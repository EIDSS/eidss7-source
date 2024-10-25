

-- ================================================================================================
-- Name: USP_GBL_NextNumbers_GET
--
-- Description: Get next numbers for barcodes.
--          
-- Author: Mark Wilson
-- 
-- Revision History:
-- Name				Date		Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     03/25/2020 Added rack barcode and updated others to be in sync.
-- Mark Wilson		10/06/2020 Added Weekly Report Form
-- Mark Wilson		11/06/2020 updated Weekly Reporting Form
--
-- Testing Code:
-- EXEC USP_GBL_NextNumbers_GET
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_NextNumbers_GET]
AS
BEGIN
	DECLARE @RC INT;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057006,
		N'Box Barcode',
		N'BBC',
		N'',
		0,
		4;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057011,
		N'Freezer Barcode',
		N'FBC',
		N'',
		0,
		4;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057012,
		N'Shelf Barcode',
		N'SBC',
		N'',
		0,
		4;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057001,
		N'Human Aggregate Disease Report',
		N'HAD',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057003,
		N'Vet Aggregate Disease Report',
		N'VAD',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057002,
		N'Vet Aggregate Action',
		N'VAA',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057004,
		N'Animal',
		N'ANM',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057010,
		N'Farm',
		N'FRM',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057013,
		N'Animal Group',
		N'AGP',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057014,
		N'Human Disease Report',
		N'HUM',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057015,
		N'Outbreak Session',
		N'OUT',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057019,
		N'Sample Field Barcode',
		N'SFB',
		N'',
		0,
		4,
		0;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057020,
		N'Sample',
		N'SAD',
		N'',
		0,
		4,
		0;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057022,
		N'Penside Test',
		N'PEN',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057024,
		N'Vet Disease Report',
		N'VET',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057025,
		N'Vet Case Field Accession Number',
		N'VFN',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057005,
		N'Batch Test Barcode',
		N'BTB',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057026,
		N'Sample Transfer Barcode',
		N'STB',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057027,
		N'Active Surveillance Campaign',
		N'SCV',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057028,
		N'Active Surveillance Session',
		N'SSV',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057029,
		N'Vector Surveillance Session',
		N'VSS',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057030,
		N'Vector Surveillance Vector',
		N'VSR',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057031,
		N'Vector Surveillance Summary Vector',
		N'VSM',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057032,
		N'Basic Syndromic Surveillance Form',
		N'SSF',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057033,
		N'Basic Syndromic Surveillance Aggregate Form',
		N'SSA',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057034,
		N'EIDSS Person',
		N'SSA',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057035,
		N'Human Active Surveillance Campaign',
		N'SCH',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057036,
		N'Human Active Surveillance Session',
		N'SSH',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057037,
		N'Human Outbreak Case',
		N'HOC',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057038,
		N'Vet Outbreak Case',
		N'VOC',
		N'',
		0,
		4,
		1;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057039,
		N'Rack Barcode',
		N'RBC',
		N'',
		0,
		4;

	EXECUTE @RC = dbo.USP_GBL_NextNumberInit_GET 10057040,
		N'Weekly Reporting Form',
		N'HWR',
		N'',
		0,
		4;

	RETURN @RC;
END
