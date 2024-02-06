




-- ================================================================================================
-- Name: USP_GBL_STREET_GETList
--
-- Description:	Get a list of street names as detailed in use case SYSUC07.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     09/29/2020 Initial release.
-- Mark Wilson		09/22/2021 Update to reference idfsLocation order by strStreetName

/*
-- Test code

DECLARE @idfsLocation BIGINT = 75111140000801

EXEC dbo.USP_GBL_STREET_GETList
	@idfsLocation = @idfsLocation

 */
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_STREET_GETList] 
(
	@idfsLocation AS BIGINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
		idfStreet AS StreetID,
		strStreetName AS StreetName,
		idfsLocation,
		intRowStatus AS RowStatus

	FROM dbo.tlbStreet
	WHERE idfsLocation = @idfsLocation
	OR @idfsLocation IS NULL
	ORDER BY 
		idfsLocation,
		strStreetName

END


