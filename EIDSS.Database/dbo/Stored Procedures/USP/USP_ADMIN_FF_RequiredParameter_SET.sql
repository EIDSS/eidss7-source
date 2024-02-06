-- ================================================================================================
-- Name: USP_ADMIN_FF_RequiredParameter_SET
-- Description: Set the idfsEditMode to "Mandatory" or "Oridinary"
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	1/6/2021	Initial Release
-- Doug Albanese	7/13/2021	Added the Form Template to narrow down the paramter being used
-- Doug Albanese	10/28/2021	Refactoring to get EF to generate correct return and provide auditing information
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_RequiredParameter_SET] 
(
	@idfsParameter		BIGINT,
	@idfsEditMode		BIGINT,
	@idfsFormTemplate	BIGINT,
	@User				NVARCHAR(20)
)	
AS
BEGIN	
	SET NOCOUNT ON;	

	DECLARE
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success'   ;
	
	BEGIN TRY	

		UPDATE
			ffParameterForTemplate
		SET
			idfsEditMode = @idfsEditMode,
			AuditUpdateDTM = GETDATE(),
			AuditUpdateUser = @User
		WHERE
			idfsParameter = @idfsParameter AND
			idfsFormTemplate = @idfsFormTemplate

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage, '' AS StrDuplicateField

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 

		THROW;
	END CATCH
END
