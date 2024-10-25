
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterFixedPresetValue_DEL
-- Description: Deletes the parameter Fixed Presetvalue from the table.
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	-----------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Mike Kornegay	9/3/2021	Updated the in use logic to return message instead of error and
--								added base reference table update.
-- Mike Kornegay	9/3/2021	Correct return message variable.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterFixedPresetValue_DEL]
(
	@idfsParameterFixedPresetValue BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE
		@returnCode BIGINT = 0,
		@returnMsg NVARCHAR(MAX) = 'Success' 

	BEGIN TRY

		BEGIN TRANSACTION
		
		IF EXISTS(SELECT TOP 1 1 
			  FROM dbo.tlbActivityParameters
			  WHERE varValue = @idfsParameterFixedPresetValue
					AND intRowStatus = 0)
			BEGIN
				SET @returnCode = 1;
				SET @returnMsg	= 'IN USE';
			END
		ELSE
			BEGIN
				--set the base reference table first
				UPDATE	dbo.trtBaseReference
				SET		intRowStatus = 1
				WHERE	idfsBaseReference = @idfsParameterFixedPresetValue
				AND		idfsReferenceType = 19000069

				--then set the parameter fixed preset value table
				UPDATE	dbo.ffParameterFixedPresetValue
				SET		intRowStatus = 1
				WHERE idfsParameterFixedPresetValue = @idfsParameterFixedPresetValue

			END
		
		SELECT @returnCode as returnCode, @returnMsg as returnMessage

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
