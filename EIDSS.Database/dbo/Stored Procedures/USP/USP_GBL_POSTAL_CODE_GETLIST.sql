

-- ================================================================================================
-- Name: USP_GBL_POSTAL_CODE_GETLIST
--
-- Description:	Get a list of postal codes as detailed in use case SYSUC07.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     06/04/2020 Initial release.
-- Mark Wilson		09/22/2021 Update to reference idfsLocation order by PostalCode
-- 
--
-- Sample code

/*
EXEC dbo.USP_GBL_POSTAL_CODE_GETLIST 
	1345200000000


*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_POSTAL_CODE_GETLIST] 
(
	@idfsLocation AS BIGINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS';
	DECLARE @ReturnCode BIGINT = 0;

	BEGIN TRY
		SELECT 
			idfPostalCode AS PostalCodeID,
			strPostCode AS PostalCodeString,
			idfsLocation,
			intRowStatus AS RowStatus

		FROM dbo.tlbPostalCode
		WHERE idfsLocation = @idfsLocation
		OR @idfsLocation IS NULL
		ORDER BY idfsLocation, strPostCode

	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode ReturnCode,
		--	@ReturnMessage ReturnMessage;

		THROW;
	END CATCH;
END
