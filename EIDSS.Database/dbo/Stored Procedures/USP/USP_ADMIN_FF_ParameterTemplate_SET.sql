-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTemplate_SET
-- Description: Save the Parameter Template
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	4/3/2020	Changes to get it inline with the new designer
-- Doug Albanese	4/27/2020	Changes to correct errors with commit transaction
-- Doug Albanese	10/20/2020	Added Auditing information
-- Doug Albanese	01/19/2021	Added the psuedo function call parameter for use by other SPs
-- Mark Wilson		03/02/2022	Added the INSERT INTO @SuppressSelect, removed unneeded PRINT
--	Doug Albanese	06/02/2022	Remove the Suppress to allow functioncall = 0 to work correctly.
--	Doug Albanese	06/06/2022	Not sure how this was missed, but set the CopyOnly and FunctionCall to 0
--	Doug Albanese	06/07/2022	Rearranged the functioncall supression for USP_ADMIN_FF_ParameterDesignOptions_SET
--	Doug Albanese	06/10/2022	Corrected to prevent EF from blowing up the repository call for this SP
-- Doug Albanese	09/14/2022	 Further correction on USP_ADMIN_FF_ParameterDesignOptions_SET to remove supression for fucntion calling.
-- Doug Albanese	 10/06/2022	 Converted over to a API Call SP only, rather than being used from multiple locations
-- Doug Albanese	 05/31/2023	 Removed supression on USP_ADMIN_FF_ParameterDesignOptions_SET
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTemplate_SET] 
(
	@idfsParameter BIGINT
	,@idfsFormTemplate BIGINT
	,@LangID NVARCHAR(50) = NULL
	,@idfsEditMode BIGINT = NULL
	,@intLeft INT = NULL
	,@intTop INT = NULL
	,@intWidth INT = NULL
	,@intHeight INT = NULL
	,@intScheme INT = NULL
	,@intLabelSize INT = NULL
	,@intOrder INT = NULL
	,@blnFreeze BIT = NULL
	,@User NVARCHAR(50) = ''
	,@CopyOnly INT = 0
	,@FunctionCall INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' 

	BEGIN TRY
		DECLARE @SupressSelect TABLE
		( 
			retrunCode INT,
			returnMsg NVARCHAR(200)
		)

		IF (@idfsEditMode IS NULL) SET @idfsEditMode = 10068001
		IF (@intLeft IS NULL) SET @intLeft = 0
		IF (@intTop IS NULL) SET @IntTop = 0
		IF (@intWidth IS NULL) SET @intWidth = 0
		IF (@intHeight IS NULL) SET @intHeight = 0
		IF (@intScheme IS NULL)	 SET @intScheme = 0
		IF (@blnFreeze IS NULL) SET @blnFreeze = 0
		
		IF (@intLabelSize IS NULL)
			BEGIN 
				IF (@intScheme = 0 OR @intScheme = 1)
					BEGIN
						SET @intLabelSize = @intWidth / 2
					END
			END
		ELSE
			BEGIN
				SET @intLabelSize = @intWidth
			END

		IF (@intOrder IS NULL) SET @intOrder = 0
			
		IF NOT EXISTS (SELECT TOP 1 1
					   FROM [dbo].[ffParameterForTemplate]
					   WHERE [idfsParameter] = @idfsParameter
							 AND [idfsFormTemplate] = @idfsFormTemplate)
			BEGIN
				INSERT INTO [dbo].[ffParameterForTemplate]
					(
           				[idfsParameter]
           				,[idfsFormTemplate]			  	   
						,[idfsEditMode]		
						,[blnFreeze]
						,AuditCreateDTM
						,AuditCreateUser
					)
				VALUES
					(
           				@idfsParameter
           				,@idfsFormTemplate
						,@idfsEditMode	
						,@blnFreeze	
						,GETDATE()
						,@User	
					)          
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffParameterForTemplate]
				SET [idfsEditMode] = @idfsEditMode
					,[blnFreeze] = @blnFreeze
					,[intRowStatus] = 0
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
 				WHERE [idfsParameter] = @idfsParameter
					  AND [idfsFormTemplate] = @idfsFormTemplate 						
			END

			--INSERT INTO @SupressSelect
			EXEC dbo.[USP_ADMIN_FF_ParameterDesignOptions_SET] 
			   @idfsParameter
			   ,@idfsFormTemplate
			   ,@intLeft
			   ,@intTop
			   ,@intWidth
			   ,@intHeight			
			   ,@intScheme
			   ,@intLabelSize
			   ,@intOrder
			   ,@LangID
			   ,@User
			   ,1

		 SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
