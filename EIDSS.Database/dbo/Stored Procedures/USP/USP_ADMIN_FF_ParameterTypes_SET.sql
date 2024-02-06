-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTypes_SET
-- Description: Insert or Update for Parameter Types
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Doug Albanese	10/28/2020	Alteration to use new EIDSS Next Key ID 
-- Doug Albanese	10/28/2020	Added Auditing Information
-- Doug Albanese	10/28/2020	Added idfsParameterType for updating parameter types
-- Mike Kornegay	05/24/2021	Corrected return results
-- Mike Kornegay	08/16/2021	Added DOES EXIST 
-- Mike Kornegay	08/30/2021	DOES EXIST fix for comparing Parameter Type and Default Name
-- Mike Kornegay	09/19/2021	Correct logic for DOES EXIST picking up existing parameter types on edit
-- Mike Kornegay	05/23/2022	Add HACode and Order to parameter list so parameter type is correctly saved
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTypes_SET] 
(
	@idfsParameterType		BIGINT	 = NULL
	,@DefaultName			NVARCHAR(400)	
	,@NationalName			NVARCHAR(600)	
	,@idfsReferenceType		BIGINT
	,@HACode				INT = NULL
	,@Order					INT = NULL
	,@LangID				NVARCHAR(50)
	,@User					NVARCHAR(100) = ''
)	
AS 
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE 
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'SUCCESS'

	BEGIN TRY
		BEGIN TRANSACTION;



		--check first for insert or update
		IF @idfsParameterType IS NULL
			--insert begin
			BEGIN
				--check for duplicate parameter type before inserting
				IF (EXISTS	(SELECT TOP 1 1 FROM dbo.ffParameterType AS PT
							LEFT JOIN FN_GBL_Reference_List_GET(@LangID, 19000071 /*'rftParameterType'*/) AS RT
							ON RT.idfsReference = PT.idfsParameterType
							WHERE RT.strDefault = @DefaultName
							AND PT.idfsReferenceType = @idfsReferenceType
							AND PT.intRowStatus = 0))
					BEGIN
						SET @returnCode = 1
						SET @idfsParameterType = null
						SET @returnMsg = 'DOES EXIST'
					END
				ELSE
					BEGIN
						--add or update the parameter type in the base reference table first
						EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterType OUTPUT, 
															19000071/*'rftParameterType'*/,
															@LangID, 
															@DefaultName, 
															@NationalName, 
															@HACode,
															@Order
						INSERT INTO dbo.ffParameterType
							(
								[idfsParameterType]
								,[idfsReferenceType]
								,AuditCreateDTM
								,AuditCreateUser
							)
						VALUES
							(
								@idfsParameterType
								,@idfsReferenceType
								,GETDATE()
								,@User
							)
					END
			END
			--insert end
		ELSE
			--update begin
			BEGIN
				--add or update the parameter type in the base reference table first
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsParameterType OUTPUT, 
													19000071/*'rftParameterType'*/,
													@LangID, 
													@DefaultName, 
													@NationalName, 
													@HACode,
													@Order
				UPDATE dbo.ffParameterType
				SET [idfsReferenceType] = @idfsReferenceType
					,[intRowStatus] = 0
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
				WHERE 
					[idfsParameterType] = @idfsParameterType
			END
			--update end

		SELECT @returnCode as returnCode, @returnMsg as returnMessage, @idfsParameterType as idfsParameterType

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
