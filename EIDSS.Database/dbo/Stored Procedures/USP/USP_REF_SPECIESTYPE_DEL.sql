--=================================================================================================
-- Name: USP_REF_SPECIESTYPE_DEL
--
-- Description:	Removes species type from active list of species types.
--
-- Author:		Ricky Moss
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		09/26/2018 Initial Release
-- Ricky Moss		01/03/2019 Added deleteAnyway parameter
-- Doug Albanese	08/03/2021 Added the deletion routine to deactivate the record tied to the 
--                             base reference
-- Stephen Long     11/01/2022 Added site alert logic.
-- Ann Xiong		02/24/2023 Implemented Data Audit
-- Ann Xiong		03/14/2023 Fixed a few issues
--
-- Test Code:
-- exec USP_REF_SPECIESTYPE_DEL 55615180000088, 0
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_REF_SPECIESTYPE_DEL]
(
    @IdfsSpeciesType BIGINT,
    @DeleteAnyway BIT,
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

	--Data Audit--
	declare @idfUserId BIGINT = @UserId;
	declare @idfSiteId BIGINT = @SiteId;
	declare @idfsDataAuditEventType bigint = NULL;
	declare @idfsObjectType bigint = 10017009;                         -- Species
	declare @idfObject bigint = @IdfsSpeciesType;
	declare @idfObjectTable_trtSpeciesType bigint = 75960000000;
	declare @idfDataAuditEvent bigint= NULL;
	declare @idfObjectTable_trtBaseReference bigint = 75820000000;
	declare @idfObjectTable_trtStringNameTranslation bigint = 75990000000;

	--Data Audit--

        IF (
               NOT EXISTS
        (
            SELECT idfAggrDiagnosticActionMTX
            FROM dbo.tlbAggrDiagnosticActionMTX
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfAggrProphylacticActionMTX
            FROM dbo.tlbAggrProphylacticActionMTX
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfAggrVetCaseMTX
            FROM dbo.tlbAggrVetCaseMTX
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfCampaignToDiagnosis
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfMonitoringSessionToDiagnosis
            FROM dbo.tlbMonitoringSessionToDiagnosis
            WHERE @IdfsSpeciesType = @idfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfCampaignToDiagnosis
            FROM dbo.tlbCampaignToDiagnosis
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSpecies
            FROM dbo.tlbSpecies
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT MonitoringSessionToSampleType
            FROM dbo.MonitoringSessionToSampleType
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSpeciesActual
            FROM dbo.tlbSpeciesActual
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSpeciesToGroupForCustomReport
            FROM dbo.trtSpeciesToGroupForCustomReport
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
               AND NOT EXISTS
        (
            SELECT idfSpeciesTypeToAnimalAge
            FROM dbo.trtSpeciesTypeToAnimalAge
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0
        )
           )
           OR @DeleteAnyway = 1
        BEGIN
            UPDATE trtSpeciesType
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsSpeciesType = @IdfsSpeciesType
                  AND intRowStatus = 0;

			--Data Audit

			-- tauDataAuditEvent Event Type - Delete
			set @idfsDataAuditEventType =10016002;

			-- insert record into tauDataAuditEvent
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserID,@idfSiteId, @idfsDataAuditEventType,@idfsObjectType,@idfObject, @idfObjectTable_trtSpeciesType, @idfDataAuditEvent OUTPUT

			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_trtSpeciesType, @idfObject
			-- End data audit

            UPDATE trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsSpeciesType
                  AND intRowStatus = 0;

			--Data Audit
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_trtBaseReference, @idfObject
			-- End data audit

            UPDATE trtStringNameTranslation
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsSpeciesType;

			--Data Audit
			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject )
					SELECT @idfDataAuditEvent, @idfObjectTable_trtStringNameTranslation, @idfObject
			-- End data audit

            UPDATE trtBaseReference
            SET intRowStatus = 1,
                AuditUpdateDTM = GETDATE(),
                AuditUpdateUser = @AuditUserName
            WHERE idfsBaseReference = @IdfsSpeciesType;

            INSERT INTO @SuppressSelect
            EXECUTE dbo.USP_ADMIN_EVENT_SET-1,
                                           @EventTypeId,
                                           @UserId,
                                           @IdfsSpeciesType,
                                           NULL,
                                           @SiteId,
                                           NULL,
                                           @SiteId,
                                           @LocationId,
                                           @AuditUserName;
        END
        ELSE IF (
                    EXISTS
             (
                 SELECT idfAggrDiagnosticActionMTX
                 FROM dbo.tlbAggrDiagnosticActionMTX
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfAggrProphylacticActionMTX
                 FROM dbo.tlbAggrProphylacticActionMTX
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfAggrVetCaseMTX
                 FROM dbo.tlbAggrVetCaseMTX
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfCampaignToDiagnosis
                 FROM dbo.tlbCampaignToDiagnosis
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfMonitoringSessionToDiagnosis
                 FROM dbo.tlbMonitoringSessionToDiagnosis
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfCampaignToDiagnosis
                 FROM dbo.tlbCampaignToDiagnosis
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfSpecies
                 FROM dbo.tlbSpecies
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT MonitoringSessionToSampleType
                 FROM dbo.MonitoringSessionToSampleType
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfSpeciesActual
                 FROM dbo.tlbSpeciesActual
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfSpeciesToGroupForCustomReport
                 FROM dbo.trtSpeciesToGroupForCustomReport
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                    OR EXISTS
             (
                 SELECT idfSpeciesTypeToAnimalAge
                 FROM dbo.trtSpeciesTypeToAnimalAge
                 WHERE idfsSpeciesType = @IdfsSpeciesType
                       AND intRowStatus = 0
             )
                )
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
