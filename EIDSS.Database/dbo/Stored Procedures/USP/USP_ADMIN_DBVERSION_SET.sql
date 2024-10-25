-- ================================================================================================
-- Name: USP_ADMIN_DBVERSION_SET
--
-- Description:	Inserts the given database and app version and marks all other versions inactive.
--                      
-- Revision History:
-- Name            Date       Change Detail
-- --------------- ---------- -------------------------------------------------------------------
-- Mike Kornegay   07/11/2022 Initial release.
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DBVERSION_SET] (
	 @ApplicationVersion NVARCHAR(25)
	,@DatabaseVersion NVARCHAR(25)
	,@VersionStartTimestamp DATETIME
	,@VersionEndTimestamp DATETIME
	,@RowStatus INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ReturnCode INT = 0;
		DECLARE @ReturnMessage NVARCHAR(MAX) = 'SUCCESS';
		DECLARE @SuppressSelect TABLE (
					ReturnCode INT,
					ReturnMessage VARCHAR(200)
				);
	

		BEGIN TRANSACTION;
		
			UPDATE tlbEIDSSVersionControl SET intRowStatus = 1;

			INSERT INTO [dbo].[tlbEIDSSVersionControl]
				   ([ApplicationVersion]
				   ,[DatabaseVersion]
				   ,[Ver_Start_Timestamp]
				   ,[Ver_End_Timestamp]
				   ,[intRowStatus])
			VALUES
				   (@ApplicationVersion,
					@DatabaseVersion,
					@VersionStartTimestamp,
					@VersionEndTimestamp,
					0);

	
		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		IF @@Trancount > 0
			ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage;
	END CATCH
END