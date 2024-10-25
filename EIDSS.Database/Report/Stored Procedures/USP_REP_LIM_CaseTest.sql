


-- ================================================================================================
-- Name: report.USP_REP_LIM_CaseTest
--
-- Description: Select Disease Report Test details
--						
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mark Wilson    07/07/2022  Initial version, Converted to E7 standards.
--
-- Testing code:

/*
--Example of a call of procedure:

select * FROM dbo.tlbVetCase where introwstatus = 0
select * FROM dbo.tlbHumanCase where introwstatus = 0

exec report.USP_REP_LIM_CaseTest @LangID=N'en-US',@ObjID=5176350001177
exec report.USP_REP_LIM_CaseTest @LangID=N'en-US',@ObjID=1570


*/


CREATE PROCEDURE [Report].[USP_REP_LIM_CaseTest]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS

	CREATE TABLE #TestResultsAmendmentHistory
	(
	strFirstTestResult NVARCHAR(2000),
	datAmendmentDate NVARCHAR(2000),
	strAmendedByPerson NVARCHAR(2000),
	strAmendedByOrganization NVARCHAR(2000),
	strNewTestResult NVARCHAR(2000),
	strReasonOfAmended NVARCHAR(2000),
	srtNewCommentary NVARCHAR(2000),
	srtOldCommentary NVARCHAR(2000)
	)

	INSERT INTO #TestResultsAmendmentHistory
	EXEC report.USP_Rep_Lim_TestResultsAmendmentHistory_GET @LangID,@ObjID

	--Inserting dummy values if no records
	IF (SELECT COUNT(*) FROM #TestResultsAmendmentHistory)=0 
	INSERT INTO #TestResultsAmendmentHistory VALUES(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)


	SELECT  
	    ROW_NUMBER() OVER (ORDER BY ISNULL(M.strBarcode,M.strFieldBarcode) DESC) as idfRowID,
		T.idfTesting				AS idfTest,
		T.idfObservation			AS idfTestObservation,
		T.idfsTestName			AS idfsTestName,
		M.strFieldBarcode			AS strLocalSampleID,
		M.strBarcode				AS strLabSampleID,
		ST.[name]				AS strSampleType,
		D.[name]				AS strTestDiagnosis,
		TN.[name]				AS strTestName,
		BT.strBarcode			AS strTestRunID,
		T.datConcludedDate		AS datResultDate,
		dep.[name]					AS strFunctionalArea,
		TC.[name]			AS strTestCategory,
		TS.[name]				AS strTestStatus,
		TR.[name]				AS strTestResult,
		HC.strCaseID				AS strHumCaseId,
		CaseStatus.name				AS strHumCaseStatus,
		dbo.FN_GBL_ConcatFullName(H.strLastName, H.strFirstName, H.strSecondName) AS strHumPatient,
		pdiag.name					AS strHumDiagnosis,
		CC.[name]		AS strHumCaseClassification,
		VC.strCaseID				AS strVetCaseId,
		VCS.[name]			AS strVetCaseStatus,
		ISNULL(F.strNationalName, '') + CASE WHEN  ISNULL(F.strNationalName, '') <> '' AND ISNULL(fown.strLastName, '') <> '' 
												THEN ' / ' 
												ELSE '' END + ISNULL(dbo.FN_GBL_ConcatFullName(fown.strLastName, fown.strFirstName, fown.strSecondName), '') AS strVetFarmOwner,
		ISNULL(rfVetDiagnosis.name, '') + ISNULL(', ' + rfVetDiagnosis1.name, '') + ISNULL(', ' + rfVetDiagnosis2.name, '') + ISNULL(', ' + rfVetDiagnosis3.name, '') AS strVetDiagnoses,
		VetCaseClassification.name AS strVetCaseClassification,
		CASE WHEN T.blnExternalTest = 1 THEN office.name ELSE NULL END AS strExternalLaboratory,
		CASE WHEN T.blnExternalTest = 1 THEN ISNULL(P.strFamilyName + ' ', '') + ISNULL(P.strFirstName + ' ', '') + ISNULL(P.strSecondName, '') ELSE NULL END	AS strExternalEmployee,
		CASE WHEN T.blnExternalTest = 1 THEN TR.name ELSE NULL END	AS strExternalDataTestResultReceived
	INTO #LIM_CaseTest
	FROM dbo.tlbTesting AS T 
	INNER JOIN dbo.tlbMaterial AS M ON M.idfMaterial = T.idfMaterial AND M.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000019) D ON D.idfsReference = T.idfsDiagnosis	
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) ST ON ST.idfsReference = M.idfsSampleType
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000097 ) TN ON TN.idfsReference = T.idfsTestName
	LEFT JOIN dbo.tlbBatchTest BT ON T.idfBatchTest = BT.idfBatchTest
	LEFT JOIN dbo.FN_GBL_Department(@LangID) dep ON dep.idfDepartment = M.idfInDepartment
	LEFT JOIN dbo.FN_GBL_Institution(@LangID) office ON office.idfOffice = T.idfTestedByOffice
	LEFT JOIN dbo.tlbPerson P ON P.idfPerson = T.idfTestedByPerson
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000095) TC ON TC.idfsReference = T.idfsTestCategory
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000001) TS ON TS.idfsReference = T.idfsTestStatus
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000096 ) TR ON TR.idfsReference = T.idfsTestResult
	LEFT JOIN dbo.tlbHumanCase HC
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000111 ) CaseStatus ON CaseStatus.idfsReference = HC.idfsCaseProgressStatus
		LEFT JOIN dbo.tlbHuman H ON H.idfHuman = HC.idfHuman
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019 ) pdiag ON pdiag.idfsReference = ISNULL(HC.idfsFinalDiagnosis, HC.idfsTentativeDiagnosis)
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000011 ) CC ON CC.idfsReference = ISNULL(HC.idfsFinalCaseStatus, HC.idfsInitialCaseStatus)
		ON HC.idfHumanCase = M.idfHumanCase
	LEFT JOIN dbo.tlbVetCase VC
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000111 ) VCS ON VCS.idfsReference = VC.idfsCaseProgressStatus		
		LEFT JOIN dbo.tlbFarm F	ON F.idfFarm = VC.idfFarm
		LEFT JOIN dbo.tlbHuman fown ON fown.idfHuman = F.idfHuman
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfVetDiagnosis ON rfVetDiagnosis.idfsReference = VC.idfsTentativeDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfVetDiagnosis1 ON rfVetDiagnosis1.idfsReference = VC.idfsTentativeDiagnosis1
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfVetDiagnosis2 ON rfVetDiagnosis2.idfsReference = VC.idfsTentativeDiagnosis2
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS rfVetDiagnosis3 ON rfVetDiagnosis3.idfsReference = VC.idfsFinalDiagnosis					
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000011 ) VetCaseClassification ON VetCaseClassification.idfsReference = VC.idfsCaseClassification
		ON VC.idfVetCase = M.idfVetCase
	WHERE T.intRowStatus = 0	
	AND (M.idfHumanCase = @ObjID OR M.idfVetCase = @ObjID OR M.idfMonitoringSession = @ObjID)

	--Inserting dummy values if no records
	IF (SELECT COUNT(*) FROM #LIM_CaseTest)=0 
	INSERT INTO #LIM_CaseTest(idfRowID,idfTest,strVetFarmOwner,strVetDiagnoses) VALUES (1,1,'','')

	SELECT *  FROM #TestResultsAmendmentHistory,#LIM_CaseTest;