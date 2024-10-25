


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: USP_GBL_GIS_NewID_GET
-- Description			: returns new ID from GIS ID set for current site
--          
-- Revision History
-- Name				Date			Change Detail
-- Mark Wilson		03-Dec-2021		renamed for E7 standards
-- Testing code:
/*

DECLARE @ID BIGINT
EXEC dbo.[USP_GBL_GIS_NewID_GET] @ID OUTPUT
PRINT @ID

*/


CREATE PROCEDURE [dbo].[USP_GBL_GIS_NewID_GET]
(
	@ID BIGINT OUTPUT 
)
AS
BEGIN
  SET NOCOUNT ON
  IF @ID < (SELECT MAX(gisNewID) FROM dbo.gisNewID)
	BEGIN
		SET @ID = (SELECT MAX(gisNewID) + 10000000 FROM dbo.gisNewID)
		INSERT INTO dbo.gisNewID (gisNewID, strA) VALUES (@ID, '')
	END
  ELSE
	BEGIN
		INSERT INTO dbo.gisNewID (strA) VALUES ('')
		SET @ID = SCOPE_IDENTITY()
	END

  SET NOCOUNT OFF 
END


