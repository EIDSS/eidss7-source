﻿-- ============================================================================
-- Name: USP_REF_AGEGROUP_CANDEL
-- Description:	Check to see 
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss     10/26/2018	Initial release.

-- exec USP_REF_MEASUREREFEFENCE_CANDEL 952180000000
-- exec USP_REF_MEASUREREFEFENCE_CANDEL 952250000000
-- ============================================================================
CREATE PROCEDURE [dbo].[USP_REF_MEASUREREFEFENCE_CANDEL]
(
	@idfsAction bigint
)as

	DECLARE @returnMsg			VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode			BIGINT = 0;
BEGIN
	BEGIN TRY
	Declare @exists bit
		IF EXISTS(SELECT idfAggrProphylacticActionMTX FROM tlbAggrProphylacticActionMTX where idfsProphilacticAction = @idfsAction) OR
			EXISTS(SELECT idfAggrSanitaryActionMTX  from tlbAggrSanitaryActionMTX where idfsSanitaryAction = @idfsAction)
			BEGIN
				Select @exists = 1
				Select @exists as CurrentlyInUse
			END
			ELSE
			BEGIN
				Select @exists = 0
				Select @exists as CurrentlyInUse
			END
		SELECT						@returnCode, @returnMsg;
	END TRY
	BEGIN CATCH		
	BEGIN
			SET					@returnCode = ERROR_NUMBER();
			SET					@returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
									+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
									+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
									+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
									+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE(), ''))
									+ ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT				@returnCode, @returnMsg;
		END

	END CATCH
END
