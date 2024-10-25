

--=====================================================================================================
-- Author:					Doug Albanese
-- Description:				11/23/2020  
--							
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-----------------------------------------------
-- Doug Albanese	11/23/2020	Initial creation for barcode generations
--
-- 
-- EXEC dbo.USP_ADMIN_Barcode_Get -- Generates a list of barcodes, according to configurations
--
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_Barcode_GetList] 
(
	@LangID						NVARCHAR(20)	= 'en',
	@idfsNumberName				BIGINT,
	@iNumberOfBarcodes			INT,
	@blnUsePrefix				BIT				= 0,
	@siteId						NVARCHAR(50)	= NULL,
	@blnUseYear					BIT				= 0
)
AS
BEGIN
	
	BEGIN TRY

		DECLARE @strDocumentName	NVARCHAR(200)
		DECLARE @strBarcode			NVARCHAR(200)
		DECLARE @iBarcode			INT = 0

		DECLARE @Barcodes TABLE (
			EIDSSBarcodeID	NVARCHAR(200)
		)

		Declare @SupressSelect table (
			retrunCode int,
			returnMsg varchar(200)
		)

		SELECT 
			@strDocumentName = strDocumentName
		FROM
			tstNextNumbers
		WHERE
			idfsNumberName = @idfsNumberName

		WHILE @iBarCode < @iNumberOfBarcodes
			BEGIN
				INSERT INTO @SupressSelect
				EXEC	dbo.USP_ADMIN_BarcodeNextNumber_GET @strDocumentName, @strBarCode OUTPUT , @blnUsePrefix, @siteId, @blnUseYear;	

				INSERT INTO @Barcodes (EIDSSBarcodeID) VALUES (@strBarcode)

				SET @iBarCode = @iBarCode + 1
			END

		SELECT
			EIDSSBarcodeID
		FROM
			@Barcodes

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		
		throw;
	END CATCH

END

