-- ================================================================================================
-- Name: USP_LAB_SAMPLE_GetListByBarCodes
--
-- Description:	Get sample list from bar codes
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Leo Tracchia     12/16/2021 Initial release.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_GetListByBarCodes]	
	--@LanguageID NVARCHAR(50)
	@BarcodeList NVARCHAR(MAX) = null
	--,@Page INT = 1
	--,@PageSize INT = 10
	--,@SortColumn VARCHAR(200) = 'strBarcode'
	--,@SortOrder VARCHAR(4) = 'ASC'
AS

DECLARE @ReturnCode INT = 0, @ReturnMessage VARCHAR(MAX) = 'SUCCESS';

--DECLARE @SamplesTemp TABLE (
--	StrBarcode NVARCHAR(MAX) NOT NULL		
--);

BEGIN

	BEGIN TRY
		
		SET NOCOUNT ON;		

		--INSERT INTO @SamplesTemp
		--SELECT *
		--FROM OPENJSON(@BarcodeList) WITH (StrBarcode NVARCHAR(MAX))				

		--select idfMaterial, strBarcode from tlbMaterial where strBarcode in (
		--	SELECT value 'EIDSSLaboratorySampleID' FROM STRING_SPLIT('SAD871213448,SAD871213446', ','))


		--set @BarcodeList = '''SAD871213448'', ''SAD871213446'''

		--SELECT 
		--	idfMaterial as SampleID,
		--	strBarcode AS EIDSSLaboratorySampleID
		--FROM dbo.tlbMaterial
		--WHERE strBarcode in (@BarcodeList)
		----AND intRowStatus = 0

		select 
			idfMaterial as 'SampleID'
			,strBarcode as 'EIDSSLaboratorySampleID'							
		from tlbMaterial 
		where strBarcode in (select value from STRING_SPLIT(@BarcodeList, ',')) 
		and intRowStatus = 0

		--SELECT @ReturnCode, @ReturnMessage;

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
