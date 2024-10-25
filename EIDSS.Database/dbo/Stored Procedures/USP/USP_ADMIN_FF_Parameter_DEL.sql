
-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameter_DEL
-- Description: Delete the Parameter.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Stephen Long		11/28/2018	Initial release for new API.
-- Doug Albanese	6/8/2020	Changes made to prevent "Actual" deletion, with intRowStatus tagging.
-- Doug Albanese	10/21/2020	Added Auditing Information
-- Doug Albanese	05/24/2021	Added correct aliases for return messaging.
--	Doug Albanese	07/12/2022	Reorganized to return the "error message", so that a notification can be displayed on the app
--	Doug Albanese	07/12/2022	Forcing the use of user auditing information. (Removed default on parameter)
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Parameter_DEL] 
(
	@LangId			NVARCHAR(50),
	@idfsParameter	BIGINT,
	@User			NVARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE 
		@ErrorMessage NVARCHAR(400),
		@returnCode INT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success',
		@Used INT = 0,
		@ResultMessage NVARCHAR(MAX) = '',
		@Result NVARCHAR(200) = ''

	DECLARE @Results AS TABLE(
		ObjectName NVARCHAR(MAX)
	)

	BEGIN TRY
		BEGIN TRANSACTION;
		
		IF EXISTS(SELECT TOP 1 1
					FROM dbo.tasQuerySearchField
					WHERE idfsParameter = @idfsParameter)
			SET @ErrorMessage = 'ParameterRemove_Has_tasQuerySearchField_Rows';

		IF EXISTS(SELECT TOP 1 1
					FROM dbo.ffParameterForTemplate
					WHERE idfsParameter = @idfsParameter
						AND intRowStatus = 0)
			BEGIN
				SET @ErrorMessage = 'ParameterRemove_Has_ffParameterForTemplate_Rows';

				INSERT INTO @Results
				SELECT distinct FT.Name AS ObjectName
				FROM dbo.ffParameterForTemplate pft
				inner join FN_GBL_ReferenceRepair(@LangId,19000033) FT
				on FT.idfsReference = pft.idfsFormTemplate
				WHERE idfsParameter = @idfsParameter
					AND pft.intRowStatus = 0
			END

		IF EXISTS(SELECT TOP 1 1
					FROM dbo.tlbActivityParameters
					WHERE idfsParameter = @idfsParameter
						AND intRowStatus = 0)
			SET @ErrorMessage = 'ParameterRemove_Has_tlbActivityParameters_Rows';

		IF EXISTS(SELECT TOP 1 1
					FROM dbo.ffParameterForFunction
					WHERE idfsParameter = @idfsParameter
						AND intRowStatus = 0)
			SET @ErrorMessage = 'ParameterRemove_ParameterForFunction';
	
		IF (@ErrorMessage IS NULL)
			BEGIN
				IF EXISTS(SELECT TOP 1 1
						  FROM dbo.ffParameterForTemplate
						  WHERE idfsParameter = @idfsParameter)
					BEGIN
						DECLARE
							@st_id BIGINT
						DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
						FOR SELECT DISTINCT idfsFormTemplate
							FROM dbo.ffParameterForTemplate
							WHERE idfsParameter = @idfsParameter
								  AND [intRowStatus] = 0
							OPEN curs
						FETCH NEXT FROM curs INTO @st_id
			
						WHILE @@FETCH_STATUS = 0
							BEGIN
								EXEC dbo.USP_ADMIN_FF_ParameterTemplate_DEL @idfsParameter, @st_id		
								FETCH NEXT FROM curs INTO @st_id
							END
			
						CLOSE curs
						DEALLOCATE curs
					END
			
					UPDATE ffParameterDesignOption
					SET 
						intRowStatus = 1
					WHERE
						idfsParameter = @idfsParameter
						AND idfsFormTemplate IS NULL
		
					UPDATE ffParameter
					SET
						intRowStatus = 1,
						AuditUpdateDTM = GETDATE(),
						AuditUpdateUser = @User
					WHERE
						idfsParameter = @idfsParameter
			END
		ELSE
			BEGIN
				SET @Used = 1
				SET @returnMsg = @ErrorMessage
				SET @returnCode = 202 --Accepted, but not completed due to usage of a Parameter in a template
			END

		WHILE EXISTS(SELECT TOP 1 1 FROM @Results)
			BEGIN
				SET ROWCOUNT 1
				
				SELECT @Result = ObjectName FROM @Results
				
				IF @ResultMessage = ''
					BEGIN
						SET @ResultMessage = @Result
					END
				ELSE
					BEGIN
						SET @ResultMessage = @ResultMessage + '\n' + @Result
					END
				
				DELETE FROM @Results
				SET ROWCOUNT 0
			END
		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage, @Used as Used, @ResultMessage as ResultMessage

		COMMIT TRANSACTION;
	END TRY 
	BEGIN CATCH   
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
END
