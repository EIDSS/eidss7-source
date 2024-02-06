--=================================================================================================
-- Name: USP_REF_REPORTDIAGNOSISGROUP_SET
-- Description:	Creates or updates a report diagnosis group
--
-- Author:		Ricky Moss
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		10/16/2018 Initial release
-- Ricky Moss		01/16/2019 Removed return code
-- Ricky Moss		02/10/2019 Checks to see when updating a report diagnosis group that the name 
--                             does not exists in another reference and updates English value
-- Ricky Moss		09/26/2019 Refactor for duplicated check.
-- Ricky Moss		02/17/2020 Refactored to check for duplicates and update translated values
-- Ricky Moss		05/19/2020 Resolution to update values
-- Ricky Moss		06/03/2020 Resolution for saving changes
-- Leo Tracchia		08/03/2021 Removed duplication check on National value. Only required on 
--                             Default value.
-- Stephen Long     07/18/2022 Added site alert logic.
--
-- exec USP_REF_REPORTDIAGNOSISGROUP_SET 55540680000292, 'Test Locally 28', 'Test Locally 28', NULL, 'en'
-- exec USP_REF_REPORTDIAGNOSISGROUP_SET NULL, 'Rabies Group', 'Rabies Group', NULL, 'en'
-- exec USP_REF_REPORTDIAGNOSISGROUP_SET 53352780000000, 'Rabies Group', 'Rabies Group', NULL, 'en'
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_REPORTDIAGNOSISGROUP_SET]
(
    @idfsReportDiagnosisGroup BIGINT = NULL,
    @strDefault NVARCHAR(MAX),
    @strName NVARCHAR(MAX),
    @strCode NVARCHAR(500),
    @LangID NVARCHAR(50),
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN

    DECLARE @ReturnMessage NVARCHAR(MAX) = N'SUCCESS',
            @ReturnCode BIGINT = 0,
            @existingDefault BIGINT,
            @existingName BIGINT;
    DECLARE @SuppressSelect TABLE
    (
        ReturnCode INT,
        ReturnMessage NVARCHAR(MAX)
    );

    BEGIN TRY
        SELECT @existingDefault =
        (
            SELECT TOP 1
                (idfsReference)
            FROM dbo.FN_GBL_Reference_GETList(@LangID, 19000130)
            WHERE strDefault = @strDefault
        );

        IF (
               @existingDefault IS NOT NULL
               AND @existingDefault <> @idfsReportDiagnosisGroup
           )
           OR (
                  @existingDefault IS NOT NULL
                  AND @idfsReportDiagnosisGroup IS NULL
              )
        BEGIN
            SELECT @ReturnMessage = 'DOES EXIST';
            SELECT @idfsReportDiagnosisGroup =
            (
                SELECT idfsBaseReference
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000130
            )
        END
        ELSE IF (
                    EXISTS
             (
                 SELECT TOP 1
                     (idfsBaseReference)
                 FROM dbo.trtBaseReference
                 WHERE strDefault = @strDefault
                       AND idfsReferenceType = 19000130
                       AND intRowStatus = 1
             )
                    OR (EXISTS
             (
                 SELECT TOP 1
                     (trtStringNameTranslation.idfsBaseReference)
                 FROM trtBaseReference
                     JOIN trtStringNameTranslation
                         ON trtBaseReference.idfsBaseReference = trtStringNameTranslation.idfsBaseReference
                 WHERE strTextString = @strName
                       AND idfsReferenceType = 19000130
                       AND trtBaseReference.intRowStatus = 1
             )
                       )
                       AND @idfsReportDiagnosisGroup is NULL
                )
        BEGIN
            SELECT @idfsReportDiagnosisGroup =
            (
                SELECT TOP 1
                    (idfsBaseReference)
                FROM dbo.trtBaseReference
                WHERE strDefault = @strDefault
                      AND idfsReferenceType = 19000130
            );
            UPDATE dbo.trtReportDiagnosisGroup
            SET intRowStatus = 0,
                strCode = @strCode,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
                  AND intRowStatus = 1;

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 0,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsReportDiagnosisGroup
                  AND intRowStatus = 1;

            IF (EXISTS
            (
                SELECT idfsBaseReference
                FROM dbo.trtStringNameTranslation
                WHERE idfsBaseReference = @idfsReportDiagnosisGroup
                      AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
                      AND intRowStatus = 0
            )
               )
            BEGIN
                UPDATE dbo.trtStringNameTranslation
                SET strTextString = @strName,
                    AuditUpdateDTM = GETDATE(),
                    AuditUpdateUser = @AuditUserName
                WHERE idfsBaseReference = @idfsReportDiagnosisGroup
                      AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID);
            END
            ELSE
            BEGIN
                INSERT INTO dbo.trtStringNameTranslation
                (
                    idfsBaseReference,
                    idfsLanguage,
                    strTextString,
                    intRowStatus,
                    AuditCreateDTM,
                    AuditCreateUser
                )
                VALUES
                (@idfsReportDiagnosisGroup,
                 dbo.FN_GBL_LanguageCode_GET(@LangID),
                 @strName,
                 0  ,
                 GETDATE(),
                 @AuditUserName
                );
            END

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsReportDiagnosisGroup,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE IF EXISTS
             (
                 SELECT idfsBaseReference
                 FROM dbo.trtBaseReference
                 WHERE idfsBaseReference = @idfsReportDiagnosisGroup
                       AND intRowStatus = 0
             )
                AND EXISTS
             (
                 SELECT idfsReportDiagnosisGroup
                 from dbo.trtReportDiagnosisGroup
                 WHERE idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup
                       and intRowStatus = 0
             )
        BEGIN
            UPDATE dbo.trtReportDiagnosisGroup
            SET strCode = @strCode
            WHERE idfsReportDiagnosisGroup = @idfsReportDiagnosisGroup

            UPDATE trtBaseReference
            SET strDefault = @strDefault,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsReportDiagnosisGroup;

            UPDATE dbo.trtStringNameTranslation
            SET strTextString = @strName,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @idfsReportDiagnosisGroup
                  AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID);

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsReportDiagnosisGroup,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE
        BEGIN
            INSERT INTO @SuppressSelect
            EXEC dbo.USP_GBL_BaseReference_SET @ReferenceID = @idfsReportDiagnosisGroup OUTPUT,
                                               @ReferenceType = 19000130,
                                               @LangID = @LangID,
                                               @DefaultName = @strDefault,
                                               @NationalName = @strName,
                                               @HACode = 0,
                                               @Order = 0,
                                               @System = 0,
                                               @User = @AuditUserName;

            INSERT INTO dbo.trtReportDiagnosisGroup
            (
                idfsReportDiagnosisGroup,
                strCode,
                AuditCreateDTM,
                AuditCreateUser
            )
            VALUES
            (@idfsReportDiagnosisGroup, @strCode, GETDATE(), @AuditUserName);

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsReportDiagnosisGroup,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        SELECT @ReturnCode AS 'ReturnCode',
               @ReturnMessage AS 'ReturnMessage',
               @idfsReportDiagnosisGroup AS 'idfsReportDiagnosisGroup';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
