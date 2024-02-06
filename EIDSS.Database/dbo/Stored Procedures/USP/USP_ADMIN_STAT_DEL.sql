--*************************************************************
-- Name 				: USP_ADMIN_STAT_DEL
-- Description			: Get Settlement details
--          
-- Author               : Ricky Moss
-- Revision History
--		Name       Date       Change Detail
-- Ricky Moss	 08/06/2019		Refactored SP to accommodate API methods
-- Ricky Moss	 08/30/2019		Returns success message
-- Leo Tracchia	 03/01/2023		Added logic for data auditing
--
-- Testing code:
-- EXECUTE USP_ADMIN_STAT_DEL 53357400000000
--*************************************************************

CREATE PROCEDURE [dbo].[USP_ADMIN_STAT_DEL]
(
	@idfStatistic BIGINT,
	@SiteId BIGINT,
    @UserId BIGINT
)

AS

BEGIN

	DECLARE @returnCode INT = 0
	DECLARE @returnMsg NVARCHAR(50) = 'SUCCESS'

	BEGIN TRY	    

		DECLARE @SuppressSelect TABLE
		(
			ReturnCode INT,
			ReturnMessage NVARCHAR(MAX)
		);

		--Begin: Data Audit--	

			DECLARE @idfUserId BIGINT = @UserId;
			DECLARE @idfSiteId BIGINT = @SiteId;
			DECLARE @idfsDataAuditEventType bigint = NULL;
			DECLARE @idfsObjectType bigint = 10017036; -- Need to review the value --
			DECLARE @idfObject bigint = @idfStatistic;
			DECLARE @idfObjectTable_tlbStatistic bigint = 75720000000;		
			DECLARE @idfDataAuditEvent bigint = NULL;	

			-- tauDataAuditEvent Event Type - Delete 
			set @idfsDataAuditEventType = 10016002;
			
		--End: Data Audit--	
		
		UPDATE tlbStatistic SET intRowStatus = 1 WHERE idfStatistic = @idfStatistic 
		SELECT @returnCode 'returnCode', @returnMsg 'returnMessage'

		--Begin: Data Audit

			-- insert record into tauDataAuditEvent - 
			INSERT INTO @SuppressSelect
			EXEC USSP_GBL_DataAuditEvent_GET @idfUserId, @idfSiteId, @idfsDataAuditEventType, @idfsObjectType, @idfObject, @idfObjectTable_tlbStatistic, @idfDataAuditEvent OUTPUT

			INSERT INTO tauDataAuditDetailDelete(idfDataAuditEvent, idfObjectTable, idfObject)
			VALUES (@idfDataAuditEvent, @idfObjectTable_tlbStatistic, @idfObject)

		--End: Data Audit, trtDiagnosis--

	END TRY
	BEGIN CATCH
		THROW
	END CATCH

END
