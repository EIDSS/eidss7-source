
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterInUse
-- Description: Checks if parameter has received an answer 
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Doug Albanese	03/06/2020	Initial release for new API.
-- Doug Albanese	07/13/2021	Corrected to operate on the right test for when idfsFormTemplate is populated
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterInUse] 
(	
	@idfsParameter			BIGINT = NULL,
	@idfsFormTemplate		BIGINT = NULL
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE
		@Result BIT,
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX) 

	SET @Result = 0;

	BEGIN TRY
		IF @idfsParameter IS NOT NULL and @idfsFormTemplate IS NULL
			BEGIN
				IF (EXISTS(SELECT TOP 1 1 
						   FROM dbo.tlbActivityParameters
						   WHERE [idfsParameter] = @idfsParameter))
					BEGIN
						SET @Result = 1;
					END
			END
		ELSE
			BEGIN
				IF (EXISTS(SELECT TOP 1 1
							FROM tlbActivityParameters ap
							LEFT JOIN ffParameter p
									ON p.idfsParameter = ap.idfsParameter
							LEFT JOIN ffSection s 
									ON s.idfsSection = p.idfsSection
							LEFT JOIN ffSectionForTemplate sft 
									ON sft.idfsSection = s.idfsSection
							LEFT JOIN ffFormTemplate ft 
									ON ft.idfsFormTemplate = sft.idfsFormTemplate
							WHERE 
									ft.idfsFormTemplate = @idfsFormTemplate))
					BEGIN
						SET @Result = 1;
					END
			END
	
		SELECT @Result AS Used

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
