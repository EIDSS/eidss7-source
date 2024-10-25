
-- ============================================================================
-- Name: USP_GBL_TEST_DISEASE_GETList
--
-- Description:	Get test name and category types by disease matrix list.
--                      
-- Revision History:
-- Name             Date		Change Detail
-- ---------------- ----------	-----------------------------------------------
-- Stephen Long     10/12/2018	Initial release.
-- Stephen Long     02/01/2019	Added disease ID column and modified where 
--								clause to IN from wild card.
-- Doug Albanese	01/04/2022	Corrected the use of DiseaseIDList to operate as a table of data
-- Mani Govindarajan 04/04/2023 Added else condition for non filtered by disease.

-- ============================================================================
CREATE PROCEDURE [dbo].[USP_GBL_TEST_DISEASE_GETList] (
	@LanguageID NVARCHAR(50),
	@DiseaseIDList VARCHAR(MAX) =NULL
	)
AS
BEGIN
	SET NOCOUNT ON;


	BEGIN TRY
		IF (@DiseaseIDList IS NOT NULL)
		BEGIN
			SELECT distinct td.idfsTestName AS TestNameTypeID,
				testNameType.name AS TestNameTypeName,
				td.idfsTestCategory AS TestCategoryTypeID,
				testCategoryType.name AS TestCategoryTypeName,
				td.idfsDiagnosis AS DiseaseID
			FROM dbo.trtTestForDisease td
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) AS testNameType
				ON testNameType.idfsReference = td.idfsTestName
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) AS testCategoryType
				ON testCategoryType.idfsReference = td.idfsTestCategory
			LEFT JOIN dbo.trtTestForDiseaseToCP tdcp
				ON tdcp.idfTestForDisease = td.idfTestForDisease
					WHERE td.idfsDiagnosis IN (select * from STRING_SPLIT(@DiseaseIDList,','))
				AND td.intRowStatus = 0-- and testNameType.intHACode=2 --and td.idfsTestCategory is NOT NULL
			GROUP BY td.idfsTestName,
				testNameType.name,
				td.idfsTestCategory,
				testCategoryType.name,
				td.idfsDiagnosis;
		END
		ELSE
		BEGIN

			SELECT td.idfsTestName AS TestNameTypeID,
				testNameType.name AS TestNameTypeName,
				NULL AS TestCategoryTypeID,
				NULL AS TestCategoryTypeName,
				cast(0 as bigint) as DiseaseID

			FROM dbo.trtTestForDisease td
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000097) AS testNameType
				ON testNameType.idfsReference = td.idfsTestName
			LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000095) AS testCategoryType
				ON testCategoryType.idfsReference = td.idfsTestCategory
			--LEFT JOIN dbo.trtTestForDiseaseToCP tdcp
				--ON tdcp.idfTestForDisease = td.idfTestForDisease
			WHERE td.intRowStatus = 0 --and testNameType.intHACode=2 --and td.idfsTestCategory is NOT NULL
			GROUP BY td.idfsTestName,
				testNameType.name
				--td.idfsTestCategory,
				--testCategoryType.name
				--,td.idfsDiagnosis;
		END

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
