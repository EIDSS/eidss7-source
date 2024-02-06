


--*************************************************************
-- Name 				: USP_ADMIN_SYSTEMEVENTS_LOG_SET
-- Description			: Set AuditEventSystemLog
--          
-- Author               : Mani
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
--
--

CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEMEVENTS_LOG_SET]
(
	@AuditObjectID AS BIGINT,
	@AuditPrimaryTable AS NVARCHAR(200),
	@idfObjectID AS BIGINT,
	@idfAppUserID AS BIGINT=NULL,
	@idfSiteID AS BIGINT =NULL,
	@idfsModule AS BIGINT,
	@PageName AS NVARCHAR(200)

	)
AS

DECLARE @AuditEventSystemLogUID AS BIGINT;
DECLARE @ReturnCode INT = 0;
DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
DECLARE @SuppressSelect TABLE (
	ReturnCode INT,
	ReturnMessage VARCHAR(200)
	);

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		BEGIN
			
			INSERT INTO @SuppressSelect
			EXEC dbo.USP_GBL_NEXTKEYID_GET 'AuditEventSystemLog',
				@AuditEventSystemLogUID OUTPUT;

		
			INSERT INTO dbo.AuditEventSystemLog(
				AuditEventSystemLogUID,
				AuditObjectId,
				AuditPrimaryTable,
				idfObjectID,
				idfAppUserID,
				idfSiteID,
				AuditCreateUser,
				AuditCreateDTM,
				idfsModule,
				PageName
				
				)
			VALUES (
				@AuditEventSystemLogUID,
				@AuditObjectID,
				@AuditPrimaryTable,
				@idfObjectID,
				@idfAppUserID,
				@idfSiteID,
				@idfAppUserID,
				GETDATE(),
				@idfsModule,
				@PageName

			
				);
		END

		IF @@TRANCOUNT > 0
			COMMIT;

		SELECT @ReturnCode 'ReturnCode',
			@ReturnMessage 'ReturnMessage',
			@AuditEventSystemLogUID '@AuditEventSystemLogUID'
			
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;

		THROW;
	END CATCH
END
