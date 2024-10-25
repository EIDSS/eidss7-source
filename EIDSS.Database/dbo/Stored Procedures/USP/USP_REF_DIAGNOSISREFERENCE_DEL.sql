--=================================================================================================
-- Name: USP_REF_DIAGNOSISREFERENCE_DEL
--
-- Description: Removes disease reference from active list of diseases
--							
-- Author:		Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/26/2018 Initial Release
-- Ricky Moss		12/12/2018 Removed return codes
-- Ricky Moss		02/09/2019 Added removal of tests, sample type and penside tests from disease
-- Ricky Moss		03/31/2019 Remove delete Anyway parameter
-- Leo Tracchia		11/25/2020 Added @forceDelete parameter as optional
-- Doug Albanese	08/03/2021 Added the deletion routine to deactivate the record tied to the 
--                             base reference
-- Stephen Long     10/31/2022 Added site alert logic.
-- Leo Tracchia		02/20/2023 Added data audit logic for deletes
-- Leo Tracchia     05/01/2023 Fixed bug for data audit logs on deletes
--
-- Test Code:
-- exec USP_REF_DIAGNOSISREFERENCE_DEL 6618200000000, 0
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_DIAGNOSISREFERENCE_DEL]
(
    @IdfsDiagnosis BIGINT,
    @ForceDelete bit = 0,
    @EventTypeId BIGINT,
    @SiteId BIGINT,
    @UserId BIGINT,
    @LocationId BIGINT,
    @AuditUserName NVARCHAR(200)
)
AS
BEGIN
    BEGIN TRY
        DECLARE @ReturnCode INT = 0,
                @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
        DECLARE @SuppressSelect TABLE
        (
            ReturnCode INT,
            ReturnMessage NVARCHAR(MAX)
        );

        IF (
               (
                   NOT EXISTS
        (
            SELECT idfAggrDiagnosticActionMTX
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrHumanCaseMTX
            FROM dbo.tlbAggrHumanCaseMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrDiagnosticActionMTX
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrProphylacticActionMTX
            FROM dbo.tlbAggrProphylacticActionMTX
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfAggrVetCaseMTX
            FROM dbo.tlbAggrVetCaseMTX
            WHERE idfsSpeciesType = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfCampaign
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfCampaignToDiagnosis
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsSpeciesType = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfMonitoringSession
            FROM dbo.tlbMonitoringSessionToDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfMonitoringSessionToDiagnosis
            FROM dbo.tlbMonitoringSessionToDiagnosis
            WHERE idfsSpeciesType = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfMonitoringSessionSummary
            FROM dbo.tlbMonitoringSessionSummaryDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfPensideTest
            FROM dbo.tlbPensideTest
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfTesting
            FROM dbo.tlbTesting
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfTestValidation
            FROM dbo.tlbTestValidation
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfVaccination
            FROM dbo.tlbVaccination
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfsVSSessionSummaryDiagnosis
            FROM dbo.tlbVectorSurveillanceSessionSummaryDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfDiagnosisAgeGroupToDiagnosis
            FROM dbo.trtDiagnosisAgeGroupToDiagnosis
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
                   AND NOT EXISTS
        (
            SELECT idfDiagnosisToGroupForReportType
            FROM dbo.trtDiagnosisToGroupForReportType
            WHERE idfsDiagnosis = @IdfsDiagnosis
        )
                   AND NOT EXISTS
        (
            SELECT idfFFObjectToDiagnosisForCustomReport
            FROM dbo.trtFFObjectToDiagnosisForCustomReport
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0
        )
               )
               or @ForceDelete = 1
           )
        BEGIN
			
			--Begin: Data Audit--	

				DECLARE @idfUserId BIGINT = @UserId;
				DECLARE @idfSiteId BIGINT = @SiteId;
				DECLARE @idfsDataAuditEventType bigint = NULL;
				DECLARE @idfsObjectType bigint = 10017018; 
				DECLARE @idfObject bigint = @IdfsDiagnosis;
				DECLARE @idfObjectTable_trtDiagnosis bigint = 75840000000;		
				DECLARE @idfObjectTable_trtBaseReference bigint = 75820000000;
				DECLARE @idfObjectTable_trtStringNameTranslation bigint = 75990000000;
				DECLARE @idfDataAuditEvent bigint = NULL;	

				-- tauDataAuditEvent Event Type - Delete 
				set @idfsDataAuditEventType = 10016002;
			
				-- insert record into tauDataAuditEvent - 
				INSERT INTO @SuppressSelect
				EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtDiagnosis, @idfDataAuditEvent OUTPUT

			--End: Data Audit--	

            UPDATE dbo.trtDiagnosis
            SET intRowStatus = 1
            WHERE idfsDiagnosis = @IdfsDiagnosis
                  AND intRowStatus = 0

			--Begin: Data Audit, trtDiagnosis--				

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtDiagnosis, @idfObject)

			--End: Data Audit, trtDiagnosis--
				  
            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsDiagnosis
                  AND intRowStatus = 0

			--Begin: Data Audit, trtBaseReference--				

				-- insert record into tauDataAuditEvent - 
				--INSERT INTO @SuppressSelect
				--EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtBaseReference, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtBaseReference, @idfObject)

			--End: Data Audit, trtBaseReference--

            UPDATE dbo.trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsDiagnosis

			--Begin: Data Audit, trtStringNameTranslation--				

				-- insert record into tauDataAuditEvent - 
				--INSERT INTO @SuppressSelect
				--EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_trtStringNameTranslation, @idfDataAuditEvent OUTPUT

				INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
				VALUES (@idfDataAuditEvent, @idfObjectTable_trtStringNameTranslation, @idfObject)

			--End: Data Audit, trtStringNameTranslation--

            UPDATE dbo.trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsDiagnosis		

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @IdfsDiagnosis,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE
        BEGIN
            SELECT @ReturnCode = -1;
            SELECT @ReturnMessage = 'IN USE';
        END

        SELECT @ReturnCode AS ReturnCode,
               @ReturnMessage AS ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
