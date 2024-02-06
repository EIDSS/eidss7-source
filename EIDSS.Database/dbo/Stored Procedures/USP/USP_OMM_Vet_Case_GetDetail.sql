


--*************************************************************
-- Name: [USP_OMM_Vet_Case_GetDetail]
-- Description: Insert/Update for Campaign Monitoring Session
--          
-- Author: Doug Albanese
-- Revision History
--	Name			Date		Change Detail
--  Doug Albanese	4/17/2020	Added fields to create Flex Forms
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_Vet_Case_GetDetail]
(    
	@LangID									nvarchar(50),
	@OutbreakCaseReportUID					BIGINT = -1
)
AS

BEGIN    

	DECLARE	@returnCode					INT = 0;
	DECLARE @returnMsg					NVARCHAR(MAX) = 'SUCCESS';

	DECLARE @idfVetCase					BIGINT
	DECLARE @idfFarm					BIGINT
	DECLARE @HerdsOrFlocks				NVARCHAR(MAX)
	DECLARE @Species					NVARCHAR(MAX)
	DECLARE @ClinicalInformation		NVARCHAR(MAX)
	DECLARE @AnimalsInvestigations		NVARCHAR(MAX)
	DECLARE @Contacts					NVARCHAR(MAX)
	DECLARE @Vaccinations				NVARCHAR(MAX)
	DECLARE @Samples					NVARCHAR(MAX)
	DECLARE @PensideTests				NVARCHAR(MAX)
	DECLARE @LabTests					NVARCHAR(MAX)
	DECLARE @TestInterpretations		NVARCHAR(MAX)
	DECLARE @CaseMonitorings			NVARCHAR(MAX)

	DECLARE @HerdIds TABLE
	(
		idfHerd							BIGINT
	)

	DECLARE @SpeciesIds TABLE
	(
		idfSpecies						BIGINT
	)

	BEGIN TRY

		--Get VetCase identification
		Set			@idfVetCase	= (Select idfVetCase
		FROM 			OutbreakCaseReport 
		WHERE			OutbreakCaseReportUID = @OutbreakCaseReportUID )

		--Get Farm identification
		SET			@idfFarm = (SELECT idfFarm
		FROM			tlbVetCase
		WHERE			idfVetCase = @idfVetCase)

		--Create a listing of Herd Id's associated with the case report
		INSERT INTO		@HerdIds
		SELECT			idfHerd
		FROM			tlbHerd
		WHERE			idfFarm = @idfFarm

		----Obtain listing of Herds for Json object
		SET @HerdsOrFlocks = 
		(SELECT			
						h.idfHerd,
						h.idfHerdActual,
						h.strHerdCode,
						h.intSickAnimalQty,
						h.intTotalAnimalQty,
						h.intDeadAnimalQty,
						h.strNote AS Comments,
						h.intRowStatus,
						'R' As RowAction
		FROM			tlbHerd h
		INNER JOIN		@HerdIds hs
		ON hs.idfherd = h.idfHerd
		WHERE
						h.intRowStatus = 0
		FOR JSON PATH)

		--Obtain listing of Species for Json Object
		SET @Species = 
		(SELECT			
						s.idfSpecies,
						s.idfSpeciesActual,
						s.idfsSpeciesType,
						s.idfHerd,
						s.intSickAnimalQty,
						s.intTotalAnimalQty,
						s.intDeadAnimalQty,
						s.datStartOfSignsDate,
						0 AS intAverageAge,
						s.idfObservation,
						s.strNote,
						s.intRowStatus,
						'R' As RowAction,
						h.idfHerdActual
			FROM			tlbSpecies s
			INNER JOIN		@HerdIds hs
			ON hs.idfherd = s.idfHerd
			INNER JOIN		tlbHerd h
			ON h.idfHerd = s.idfHerd
			WHERE
						s.intRowStatus = 0
		FOR JSON PATH)

		--Create a listing of Species Id's associated with the Herd listing
		INSERT INTO		@SpeciesIds
		SELECT			s.idfSpecies
		FROM			tlbSpecies s
		INNER JOIN		@HerdIds hs
		ON hs.idfherd = s.idfHerd

		--Obtain listing of Animals for Json Object
		SET @AnimalsInvestigations = 
		(SELECT			
				a.idfAnimal,
				a.idfsAnimalGender,
				a.idfsAnimalCondition,
				a.idfsAnimalAge,
				s.idfsSpeciesType,
				a.idfSpecies,
				a.idfObservation,
				a.strAnimalCode,
				a.strName,
				a.strColor,
				AC.name						AS [Status],
				a.strDescription,
				a.intRowStatus,
				'R'							AS RowAction,
				a.idfAnimal					AS idfsClinical,
				s.idfHerd,
				h.strHerdCode,
				ST.name						AS Species,
				AG.name						AS Age,
				SX.name						AS Sex
			FROM			OutbreakCaseReport OCR
			INNER JOIN		tlbVetCase VC
			ON				VC.idfVetCase = OCR.idfVetCase
			INNER JOIN		tlbHerd H
			ON				H.idfFarm = VC.idfFarm
			INNER JOIN		tlbSpecies S
			ON				S.idfHerd = H.idfHerd
			INNER JOIN		tlbAnimal A
			ON				A.idfSpecies = S.idfSpecies
			INNER JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000005) AG
			ON				AG.idfsReference = a.idfsAnimalAge
			INNER JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000006) AC
			ON				AC.idfsReference = a.idfsAnimalCondition
			INNER JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000086) ST
			ON				ST.idfsReference = s.idfsSpeciesType
			INNER JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000007) SX
			ON				SX.idfsReference = a.idfsAnimalGender
			WHERE			OCR.OutbreakCaseReportUID = @OutbreakCaseReportUID AND
							OCR.intRowStatus = 0 AND
							A.intRowStatus = 0
		FOR JSON PATH)

		--Obtain listing of Contacts for Json Object
		DECLARE @ContactTypeID AS BIGINT = -1

		SELECT 
			@ContactTypeID = ContactTypeID
		FROM
			OutbreakCaseContact
		WHERE 
			OutbreakCaseReportUID = @OutbreakCaseReportUID

		SET @Contacts = 
			(SELECT
								occ.OutbreakCaseContactUID,
								h.idfHumanActual,
								h.strFirstName + ' ' + h.strLastName	AS ContactName,
								occ.ContactRelationshipTypeID			AS idfsPersonContactType,
								CR.name									AS Relation,
								occ.DateOfLastContact					AS datDateOfLastContact,
								occ.PlaceOfLastContact					AS strPlaceInfo,
								occ.ContactStatusID,
								CS.name									AS ContactStatus,
								occ.CommentText							AS strComments,
								occ.ContactTypeID,
								CT.name									AS ContactType,
								occ.intRowStatus,
								occ.ContactTracingObservationID			AS idfObservation,
								ft.idfsFormType

			FROM				OutbreakCaseContact occ
			LEFT JOIN			tlbHuman h
			ON					h.idfHuman = occ.idfHuman
			LEFT JOIN			dbo.FN_GBL_Reference_GETList(@LangID, 19000014) CR
			ON					CR.idfsReference = occ.ContactRelationshipTypeID
			LEFT JOIN			dbo.FN_GBL_Reference_GETList(@LangID, 19000516) CT
			ON					CT.idfsReference = occ.ContactTypeID
			LEFT JOIN			dbo.FN_GBL_Reference_GETList(@LangID, 19000517) CS
			ON					CS.idfsReference = occ.ContactStatusID
			LEFT JOIN			tlbObservation o
			ON					o.idfObservation = occ.ContactTracingObservationID
			LEFT JOIN			ffFormTemplate ft
			ON					ft.idfsFormTemplate = o.idfsFormTemplate
			WHERE				occ.OutbreakCaseReportUID = @OutbreakCaseReportUID AND
								occ.intRowStatus = 0

			FOR JSON PATH)
			

		SET @Vaccinations = 
		(SELECT
							V.idfVaccination,
							V.idfVetCase,
							V.idfSpecies,
							S.idfsSpeciesType,
							V.idfsVaccinationType,
							V.idfsVaccinationRoute,
							V.idfsDiagnosis,
							V.datVaccinationDate,
							V.strManufacturer,
							V.strLotNumber,
							V.intNumberVaccinated,
							V.strNote,
							V.intRowStatus,
							'R' AS RowAction,
							VT.strDefault AS Name,
							ST.strDefault AS Species,
							ST.strDefault AS VaccinationType,
							VR.strDefault AS Route
					FROM			
							OutbreakCaseReport OCR
					LEFT JOIN		tlbVetCase VC
					ON				VC.idfVetCase = OCR.idfVetCase
					LEFT JOIN		tlbVaccination V
					ON				V.idfVetCase = VC.idfVetCase
					LEFT JOIN		tlbHerd H
					ON				H.idfFarm = VC.idfFarm
					LEFT JOIN		tlbSpecies S
					ON				S.idfHerd = H.idfHerd
					LEFT JOIN		tlbAnimal A
					ON				A.idfSpecies = S.idfSpecies
					LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000086) ST
					ON				ST.idfsReference = S.idfsSpeciesType
					LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000098) VR
					ON				VR.idfsReference = V.idfsVaccinationRoute
					LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000099) VT
					ON				VT.idfsReference = v.idfsVaccinationType
					WHERE			OCR.OutbreakCaseReportUID = @OutbreakCaseReportUID AND
									OCR.intRowStatus = 0 AND
									V.intRowStatus = 0
		FOR JSON PATH)

		--Obtain listing of SAmples for Json Object
		SET @Samples = 
		(SELECT
									m.idfMaterial,
									m.idfsSampleType,
									R.Name AS SampleType,
									m.strFieldBarcode,
									m.idfAnimal,
									a.strAnimalCode As Animal,
									m.idfSpecies,
									sr.Name As Species,
									m.idfsBirdStatus,
									bsr.Name AS BirdStatus,
									m.datFieldCollectionDate,
									m.idfFieldCollectedByOffice,
									fcboName.strDefault As FieldCollectedByOffice,
									m.idfFieldCollectedByPerson,
									Coalesce(prb.strFirstName + ' ' + prb.strFamilyName, '') As FieldColectedByPerson,
									m.idfSendToOffice,
									stoName.strDefault As SendToOffice,
									m.strNote,
									m.strBarcode

		FROM
									OutbreakCaseReport ocr
		LEFT JOIN					tlbVetCase vc
		ON							vc.idfVetCase = ocr.idfVetCase
		LEFT JOIN					tlbMaterial m
		ON							m.idfVetCase = vc.idfVetCase
		LEFT JOIN					tlbAnimal a
		ON							a.idfAnimal = m.idfAnimal
		LEFT JOIN					tlbOffice fcbo
		ON							fcbo.idfOffice = m.idfFieldCollectedByOffice
		LEFT JOIN					tlbPerson prb
		ON							prb.idfPerson = m.idfFieldCollectedByPerson
		LEFT JOIN					tlbOffice sto
		ON							sto.idfOffice = m.idfSendToOffice
		LEFT JOIN					tlbSpecies s
		ON							s.idfSpecies = m.idfSpecies
		LEFT JOIN					dbo.FN_GBL_Reference_GETList(@LangId, 19000006) bsr
		ON							bsr.idfsReference = m.idfsBirdStatus
		LEFT JOIN					dbo.FN_GBL_Reference_GETList(@LangId, 19000086) sr
		ON							sr.idfsReference = s.idfsSpeciesType
		LEFT JOIN					dbo.FN_GBL_Reference_GETList(@LangId, 19000087) R
		ON							R.idfsReference = m.idfsSampleType
		LEFT JOIN					trtBaseReference fcboName
		ON							fcboName.idfsBaseReference = fcbo.idfsOfficeName
		LEFT JOIN					trtBaseReference stoName
		ON							stoName.idfsBaseReference = sto.idfsOfficeName
		WHERE
									ocr.OutBreakCaseReportUID = @OutbreakCaseReportUID AND
									ocr.intRowStatus = 0 AND
									m.intRowStatus = 0
		FOR JSON PATH)

		SET @PensideTests = 
		(SELECT 
					DISTINCT
					pt.idfPensideTest,
					m.strFieldBarcode,
					pt.idfMaterial,
					m.idfsSampleType,
					ST.name AS SampleType,
					s.idfSpecies,
					'' AS Species,
					A.strAnimalCode AS Animal,
					m.idfAnimal,
					pt.idfsPensideTestName,
					TN.name AS TestName,
					pt.idfsPensideTestResult,
					TR.name AS Result,
					pt.intRowStatus,
					'R' AS RowAction
			FROM
					OutbreakCaseReport ocr
			LEFT JOIN		tlbVetCase vc
			ON				vc.idfVetCase = ocr.idfVetCase
			LEFT JOIN		tlbMaterial m
			ON				m.idfVetCase = vc.idfVetCase
			LEFT JOIN		tlbPensideTest pt
			ON				pt.idfMaterial = m.idfMaterial
			LEFT JOIN		tlbSpecies S
			ON				s.idfSpecies = m.idfSpecies
			LEFT JOIN		tlbAnimal A
			ON				A.idfSpecies = S.idfSpecies
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000086) ST
			ON				ST.idfsReference = s.idfsSpeciesType
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000104) TN
			ON				TN.idfsReference = pt.idfsPensideTestName
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000105) TR
			ON				TR.idfsReference = pt.idfsPensideTestResult
			WHERE
							ocr.OutBreakCaseReportUID = @OutbreakCaseReportUID AND
							pt.intRowStatus = 0
		FOR JSON PATH)

		SET @LabTests = 
		(SELECT
					DISTINCT
					T.idfTesting,
					T.idfMaterial,
					idfsSampleType,
					MT.name AS SampleType,
					M.strBarCode,
					M.strFieldBarcode,
					A.idfAnimal,
					ST.name AS Animal,
					S.idfsSpeciesType,
					S.idfSpecies,
					ST.name AS Species,
					T.idfsDiagnosis,
					TD.name AS TestDisease,
					T.idfsTestName,
					TN.name AS TestName,
					T.idfsTestCategory,
					TC.name AS TestCategory,
					T.idfsTestStatus,
					TS.name AS TestStatus,
					T.datConcludedDate,
					T.idfsTestResult,
					TR.name AS ResultObservation,
					T.intRowStatus,
					'R' AS RowAction
			FROM
					OutbreakCaseReport OCR
			LEFT JOIN		tlbVetCase vc
			ON				vc.idfVetCase = ocr.idfVetCase
			LEFT JOIN		tlbMaterial m
			ON				m.idfVetCase = vc.idfVetCase
			LEFT JOIN		tlbPensideTest pt
			ON				pt.idfMaterial = m.idfMaterial
			LEFT JOIN		tlbSpecies S
			ON				s.idfSpecies = m.idfSpecies
			LEFT JOIN		tlbAnimal A
			ON				A.idfSpecies = S.idfSpecies
			LEFT JOIN		tlbTesting T
			ON				T.idfMaterial = m.idfMaterial
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000097) TN
			ON				TN.idfsReference = T.idfsTestName
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000095) TC
			ON				TC.idfsReference = T.idfsTestCategory
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000001) TS
			ON				TS.idfsReference = T.idfsTestStatus
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000096) TR
			ON				TR.idfsReference = T.idfsTestResult
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000019) TD
			ON				TD.idfsReference = T.idfsDiagnosis
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000086) ST
			ON				ST.idfsReference = S.idfsSpeciesType
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000087) MT
			ON				MT.idfsReference = M.idfsSampleType
			WHERE
							OCR.OutbreakCaseReportUID = @OutbreakCaseReportUID AND
							T.intRowStatus = 0
		FOR JSON PATH)
		
		SET @TestInterpretations = (
			SELECT
							tv.idfTestValidation,
							tv.idfTesting,
							m.idfAnimal,
							ST.name AS Animal,
							tv.idfsDiagnosis,
							TD.name AS TestDisease,
							m.idfSpecies,
							ST.name AS Species,
							t.idfsTestName,
							TN.name AS TestName,
							t.idfsTestCategory,
							TC.name AS TestCategory,
							m.strBarCode,
							m.idfsSampleType,
							MT.name AS SampleType,
							m.strFieldBarcode,
							tv.idfsInterpretedStatus,
							'' AS InterpretedStatus,
							tv.strInterpretedComment,
							tv.strInterpretedComment AS CommentsValidatedYN,
							tv.datInterpretationDate,
							tv.idfInterpretedByOffice,
							'' AS InterpretedByOffice,
							tv.idfInterpretedByPerson,
							'' As InterpretedByPerson,
							tv.blnValidateStatus,
							tv.strValidateComment,
							'' AS ValidatedStatus,
							tv.datValidationDate,
							tv.idfValidatedByOffice,
							'' AS ValidatedByOffice, 
							tv.idfValidatedByPerson,
							'' AS ValidatedByPerson,
							'R' AS RowAction,
							0 AS intRowStatus
			FROM
							OutbreakCaseReport OCR
			LEFT JOIN		tlbVetCase vc
			ON				vc.idfVetCase = ocr.idfVetCase
			LEFT JOIN		tlbMaterial m
			ON				m.idfVetCase = vc.idfVetCase
			LEFT JOIN		tlbTesting t
			ON				t.idfMaterial = m.idfMaterial
			LEFT JOIN		tlbTestValidation tv
			ON				tv.idfTesting = t.idfTesting
			LEFT JOIN		tlbSpecies s
			ON				s.idfSpecies = m.idfSpecies
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000087) MT
			ON				MT.idfsReference = M.idfsSampleType
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000095) TC
			ON				TC.idfsReference = T.idfsTestCategory
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000097) TN
			ON				TN.idfsReference = T.idfsTestName
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000086) ST
			ON				ST.idfsReference = S.idfsSpeciesType
			LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangId, 19000019) TD
			ON				TD.idfsReference = T.idfsDiagnosis
			WHERE
							OCR.OutbreakCaseReportUID = @OutbreakCaseReportUID AND
							tv.intRowStatus = 0
		FOR JSON PATH)

		SET @CaseMonitorings = 
			(SELECT 
								ocm.idfOutbreakCaseMonitoring,
								ocm.idfObservation,
								ocm.datMonitoringdate,
								ocm.idfInvestigatedByOffice,
								CO.name AS InvestigatedByOffice,
								ocm.idfInvestigatedByPerson,
								CONCAT(P.strFirstName, ' ', P.strFamilyName) AS InvestigatedByPerson,
								ocm.strAdditionalComments,
								ocm.intRowStatus,
								ft.idfsFormType
				FROM
								tlbOutbreakCaseMonitoring ocm
				LEFT JOIN		trtBaseReference fcboName
				ON				fcboName.idfsBaseReference = ocm.idfInvestigatedByOffice
				LEFT JOIN		trtBaseReference stoName
				ON				stoName.idfsBaseReference = ocm.idfInvestigatedByPerson
				LEFT JOIN		tlbObservation o
				ON				o.idfObservation = ocm.idfObservation
				LEFT JOIN		ffFormTemplate ft
				ON				ft.idfsFormTemplate = o.idfsFormTemplate
				LEFT JOIN		tlbOffice o2
				ON				o2.idfOffice = ocm.idfInvestigatedByOffice
				LEFT JOIN		dbo.FN_GBL_Reference_GETList(@LangID, 19000046) CO
				ON				CO.idfsReference = o2.idfsOfficeName
				LEFT JOIN		tlbPerson P
				ON				P.idfPerson = ocm.idfInvestigatedByPerson
				WHERE
								idfVetCase = @idfVetCase AND
								ocm.intRowStatus = 0
			FOR JSON PATH)

SELECT(
		SELECT
			--General
			vc.idfFarm,
			f.idfFarmActual,
			fa.strFarmCode,
			--Notification
			vc.datReportDate								AS datVetNotificationDate,
			vc.idfReportedByOffice							AS idfVetNotificationSentByFacilty,
			vc.idfPersonReportedBy							AS idfVetNotificationSentByName,
			vc.idfReceivedByOffice							AS idfVetNotificationReceivedByFacilty,
			vc.idfReceivedByPerson							AS idfVetNotificationReceivedByName,
			rbo.strOrganizationID							AS strVetNotificationSentByFacilty,
			prb.strFirstName + ' ' + prb.strFamilyName		AS strVetNotificationSentByName,
			rbo2.strOrganizationID							AS strVetNotificationReceivedByFacilty,
			prb2.strFirstName + ' ' + prb2.strFamilyName	AS strVetNotificationReceivedByName,
			--Location
			COALESCE(geo.idfsCountry, '')					AS idfsCountry,
			COALESCE(geo.idfsRegion, '')					AS idfsRegion,
			COALESCE(geo.idfsRayon, '')						AS idfsRayon,
			COALESCE(geo.idfsSettlement, '')				AS idfsSettlement,
			geo.strStreetName,
			geo.strPostCode, 
			geo.strBuilding,
			geo.strHouse,		   
			geo.strApartment,
			geo.dblLongitude,
			geo.dblLatitude,
			--Species Information
			@HerdsOrFlocks									AS HerdsOrFlocks,
			@Species										AS Species,
			idfsCaseType,
			--Clinical Information
			--Vaccination Informationr
			@Vaccinations									AS Vaccinations,
			--Outbreak Investigation
			vc.datInvestigationDate,
			vc.idfInvestigatedByOffice,
			vc.idfPersonInvestigatedBy,
			ibo.strOrganizationID							AS strVetInvestigatorOrganization,
			pib.strFirstName + ' ' + prb2.strFamilyName		AS strInvestigatorName,
			OCR.IsPrimaryCaseFlag							AS VetPrimaryCase,
			OCR.OutbreakCaseStatusID						AS idfVetCaseStatus,
			OCR.OutbreakCaseClassificationID				AS idfVetCaseClassification,
			--Case Monitoring
			@AnimalsInvestigations							AS AnimalsInvestigations,
			--Contats
			@Contacts										AS Contacts,
			--Samples
			@Samples										AS Samples,
			--Penside Test
			@PensideTests									AS PensideTests,
			--Lab Test & INterpretation
			@LabTests										AS LabTests,
			@TestInterpretations							AS TestInterpretations,
			--Outbreak Flex Forms
			OCR.OutbreakCaseObservationID,
			OCOFT.idfsFormType								AS OutbreakCaseObservationFormType,
			OCR.CaseEPIObservationID,
			OCMFT.idfsFormType								AS CaseMonitoringObservationFormType,
			@CaseMonitorings								AS CaseMonitorings
		FROM
			OutbreakCaseReport OCR
		LEFT JOIN											tlbVetCase vc
		ON													vc.idfVetCase = OCR.idfVetCase
		LEFT JOIN											tlbOffice rbo
		ON													rbo.idfOffice = vc.idfReportedByOffice
		LEFT JOIN											tlbPerson prb
		ON													prb.idfPerson = vc.idfPersonReportedBy
		LEFT JOIN											tlbOffice rbo2
		ON													rbo2.idfOffice = vc.idfReceivedByOffice
		LEFT JOIN											tlbPerson prb2
		ON													prb2.idfPerson = vc.idfReceivedByPerson
		LEFT JOIN											tlbOffice ibo
		ON													ibo.idfOffice = vc.idfInvestigatedByOffice
		LEFT JOIN											tlbPerson pib
		ON													pib.idfPerson = vc.idfPersonInvestigatedBy
		LEFT JOIN											tlbFarm f
		ON													vc.idfFarm = f.idfFarm
		LEFT JOIN											tlbFarmActual fa
		ON													fa.idfFarmActual = f.idfFarmActual
		LEFT JOIN											dbo.tlbGeoLocationShared geo 
		ON													fa.idfFarmAddress = geo.idfGeoLocationShared
		LEFT JOIN											FN_GBL_GIS_REFERENCE(@LangID, 19000002) Rayon
		ON													Rayon.idfsReference = geo.idfsRayon
		LEFT JOIN											FN_GBL_GIS_REFERENCE(@LangID,19000003) Region
		ON													Region.idfsReference = geo.idfsRegion
		LEFT JOIN											dbo.FN_GBL_GIS_REFERENCE(@LangID,19000004) Settlement
		ON													Settlement.idfsReference = geo.idfsSettlement
		LEFT JOIN											tlbObservation OCO
		ON													OCO.idfObservation = OCR.OutbreakCaseObservationID
		LEFT JOIN											tlbObservation CMO
		ON													CMO.idfObservation = OCR.CaseEPIObservationID
		LEFT JOIN											ffFormTemplate OCOFT
		ON													OCOFT.idfsFormTemplate = OCO.idfsFormTemplate
		LEFT JOIN											ffFormTemplate OCMFT
		ON													OCMFT.idfsFormTemplate = CMO.idfsFormTemplate
		WHERE
			OCR.OutBreakCaseReportUID = @OutbreakCaseReportUID AND
			OCR.intRowStatus = 0 
		 FOR JSON Path ,  Root('OmmVetCaseGetDetailModel')  
		 ) as Results
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		throw;
	END CATCH

END
