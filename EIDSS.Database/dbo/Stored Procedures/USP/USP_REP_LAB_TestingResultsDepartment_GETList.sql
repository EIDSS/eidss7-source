

--*************************************************************************
-- Name 				: dbo.USP_REP_LAB_TestingResultsDepartment_GETList
-- Description			: This procedure used in Laboratory Testing Results 
--                        report to populate Lab Department values.
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
EXEC dbo.USP_REP_LAB_TestingResultsDepartmentLookup 'ru', N'SWAZ1779515'
EXEC dbo.USP_REP_LAB_TestingResultsDepartmentLookup 'en', N'SGETBTB0110013'

SELECT  tm.strBarcode,*
FROM tlbMaterial tm
		INNER JOIN tstSite ts
		ON ts.idfsSite = tm.idfsCurrentSite
		INNER JOIN tlbOffice to1
		ON to1.idfOffice = ts.idfOffice
		INNER JOIN tlbDepartment td
		ON td.idfOrganization = to1.idfOffice
WHERE
idfHumanCase IS NOT NULL

 --tm.strBarcode = N'SAZTO002110001'
*/

CREATE PROCEDURE [dbo].[USP_REP_LAB_TestingResultsDepartment_GETList]
	(
		@LangID	AS NVARCHAR(10), 
		@SampleID	AS VARCHAR(36)
	)
AS	

DECLARE @ReportTable TABLE 
(
	idfsReference BIGINT PRIMARY KEY NOT NULL, 
	strName NVARCHAR(200)
)

--o If sample was not found it should returns (-2, null) 
--o If appropriate sample was found, and the laboratory (EIDSS site), where it is located, 
--		does not contain any department, it should returns (-1, null)
--o If appropriate sample was found, and the laboratory (EIDSS site), where it is located, 
--		contains at least one department, 
--		then names of all departments of this laboratory  shall be returned with their ids

IF NOT EXISTS (SELECT * FROM dbo.tlbMaterial tm WHERE tm.strBarcode = @SampleID)
BEGIN
	INSERT INTO @ReportTable VALUES (-2, null)
END
ELSE
IF NOT EXISTS (
	SELECT * 
	FROM dbo.tlbMaterial tm
		INNER JOIN dbo.tstSite ts
		ON ts.idfsSite = tm.idfsCurrentSite
		INNER JOIN dbo.tlbOffice to1
		ON to1.idfOffice = ts.idfOffice
		INNER JOIN dbo.tlbDepartment td
		ON td.idfOrganization = to1.idfOffice
	WHERE tm.strBarcode = @SampleID
)	
BEGIN
	INSERT INTO @ReportTable VALUES (-1, null) 
END
ELSE 	
IF EXISTS (
	SELECT * 
	FROM dbo.tlbMaterial tm
		INNER JOIN dbo.tstSite ts
		ON ts.idfsSite = tm.idfsCurrentSite
		INNER JOIN dbo.tlbOffice to1
		ON to1.idfOffice = ts.idfOffice
		INNER JOIN dbo.tlbDepartment td
		ON td.idfOrganization = to1.idfOffice
	WHERE tm.strBarcode = @SampleID
)	
BEGIN
	INSERT INTO @ReportTable(idfsReference, strName)
	SELECT td.idfDepartment, frr.name
	FROM dbo.tlbDepartment td
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000164) frr
		ON td.idfsDepartmentName = frr.idfsReference
		INNER JOIN dbo.tlbOffice to1
		ON td.idfOrganization = to1.idfOffice
		INNER JOIN dbo.tstSite ts
		ON to1.idfOffice = ts.idfOffice
		INNER JOIN dbo.tlbMaterial tm
		ON ts.idfsSite = tm.idfsCurrentSite
	WHERE tm.strBarcode = @SampleID
END

SELECT idfsReference, 
	strName
FROM @ReportTable


