
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterFixedPresetValue_SET
-- Description: Insert or update Parameter Fixed Preset Values. 
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Lamont Mitchell	01/02/18	Aliased Output columns, remobed Output declarations on @idfsParameterFixedPresetValue and added to Output in Select Statement
-- Doug Albanese	12/31/2020	Removed EIDSS 6.1 SP with new "Next Key" generating function. Altered parameter, idfsParameterFixedPresetValue, to default as =1. Added BEGIN TRANSACTION 
-- Doug Albanese	01/08/2021	Corrected the Next Key table entry to obtain the correct idfs value for a new record
-- Doug Albanese	01/08/2021	Alter to use USSP instead of USB, which seems to be outdated.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterFixedPresetValue_SET] 
(
	@idfsParameterType BIGINT
	,@DefaultName NVARCHAR(400)	
	,@NationalName  NVARCHAR(600)	
	,@LangID NVARCHAR(50) = 'en'
	,@intOrder INT = NULL
	,@idfsParameterFixedPresetValue BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' ;

		Declare @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)   

	BEGIN TRY
		BEGIN TRANSACTION;
			
		INSERT INTO @SupressSelect
		EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterFixedPresetValue OUTPUT,19000069,@LangID, @DefaultName, @NationalName, 0, @intOrder

		IF NOT EXISTS (SELECT TOP 1 1
					   FROM dbo.[ffParameterFixedPresetValue]
					   WHERE [idfsParameterFixedPresetValue] = @idfsParameterFixedPresetValue)
			BEGIN
				INSERT INTO dbo.[ffParameterFixedPresetValue]
					(
						[idfsParameterFixedPresetValue]
						,[idfsParameterType]
					)
				VALUES
					(
						@idfsParameterFixedPresetValue
						,@idfsParameterType			
					)
			END
		ELSE
			BEGIN
				UPDATE dbo.[ffParameterFixedPresetValue]
				SET [idfsParameterType] = @idfsParameterType
					,[intRowStatus] = 0
				WHERE [idfsParameterFixedPresetValue] = @idfsParameterFixedPresetValue
			END

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage', @idfsParameterFixedPresetValue 'idfsParameterFixedPresetValue'

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
