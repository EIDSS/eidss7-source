

-- ================================================================================================
-- Name: USP_REP_Lim_Sample_GET
--
-- Description:	Select data for Container details report.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		12132021	Initial Version, converted to E7 standards

/*
--Example of a call of procedure:

select top 10 * from tlbMaterial

exec report.[USP_REP_Lim_Sample_GET] 'en-US', 675020000816

*/


CREATE  PROCEDURE [Report].[USP_REP_Lim_Sample_GET]
    (
        @LangID AS NVARCHAR(10),
        @ObjID	AS BIGINT
    )
AS
	SELECT
				COALESCE	(HC.strCaseID,VC.strCaseID,
							MS.strMonitoringSessionID,
							VSS.strSessionID)		AS strCaseID,
				Material.datAccession				AS datAccessionDate,
				Material.datFieldCollectionDate		AS datCollectionDate,
				Material.strBarcode					AS strLabSampleID,
				SampleType.name						AS strSampleType,
				pm.strBarcode						AS strParentSampleID,
				Department.name						AS strFunctionalArea,
				RepSchema.[Path]						AS strStorageLocation,		
				CaseType.name  						AS strCaseType,
				ISNULL(HC.strCaseID, VC.strCaseID) + ', ' +
					(CASE 
						WHEN HC.idfHumanCase IS NULL THEN ISNULL(VetDiagnosis.strDisplayDiagnosis,   VC.strDefaultDisplayDiagnosis)    
						ELSE Diagnosis.name 
				 	END)							AS strCaseInfo,
				ISNULL(MS.strMonitoringSessionID, VSS.strSessionID)		AS strSessionID,
		
				(CASE 
						WHEN HC.idfHumanCase IS NOT NULL THEN 
								dbo.FN_GBL_ConcatFullName(H.strLastName, H.strFirstName,H.strSecondName)
						ELSE COALESCE (Animal.SpeciesName, SpeciesName.name, vt.[name] + ISNULL(N' ' + vst.[name], N'') + N', ' + V.strVectorID)
				 	END)	
				AS strPatientSpeciesVectorInfo,
				
				Material.strNote					AS strNotes,
				tlbCollectedByOffice.name			AS strCollectedByInstitution,
				dbo.FN_GBL_ConcatFullName(tlbCollectedByPerson.strFamilyName, tlbCollectedByPerson.strFirstName, tlbCollectedByPerson.strSecondName) AS strCollectedByOfficer,
				TransferFromInst.name				AS strReceivedFromInstitution,
				tout_from.strBarcode				AS strReceivedFromTransferID,
				originalMaterial.strBarcode			AS strReceivedFromLabSampleID,
				tout_from.datSendDate				AS datReceivedFromLabDateReceived,
				
				TransferToInst.name					AS strTransferredToInstitution,
				tout_to.strBarcode					AS strTransferredToTransferID,
				tranferToMaterial.strBarcode		AS strTransferredToLabSampleID,
				--tout_to.strBarcode					AS strTransferredToTransferID,
				tout_to.datSendDate					AS datTransferredToDate,
				
				TestName.name						AS strTestName,
				TestCategory.name					AS strTestCategory,
				TestDiagnosis.name					AS strTestDiagnosis,
				TestStatus.name						AS strTestStatus,
				TestResult.name						AS strTestResult,
				tbt.strBarcode						AS strTestRunID,
				T.datConcludedDate			AS datTestResultDate,
				T.datReceivedDate			AS datDateTestResultsReceived,
				T.strContactPerson			AS strTestContactPerson 
							

	FROM dbo.tlbMaterial AS Material
	LEFT JOIN dbo.tlbMaterial pm ON pm.idfMaterial = Material.idfParentMaterial AND pm.intRowStatus = 0
    LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) SampleType ON SampleType.idfsReference = Material.idfsSampleType
    LEFT JOIN dbo.tlbMonitoringSession MS ON MS.idfMonitoringSession = Material.idfMonitoringSession
    LEFT JOIN dbo.tlbVectorSurveillanceSession VSS ON VSS.idfVectorSurveillanceSession = Material.idfVectorSurveillanceSession

	LEFT JOIN dbo.tlbVector AS V 
		INNER JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000140) vt ON vt.idfsReference = V.idfsVectorType
		INNER JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000141) vst ON vst.idfsReference = V.idfsVectorSubType
		ON V.idfVector = Material.idfVector	AND V.intRowStatus = 0
			
    LEFT JOIN dbo.tlbHumanCase HC ON HC.idfHumanCase = Material.idfHumanCase
    LEFT JOIN dbo.tlbVetCase VC ON VC.idfVetCase = Material.idfVetCase
    LEFT JOIN dbo.FN_GBL_Department(@LangID) Department ON Department.idfDepartment = Material.idfInDepartment
    LEFT JOIN report.FN_SAMPLE_RepositorySchema_GET(@LangID, NULL, NULL) AS RepSchema ON RepSchema.idfSubdivision  = Material.idfSubdivision
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000012) CaseType ON CaseType.idfsReference = CASE WHEN HC.idfHumanCase IS NOT NULL THEN 10012001 ELSE VC.idfsCaseType END
	LEFT JOIN dbo.FN_GBL_Institution(@LangID) AS tlbCollectedByOffice ON tlbCollectedByOffice.idfOffice = Material.idfFieldCollectedByOffice
	LEFT JOIN dbo.tlbPerson AS tlbCollectedByPerson ON tlbCollectedByPerson.idfPerson = Material.idfFieldCollectedByPerson
	LEFT JOIN dbo.tlbVetCaseDisplayDiagnosis VetDiagnosis ON VC.idfVetCase = VetDiagnosis.idfVetCase AND VetDiagnosis.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)  
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019 ) Diagnosis ON COALESCE(HC.idfsFinalDiagnosis, HC.idfsTentativeDiagnosis, VC.idfsShowDiagnosis) = Diagnosis.idfsReference
	LEFT JOIN report.FN_GBL_AnimalList_GET(@LangID) Animal ON Material.idfAnimal = Animal.idfParty
	LEFT JOIN dbo.tlbSpecies S ON S.idfSpecies = Material.idfSpecies
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) SpeciesName ON SpeciesName.idfsReference = S.idfsSpeciesType
	LEFT JOIN dbo.tlbHuman H ON H.idfHuman = Animal.idfFarmOwner OR H.idfHuman = HC.idfHuman
	-- transfer from
	LEFT JOIN dbo.tlbMaterial originalMaterial
		INNER JOIN dbo.tlbTransferOutMaterial tout_m ON tout_m.idfMaterial = originalMaterial.idfMaterial			
		INNER JOIN dbo.tlbTransferOUT AS tout_from ON tout_from.idfTransferOut = tout_m.idfTransferOut AND tout_from.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Institution(@LangID) AS TransferFromInst ON TransferFromInst.idfOffice = tout_from.idfSendFromOffice
		ON originalMaterial.idfMaterial = Material.idfParentMaterial AND originalMaterial.intRowStatus = 0 AND Material.idfsSampleKind = 12675430000000 --TransferredIn
	
	--transfer to
	LEFT JOIN dbo.tlbTransferOutMaterial TOM
		INNER JOIN dbo.tlbTransferOUT tout_to ON TOM.idfTransferOut=tout_to.idfTransferOut AND tout_to.intRowStatus = 0 AND tout_to.idfsTransferStatus = 10001003
		INNER JOIN dbo.tlbMaterial tranferToMaterial ON tranferToMaterial.idfParentMaterial = TOM.idfMaterial AND tranferToMaterial.intRowStatus = 0
					AND tranferToMaterial.idfsSampleKind = 12675430000000 --TransferredIn
					AND tranferToMaterial.blnAccessioned = 1
		LEFT JOIN dbo.FN_GBL_Institution(@LangID) AS TransferToInst ON TransferToInst.idfOffice = tout_to.idfSendToOffice
		ON TOM.idfMaterial = Material.idfMaterial AND TOM.intRowStatus = 0
				
		

	LEFT JOIN dbo.tlbTesting T
		LEFT JOIN dbo.tlbBatchTest tbt ON tbt.idfBatchTest = T.idfBatchTest AND tbt.intRowStatus = 0
		INNER JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000097) TestName ON TestName.idfsReference = T.idfsTestName
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000096) TestResult ON TestResult.idfsReference = T.idfsTestResult
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000095) TestCategory ON TestCategory.idfsReference = T.idfsTestCategory
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) TestDiagnosis ON TestDiagnosis.idfsReference = T.idfsDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000001) TestStatus ON TestStatus.idfsReference = T.idfsTestStatus	
		ON T.idfMaterial = Material.idfMaterial AND T.intRowStatus = 0				
  
 WHERE	Material.idfMaterial = @ObjID
			

