
--*************************************************************
-- Name 				: USP_VET_PensideTests_List
-- Description			: Penside Tests for Vet report.
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
--
--Example of a call of procedure:
/*
select * FROM dbo.tlbVetCase
exec Report.USP_VET_PensideTests_List 5356 , 'en-US' 
  
*/

CREATE  PROCEDURE [Report].[USP_VET_PensideTests_List] 
    (
        @ObjID AS BIGINT,
        @LangID AS NVARCHAR(10)
    )
AS
	SELECT		
		pTestType.[name] AS strTestName,
		M.strFieldBarcode AS strFieldSampleID,
		rfSpecimenType.[name] AS strSampleType,
		COALESCE(SpeciesType.name, SpeciesType.strDefault, '') + ' ' + COALESCE(A.strAnimalCode, H.strHerdCode,'') AS strSpecies,
		pTestResult.[name] AS strTestResult 	
	 
	FROM dbo.tlbVetCase AS VC
		   
	LEFT JOIN dbo.tlbMaterial AS M
	     LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000087) AS rfSpecimenType ON M.idfsSampleType = rfSpecimenType.idfsReference
				ON	M.idfVetCase = VC.idfVetCase AND M.intRowStatus = 0
		   
	INNER JOIN	dbo.tlbPensideTest AS pTest
	     LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000105) AS pTestResult ON pTestResult.idfsReference = pTest.idfsPensideTestResult
	     LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000104) AS pTestType ON pTestType.idfsReference = pTest.idfsPensideTestName
				ON pTest.idfMaterial = M.idfMaterial AND pTest.intRowStatus = 0

	LEFT JOIN dbo.tlbSpecies AS S
		INNER JOIN dbo.tlbHerd AS H ON S.idfHerd = H.idfHerd
				ON	M.idfSpecies = S.idfSpecies AND S.intRowStatus = 0

	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) SpeciesType ON SpeciesType.idfsReference = S.idfsSpeciesType
			
	LEFT JOIN dbo.tlbAnimal AS A ON M.idfAnimal = A.idfAnimal AND A.intRowStatus = 0
			
	WHERE (VC.idfVetCase = @ObjID OR @ObjID IS NULL)
	AND VC.intRowStatus = 0
			

