



-- ================================================================================================
-- Name: Added NULL Elevation parm to USP_REP_LimLabSampleReceive_GET
--
-- Description: Select data for Accession in report.
--          
-- Author: Mark Wilson
--
-- Revision History:
-- Name				Date		Change Detail
-- ---------------	----------	--------------------------------------------------------------------
-- Mark Wilson		01/14/2019	converted to E7 
 
/*
--Example of a call of procedure:

exec report.USP_REP_LimLabSampleReceive_GET @ObjID=47280000204,@LangID='en-US'

exec report.USP_REP_LimLabSampleReceive_GET @ObjID=30930,@LangID='ru-RU'

exec report.USP_REP_LimLabSampleReceive_GET @ObjID=88200000241,@LangID='ru-RU'



// empty
select top 100 * from tlbHumanCase hc
inner join tlbAntimicrobialTherapy ant
on hc.idfHumanCase = ant.idfHumanCase
inner join tlbMaterial m
on m.idfHumanCase = hc.idfHumanCase
inner join tlbTesting tt
on tt.idfMaterial = m.idfMaterial

WHERE hc.strSummaryNotes is not null


exec report.USP_REP_LimLabSampleReceive_GET @ObjID=67674,@LangID=N'ru'
exec report.USP_REP_LimLabSampleReceive_GET @ObjID=67674,@LangID='en'

*/

CREATE  PROCEDURE [Report].[USP_REP_LimLabSampleReceive_GET]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10) 
)
    
AS
	declare @strAnyAntibioticsAdministration nvarchar(max)

	select 
		@strAnyAntibioticsAdministration = isnull(@strAnyAntibioticsAdministration + ',', '') + at.strAntimicrobialTherapyName
	FROM dbo.tlbAntimicrobialTherapy at
	INNER JOIN dbo.tlbHumanCase thc ON thc.idfHumanCase = at.idfHumanCase AND thc.intRowStatus = 0
	WHERE at.idfHumanCase = @ObjID 
	AND at.intRowStatus = 0
	

	SELECT		
		COALESCE(hc.idfHumanCase, vc.idfVetCase, sess.idfMonitoringSession ) AS idfCase,
		COALESCE(hc.strCaseID, vc.strCaseID, sess.strMonitoringSessionID) AS CaseID,
		COALESCE(hc.datOnSetDate, vc.datInvestigationDate) 	AS DateOfSymptoms,
				-- TODO: implement 
				-----------------------
				
		@strAnyAntibioticsAdministration			AS	strAnyAntibioticsAdministration,
		hc.strSampleNotes							AS	strAdditionalTestRequested ,
		Material.strFieldBarcode					AS  LocalID,
		Material.strCondition						AS  Comment,
		-----------------------
		(
			SELECT COUNT(*) FROM dbo.tlbTesting tt
			WHERE tt.idfMaterial = Material.idfMaterial
			AND tt.intRowStatus = 0
		)		AS			intTests,
		CASE
			WHEN (hc.idfHumanCase IS NULL) AND (vc.idfVetCase IS NULL) THEN 2
			ELSE 
				CASE 
					WHEN (hc.idfHumanCase IS NOT NULL) THEN 1   ELSE 0	
				END
		END									AS intCaseType,
				
				
		dbo.FN_GBL_GeoLocationString(@LangID, tFarm.idfFarmAddress, NULL) AS FarmAddress,
		tFarm.strNationalName AS FarmName,
		dbo.FN_GBL_ConcatFullName(tFarmOwner.strLastName, tFarmOwner.strFirstName, tFarmOwner.strSecondName)	
											AS FarmOwner,
		dbo.FN_GBL_ConcatFullName(tHuman.strLastName, tHuman.strFirstName, tHuman.strSecondName)				
											AS PatientName,
		ISNULL(STR(hc.intPatientAge) + ' (' + rfAgeType.[name] + ')', '')	
											AS Age,
		(CASE 
			WHEN vc.idfVetCase IS NULL THEN HD.name
			ELSE ISNULL(VD.[name], vc.strDefaultDisplayDiagnosis)
		END)  AS DiagnosisInitial,  
		dbo.FN_GBL_ConcatFullName(@LangID, tHuman.idfCurrentResidenceAddress, NULL)	AS CurrentResidence,

		Material.strFieldBarcode			AS LocalSampleID,
		SpecimenType.name					AS SampleType,
		fnAnimal.AnimalName					AS AnimalID,
		fnAnimal.SpeciesName				AS Species,
		Material.datFieldCollectionDate		AS CollectionDate,
		Material.datFieldSentDate			AS DateSent,
		Material.strBarcode					AS LabSampleID,
		Material.datAccession				AS AccessionDate,
		sCondition.[name]					AS SampleCondition,
		fnRepository.[Path]					AS Location,
				
		fnDepartment.[name]					AS FunctionalArea,
		dbo.FN_GBL_ConcatFullName(tAccessionPerson.strFamilyName, tAccessionPerson.strFirstName, tAccessionPerson.strSecondName) 
											AS AccessionedBy,
		dbo.FN_GBL_ConcatFullName(tCollectedPerson.strFamilyName, tCollectedPerson.strFirstName, tCollectedPerson.strSecondName) 
											AS CollectedByPerson,
		tHuman.idfCurrentResidenceAddress	AS idfCurrentResidenceAddress,
		L.AdminLevel2Name					AS strASRegion,
		L.AdminLevel3Name					AS strASRayon,
		L.AdminLevel4Name					AS strASSettlement,
		(
			SELECT
				FD.[name] + '; '
			FROM dbo.tlbMonitoringSessionToDiagnosis tSTD
			INNER JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000019) FD ON tSTD.idfsDiagnosis = FD.idfsReference 		
			WHERE tSTD.idfMonitoringSession = @ObjID
			AND tSTD.intRowStatus = 0
			ORDER BY tSTD.intOrder	
			FOR XML PATH('')
		)									AS strDiagnosisList,
		camp.strCampaignID					AS strCampaignID,
		camp.strCampaignName				AS strCampaignName,
		fnCampaignType.[name]				AS strCampaignType
				
				
				
--get session				
FROM	 (dbo.tlbMonitoringSession	AS sess
		-- Get campaign
			LEFT JOIN dbo.tlbCampaign AS camp ON camp.idfCampaign = sess.idfCampaign 
			LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000116) fnCampaignType ON fnCampaignType.idfsReference = camp.idfsCampaignType
		-- Get session address
			INNER JOIN	dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) L ON L.idfsLocation = sess.idfsLocation
		)
-- get human case
FULL JOIN (
			dbo.tlbHumanCase AS hc
			-- Get Human Age Type 
			LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000042) rfAgeType ON hc.idfsHumanAgeType = rfAgeType.idfsReference
			-- Get patient
			INNER JOIN	dbo.tlbHuman AS tHuman ON hc.idfHuman = tHuman.idfHuman AND  tHuman.intRowStatus = 0
				
			-- Get Diagnosis
			LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS HD ON HD.idfsReference = ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)
		) ON	hc.idfHumanCase = sess.idfMonitoringSession
			
-- get vet case
FULL JOIN 
(
			dbo.tlbVetCase AS vc
			-- Get Farm		
			INNER JOIN	dbo.tlbFarm AS tFarm ON	vc.idfFarm = tFarm.idfFarm AND  tFarm.intRowStatus = 0
			LEFT JOIN dbo.tlbHuman AS tFarmOwner ON	tFarm.idfHuman = tFarmOwner.idfHuman
					
			-- Get Diagnosis
			LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS VD ON VD.idfsReference = vc.idfsShowDiagnosis
			LEFT JOIN dbo.tlbVetCaseDisplayDiagnosis VetDiagnosis ON vc.idfVetCase = VetDiagnosis.idfVetCase AND VetDiagnosis.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
) ON	vc.idfVetCase = sess.idfMonitoringSession


-- Get Accession, Container, Matererial
LEFT JOIN	(dbo.tlbMaterial AS Material
			LEFT JOIN Report.FN_GBL_AnimalList_GET(@LangID) fnAnimal ON	Material.idfAnimal = fnAnimal.idfParty
			LEFT JOIN dbo.tlbPerson AS tCollectedPerson ON tCollectedPerson.idfPerson = Material.idfFieldCollectedByPerson
			LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) SpecimenType ON SpecimenType.idfsReference = Material.idfsSampleType
			LEFT JOIN dbo.tlbPerson AS tAccessionPerson ON	tAccessionPerson.idfPerson = Material.idfAccesionByPerson
			LEFT JOIN dbo.FN_LAB_RepositorySchema (@LangID, NULL, NULL) AS fnRepository ON	Material.idfSubdivision = fnRepository.idfSubdivision								 
			LEFT JOIN dbo.FN_GBL_Department(@LangID) AS fnDepartment ON	fnDepartment.idfDepartment = Material.idfInDepartment
			LEFT JOIN dbo.tlbTransferOutMaterial tOut_M ON tOut_M.idfMaterial = Material.idfMaterial
			LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000110) sCondition ON sCondition.idfsReference = Material.idfsAccessionCondition

		)
		ON	
		Material.blnShowInAccessionInForm = 1 
		AND tOut_M.idfMaterial IS NULL -- doesn't include transferred materials
		AND ((Material.idfHumanCase = hc.idfHumanCase) OR (Material.idfVetCase = vc.idfVetCase) OR
			(Material.idfMonitoringSession = sess.idfMonitoringSession))
			AND Material.intRowStatus = 0

	
					
					

 WHERE	((hc.intRowStatus = 0  AND	hc.idfHumanCase = @ObjID) OR 
		(vc.intRowStatus = 0  AND	vc.idfVetCase = @ObjID)	OR 
		(sess.intRowStatus = 0  AND	sess.idfMonitoringSession = @ObjID))
			

