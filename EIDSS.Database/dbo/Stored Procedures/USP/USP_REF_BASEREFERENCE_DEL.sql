-- ================================================================================================
-- Name: USP_REF_BASEREFERENCE_DEL
-- Description:	Removes a base reference
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		02/10/2019 Initial release.
-- Ricky Moss		02/12/2019 Returns values.
-- LAMONT MITCHELL	06/17/2021 PROHIBITED DELETION FOR REFERENCE TYPES THAT ARE FOUND BASED ON 
--                             USE CASE DOCUMENT SAUC40
-- Stephen Long     10/26/2022 Added site alert for reference table change event.
--
-- exec USP_REF_BASEREFERENCE_DEL 55540680000289
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_BASEREFERENCE_DEL]
(
    @idfsBaseReference BIGINT,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
declare @idfUserId BIGINT =NULL;
declare @idfSiteId BIGINT = NULL;
declare @idfsDataAuditEventType bigint = 10016002;
declare @idfsObjectType bigint = 10017042;
declare @idfObject bigint = @idfsBaseReference;
declare @idfObjectTable_tlbTestMatrix bigint = 75820000000;
declare @idfDataAuditEvent bigint= NULL; 
-- Get and Set UserId and SiteId
select @idfUserId =userInfo.UserId, @idfSiteId=UserInfo.SiteId from dbo.FN_UserSiteInformation(@AuditUserName) userInfo
    BEGIN TRY
        DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
                @ReturnCode BIGINT = 0, 
                @Duplicate BIT = 0;
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        SELECT @Duplicate =
        (
            SELECT Top (1)
                Case
                    WHEN rt.idfsReferenceType = 19000001 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000003 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000004 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000007 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000012 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000013 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000015 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000016 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000017 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000018 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000020 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000023 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000025 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000028 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000030 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000031 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000034 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000036 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000039 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000040 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000041 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000042 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000043 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000049 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000057 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000059 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000063 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000067 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000068 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000076 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000080 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000081 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000082 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000085 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000089 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000091 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000093 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000094 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000095 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000100 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000102 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000103 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000106 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000108 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000110 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000111 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000112 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000113 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000114 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000115 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000117 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000128 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000129 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000133 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000151 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000155 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000158 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000160 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000163 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000504 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000512 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000513 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000514 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000526 THEN
                        1
                    WHEN rt.idfsReferenceType = 19000527 THEN
                        1
                    WHEN rt.idfsReferenceType IS NULL THEN
                        0
                    ELSE
                        0
                END
            FROM dbo.trtReferenceType rt
                JOIN dbo.trtBaseReference br
                    ON rt.idfsReferenceType = br.idfsReferenceType
            WHERE br.idfsBaseReference = @idfsBaseReference
        )

        IF @Duplicate = 0
        BEGIN
            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1, 
                AuditUpdateUser = @AuditUserName, 
                AuditUpdateDTM = GETDATE()
            WHERE idfsBaseReference = @idfsBaseReference;

			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_tlbTestMatrix, @idfDataAuditEvent OUTPUT
			insert into dbo.tauDataAuditDetailUpdate (idfDataAuditEvent, idfObjectTable, idfColumn, idfObject, idfObjectDetail, strOldValue, strNewValue)
			values (@idfDataAuditEvent,@idfObjectTable_tlbTestMatrix, 4578170000000,@idfObject,null,0,1) 

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1, 
                AuditUpdateUser = @AuditUserName, 
                AuditUpdateDTM = GETDATE()
            WHERE idfsBaseReference = @idfsBaseReference;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @idfsBaseReference,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE
        BEGIN
            SELECT @ReturnMessage = 'CAN NOT DELETE';
        END
        SELECT @ReturnCode 'ReturnCode',
               @ReturnMessage 'ReturnMessage';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
