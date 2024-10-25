--*************************************************************************
-- Name 				: report.USP_REP_LAB_Journal60B
-- Description			: Select data for 60B Journal.
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date		Change Detail
--		Srini Goli		02/06/2023	Updated based on 6.0 Base
--      Steven Verner   03/10/2023  Removed INNER JOIN on tentative diagnosis join.  Apparently there's no longer a concept of tentative diagnosis
--                                  This was causing the query to exclude all new EIDSS7 disease reports and outbreaks.

-- Testing code:
/*
 EXEC report.USP_REP_LAB_Journal60B 'ka', '20150101', '20151231', 9844050000000, 1101
 
 EXEC report.USP_REP_LAB_Journal60B 'en-US', '20150101', '20151231', 9844050000000, 1101

 EXEC report.USP_REP_LAB_Journal60B 'en-US', '20150101', '20150630', NULL,NULL

 EXEC report.USP_REP_LAB_Journal60B 'en-US', '20230101', '20230201', NULL,NULL
 */
  --*************************************************************************
 
 CREATE   Procedure [Report].[USP_REP_LAB_Journal60B]
 	(
 		@LangID		AS NVARCHAR(10), 
 		@StartDate	AS DATETIME,	 
 		@FinishDate	AS DATETIME,
 		@Diagnosis	AS BIGINT	=NULL,		-- filter value ofa drop-down list of all diseases accounted in EIDSS as case-based diseases with HA Code �Human� or �Human, Livestock� or �Human, Avian� or �Human, Avian, Livestock� (non-mandatory field).
 		@SiteID		AS BIGINT = NULL
 	)
 AS	
 
 -- Field description may be found here
 -- "https://repos.btrp.net/BTRP/Project_Documents/08x-Implementation/Customizations/GG/Reports/Specification for report development - 60B Journal Human GG v1.0.doc"
 -- by number marked red at screen form prototype 
 
 DECLARE	@ReportTable 	TABLE
 (	
 	strName						NVARCHAR(2000), --2	
	LegacyCaseID				NVARCHAR(100),
	intRow						NVARCHAR(100),
 	strAge						NVARCHAR(2000), --3
 	strGender					NVARCHAR(2000), --4
 	strAddress					NVARCHAR(2000), --5
 	strPlaceOfStudyWork			NVARCHAR(2000), --6
 	datDiseaseOnsetDate			DATETIME, --7
 	datDateOfFirstPresentation		DATETIME, --8
 	strFacilityThatSentNotification NVARCHAR(2000), --9
 	strProvisionalDiagnosis			NVARCHAR(2000), --10
 	datDateProvisionalDiagnosis		DATETIME, --11
 	datDateSpecificTreatment		DATETIME, --12
 	datDateSpecimenTaken			NVARCHAR(MAX), --13
 	strResultAndDate			NVARCHAR(MAX), --14
 	strVaccinationStatus		NVARCHAR(2000), --15
 	datDateCaseInvestigation	DATETIME, --16
 	strFinalDS					NVARCHAR(2000), --17
 	strFinalClassification		NVARCHAR(2000), --18
 	datDateFinalDS				DATETIME, --19
 	strOutcome					NVARCHAR(2000), --20
 	strCaseStatus				NVARCHAR(2000), --24
 	strComments					NVARCHAR(MAX), --25
 	strCaseID					NVARCHAR(200),
 	-- todo: fill this new field:
 	datEnteredDate				DATETIME  -- for sorting in EIDSS
 )	
 
 DECLARE	@OutbreakID	NVARCHAR(300)
 SELECT	@OutbreakID = ISNULL(RTRIM(r.[name]) + N' ', N'')
 FROM	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) r	-- Additional report Text
 WHERE	r.strDefault = N'Outbreak ID'
 PRINT @OutbreakID
 
 DECLARE	@CurrentResidence	NVARCHAR(300)
 SELECT	@CurrentResidence = ISNULL(RTRIM(r.[name]) + N' ' , N'') 
 FROM	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) r	-- Additional report Text
 WHERE	r.strDefault = N'Current Residence:'
 
 DECLARE	@PermanentResidence	NVARCHAR(300)
 SELECT	@PermanentResidence = ISNULL(RTRIM(r.[name]) + N' ' , N'') 
 FROM	dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) r	-- Additional report Text
 WHERE	r.strDefault = N'Permanent Residence:'
 
 DECLARE 
	 @OPV5field BIGINT
	,@OPV4field BIGINT
	,@OPV3field BIGINT
	,@OPV2field BIGINT
	,@OPV1field BIGINT
	,@Thirdfield BIGINT
	,@Secondfield BIGINT
	,@Firstfield BIGINT 
	,@NumberOfImmunizationsReceived BIGINT
	,@ArePatientsImmunizationRecordsAvailable BIGINT
	,@WasSpecificVaccinationAdministered BIGINT
	,@VaccinatedAgainstRubella BIGINT
	,@NumberOfReceivedDoses_WithDiphtheriaComponent BIGINT
	,@RabiesVaccineGiven BIGINT
	,@NumberOfReceivedDoses_WithMeaslesComponent BIGINT
	,@HibVaccinationStatus BIGINT
	,@NumberOfReceivedDoses_WithMumpsComponent BIGINT
	,@MothersTetanusToxoidHistoryPriorToChildsDisease BIGINT
	,@NumberOfReceivedDoses_WithPertussisComponent BIGINT
	,@NumberOfReceivedDoses_WithRubellaComponent BIGINT
	,@IncludeDosesOfALLTetanusContainingToxoids BIGINT
	,@WasVaccinationAdministered BIGINT
	,@Revaccination BIGINT
	,@DateOfVaccination BIGINT
	,@DateOfRevaccination BIGINT
	,@ImmunizationHistory_DateOfLastVaccination BIGINT
	,@SpecificVaccination_DateOfLastVaccination BIGINT
	,@IfYes_IndicateDatesOfDoses BIGINT
	,@IfYes_NumberOfVaccinesReceived BIGINT
	,@IntervalSinceLastTetanusToxoidDose BIGINT
	,@DateOfLastOPVDoseReceived BIGINT
	,@NameVaccine BIGINT
	
	--NEW!!!
	--Is patient vaccinated against leptospirosis?
	,@IsPatientVaccinatedAgainstLeptospirosis BIGINT
	
	--Date of vaccination of patient against leptospirosis
	,@DateOfVaccinationOfPatientAgainstLeptospirosis BIGINT


	--NEW!!! 22.06.2016
	--Rabies vaccine dose
	,@RabiesVaccineDose BIGINT
	
	--Rabies vaccination date
	,@RabiesVaccinationDate BIGINT

	--HEI S. pneumonae caused infection GG: S. pneumonae vaccination status
	,@PneumonaeVaccinationStatus BIGINT
	
	--HEI S. pneumonae caused infection GG: Number of received doses of S. pneumonae vaccine
	,@PneumonaeNumberReceivedDoses BIGINT
	
	--HEI S. pneumonae caused infection GG: Date of last vaccination
	,@PneumonaeDateLastVaccination BIGINT
	
	--HEI Acute Viral Hepatitis A GG: Number of received doses of Hepatitis A vaccine
	,@HepatitisANumberReceivedDoses BIGINT
	
	--HEI Acute Viral Hepatitis A GG: Date of last vaccination
	,@HepatitisADateLastVaccination BIGINT


	,@Section_AdditionalOPVdoses BIGINT
	,@Section_Maternalhistory BIGINT

	,@PVT_Immunization3 BIGINT
	,@PVT_Immunization5 BIGINT
	,@PVT_VaccineTypes BIGINT
	,@PVT_OPVDoses BIGINT
	,@PVT_Y_N_Unk BIGINT
     
     
	,@ft_HEI_Acute_viral_hepatitis_B_GG BIGINT
	,@ft_HEI_AFP_Acute_poliomyelitis_GG BIGINT
	,@ft_HEI_Anthrax_GG BIGINT
	,@ft_HEI_Botulism_GG BIGINT
	,@ft_HEI_Brucellosis_GG BIGINT
	,@ft_HEI_CRS_GG BIGINT
	,@ft_HEI_Congenital_Syphilis_GG BIGINT
	,@ft_HEI_CCHF_GG BIGINT
	,@ft_HEI_Diphtheria_GG BIGINT
	,@ft_HEI_Gonococcal_Infection_GG BIGINT
	,@ft_HEI_Bacterial_Meningitis_GG BIGINT
	,@ft_HEI_HFRS_GG BIGINT
	,@ft_HEI_Influenza_Virus_GG BIGINT
	,@ft_HEI_Measles_GG BIGINT
	,@ft_HEI_Mumps_GG BIGINT
	,@ft_HEI_Pertussis_GG BIGINT
	,@ft_HEI_Plague_GG BIGINT
	,@ft_HEI_Post_vaccination_unusual_reactions_and_complications_GG BIGINT
	,@ft_HEI_Rabies_GG BIGINT
	,@ft_HEI_Rubella_GG BIGINT
	,@ft_HEI_Smallpox_GG BIGINT
	,@ft_HEI_Syphilis_GG BIGINT
	,@ft_HEI_Tetanus_GG BIGINT
	,@ft_HEI_TBE_GG BIGINT
	,@ft_HEI_Tularemia_GG BIGINT
	,@ft_UNI_HEI_GG BIGINT
	--NEW!!!
	,@ft_HEI_Leptospirosis_GG BIGINT
	--NEW!!! 22.06.2016
	,@ft_HEI_Pneumonae_GG BIGINT
	,@ft_HEI_Acute_Viral_Hepatitis_A_GG BIGINT

    
	,@DG_MotherTtetanusToxoidHistoryPriorToChildDisease BIGINT

	,@idfsCustomReportType BIGINT
 
 
SET @idfsCustomReportType = 10290013 --GG 60B Journal


SELECT @OPV5field = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'OPV5field'
AND intRowStatus = 0

SELECT @OPV4field = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'OPV4field'
AND intRowStatus = 0

SELECT @OPV3field = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'OPV3field'
AND intRowStatus = 0

SELECT @OPV2field = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'OPV2field'
AND intRowStatus = 0

SELECT @OPV1field = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'OPV1field'
AND intRowStatus = 0

SELECT @Thirdfield = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'Thirdfield'
AND intRowStatus = 0

SELECT @Secondfield = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'Secondfield'
AND intRowStatus = 0

SELECT @Firstfield = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'Firstfield'
AND intRowStatus = 0

SELECT @NumberOfImmunizationsReceived = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NumberOfImmunizationsReceived'
AND intRowStatus = 0

SELECT @ArePatientsImmunizationRecordsAvailable = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ArePatientsImmunizationRecordsAvailable'
AND intRowStatus = 0

SELECT @WasSpecificVaccinationAdministered = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'WasSpecificVaccinationAdministered'
AND intRowStatus = 0

SELECT @VaccinatedAgainstRubella = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'VaccinatedAgainstRubella'
AND intRowStatus = 0

SELECT @NumberOfReceivedDoses_WithDiphtheriaComponent = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NumberOfReceivedDoses_WithDiphtheriaComponent'
AND intRowStatus = 0

SELECT @RabiesVaccineGiven = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'RabiesVaccineGiven'
AND intRowStatus = 0

SELECT @NumberOfReceivedDoses_WithMeaslesComponent = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NumberOfReceivedDoses_WithMeaslesComponent'
AND intRowStatus = 0

SELECT @HibVaccinationStatus = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'HibVaccinationStatus'
AND intRowStatus = 0

SELECT @NumberOfReceivedDoses_WithMumpsComponent = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NumberOfReceivedDoses_WithMumpsComponent'
AND intRowStatus = 0

SELECT @MothersTetanusToxoidHistoryPriorToChildsDisease = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'MothersTetanusToxoidHistoryPriorToChildsDisease'
AND intRowStatus = 0

SELECT @NumberOfReceivedDoses_WithPertussisComponent = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NumberOfReceivedDoses_WithPertussisComponent'
AND intRowStatus = 0

SELECT @NumberOfReceivedDoses_WithRubellaComponent = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NumberOfReceivedDoses_WithRubellaComponent'
AND intRowStatus = 0

SELECT @IncludeDosesOfALLTetanusContainingToxoids = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'IncludeDosesOfALLTetanusContainingToxoids'
AND intRowStatus = 0

SELECT @WasVaccinationAdministered = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'WasVaccinationAdministered'
AND intRowStatus = 0

SELECT @Revaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'Revaccination'
AND intRowStatus = 0

SELECT @DateOfVaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'DateOfVaccination'
AND intRowStatus = 0

SELECT @DateOfRevaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'DateOfRevaccination'
AND intRowStatus = 0

SELECT @ImmunizationHistory_DateOfLastVaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ImmunizationHistory_DateOfLastVaccination'
AND intRowStatus = 0

SELECT @SpecificVaccination_DateOfLastVaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'SpecificVaccination_DateOfLastVaccination'
AND intRowStatus = 0

SELECT @IfYes_IndicateDatesOfDoses = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'IfYes_IndicateDatesOfDoses'
AND intRowStatus = 0

SELECT @IfYes_NumberOfVaccinesReceived = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'IfYes_NumberOfVaccinesReceived'
AND intRowStatus = 0

SELECT @IntervalSinceLastTetanusToxoidDose = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'IntervalSinceLastTetanusToxoidDose'
AND intRowStatus = 0

SELECT @DateOfLastOPVDoseReceived = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'DateOfLastOPVDoseReceived'
AND intRowStatus = 0

SELECT @NameVaccine = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'NameVaccine' --Vaccine type that caused post vaccination complications: Name of vaccine
AND intRowStatus = 0

--NEW!!!
SELECT @IsPatientVaccinatedAgainstLeptospirosis = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'IsPatientVaccinatedAgainstLeptospirosis'
AND intRowStatus = 0

SELECT @DateOfVaccinationOfPatientAgainstLeptospirosis = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'DateOfVaccinationOfPatientAgainstLeptospirosis'
AND intRowStatus = 0

--NEW!!! 22.06.2016
SELECT @RabiesVaccineDose = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'RabiesVaccineDose'
AND intRowStatus = 0	

SELECT @RabiesVaccinationDate = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'RabiesVaccinationDate'
AND intRowStatus = 0		

SELECT @PneumonaeVaccinationStatus = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PneumonaeVaccinationStatus'
AND intRowStatus = 0	
	
SELECT @PneumonaeNumberReceivedDoses = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PneumonaeNumberReceivedDoses'
AND intRowStatus = 0	
	
SELECT @PneumonaeDateLastVaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PneumonaeDateLastVaccination'
AND intRowStatus = 0	
	
SELECT @HepatitisANumberReceivedDoses = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'HepatitisANumberReceivedDoses'
AND intRowStatus = 0		
	
SELECT @HepatitisADateLastVaccination = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'HepatitisADateLastVaccination'
AND intRowStatus = 0	

--SELECT 
--@RabiesVaccineDose as RabiesVaccineDose
--,@RabiesVaccinationDate as RabiesVaccinationDate
--,@PneumonaeVaccinationStatus as PneumonaeVaccinationStatus
--,@PneumonaeNumberReceivedDoses as PneumonaeNumberReceivedDoses
--,@PneumonaeDateLastVaccination as PneumonaeDateLastVaccination
--,@HepatitisANumberReceivedDoses as HepatitisANumberReceivedDoses
--,@HepatitisADateLastVaccination as HepatitisADateLastVaccination




-- sections
SELECT @Section_AdditionalOPVdoses = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'Section_AdditionalOPVdoses'
AND intRowStatus = 0    
 
SELECT @Section_Maternalhistory = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'Section_Maternalhistory'
AND intRowStatus = 0

--parameter values type
SELECT @PVT_Immunization3 = pt.idfsReferenceType FROM trtFFObjectForCustomReport pfc
	INNER JOIN dbo.ffParameterType  pt
	on pfc.idfsFFObject = pt.idfsParameterType
	AND pt.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PVT_Immunization3'
AND pfc.intRowStatus = 0

SELECT @PVT_Immunization5 = pt.idfsReferenceType FROM trtFFObjectForCustomReport pfc
	INNER JOIN dbo.ffParameterType  pt
	on pfc.idfsFFObject = pt.idfsParameterType
	AND pt.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PVT_Immunization5'
AND pfc.intRowStatus = 0

SELECT @PVT_VaccineTypes = pt.idfsReferenceType FROM trtFFObjectForCustomReport pfc
	INNER JOIN dbo.ffParameterType  pt
	on pfc.idfsFFObject = pt.idfsParameterType
	AND pt.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PVT_VaccineTypes'
AND pfc.intRowStatus = 0

SELECT @PVT_OPVDoses = pt.idfsReferenceType FROM trtFFObjectForCustomReport pfc
	INNER JOIN dbo.ffParameterType  pt
	on pfc.idfsFFObject = pt.idfsParameterType
	AND pt.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PVT_OPVDoses'
AND pfc.intRowStatus = 0

SELECT @PVT_Y_N_Unk = pt.idfsReferenceType FROM trtFFObjectForCustomReport pfc
	INNER JOIN dbo.ffParameterType  pt
	on pfc.idfsFFObject = pt.idfsParameterType
	AND pt.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'PVT_Y_N_Unk'
AND pfc.intRowStatus = 0
     

--Templates
--ft_HEI_Acute_viral_hepatitis_B_GG
SELECT @ft_HEI_Acute_viral_hepatitis_B_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Acute_viral_hepatitis_B_GG'
AND pfc.intRowStatus = 0

--ft_HEI_AFP_Acute_poliomyelitis_GG
SELECT @ft_HEI_AFP_Acute_poliomyelitis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_AFP_Acute_poliomyelitis_GG'
AND pfc.intRowStatus = 0
	
--ft_HEI_Anthrax_GG
SELECT @ft_HEI_Anthrax_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Anthrax_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Botulism_GG
SELECT @ft_HEI_Botulism_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Botulism_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Brucellosis_GG
SELECT @ft_HEI_Brucellosis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Brucellosis_GG'
AND pfc.intRowStatus = 0

--ft_HEI_CRS_GG
SELECT @ft_HEI_CRS_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_CRS_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Congenital_Syphilis_GG
SELECT @ft_HEI_Congenital_Syphilis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Congenital_Syphilis_GG'
AND pfc.intRowStatus = 0

--ft_HEI_CCHF_GG
SELECT @ft_HEI_CCHF_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_CCHF_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Diphtheria_GG
SELECT @ft_HEI_Diphtheria_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Diphtheria_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Gonococcal_Infection_GG
SELECT @ft_HEI_Gonococcal_Infection_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Gonococcal_Infection_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Bacterial_Meningitis_GG
SELECT @ft_HEI_Bacterial_Meningitis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Bacterial_Meningitis_GG'
AND pfc.intRowStatus = 0

--ft_HEI_HFRS_GG
SELECT @ft_HEI_HFRS_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_HFRS_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Influenza_Virus_GG
SELECT @ft_HEI_Influenza_Virus_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Influenza_Virus_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Measles_GG
SELECT @ft_HEI_Measles_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Measles_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Mumps_GG
SELECT @ft_HEI_Mumps_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Mumps_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Pertussis_GG
SELECT @ft_HEI_Pertussis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Pertussis_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Plague_GG
SELECT @ft_HEI_Plague_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Plague_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Post_vaccination_unusual_reactions_and_comp
SELECT @ft_HEI_Post_vaccination_unusual_reactions_and_complications_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Post_vaccination_unusual_reactions_and_comp'
AND pfc.intRowStatus = 0

--ft_HEI_Rabies_GG
SELECT @ft_HEI_Rabies_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Rabies_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Rubella_GG
SELECT @ft_HEI_Rubella_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Rubella_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Smallpox_GG
SELECT @ft_HEI_Smallpox_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Smallpox_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Syphilis_GG
SELECT @ft_HEI_Syphilis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Syphilis_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Tetanus_GG
SELECT @ft_HEI_Tetanus_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Tetanus_GG'
AND pfc.intRowStatus = 0

--ft_HEI_TBE_GG
SELECT @ft_HEI_TBE_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_TBE_GG'
AND pfc.intRowStatus = 0

--ft_HEI_Tularemia_GG
SELECT @ft_HEI_Tularemia_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Tularemia_GG'
AND pfc.intRowStatus = 0

--ft_UNI_HEI_GG
SELECT @ft_UNI_HEI_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_UNI_HEI_GG'
AND pfc.intRowStatus = 0

--NEW!!!
--ft_HEI_Leptospirosis_GG
SELECT @ft_HEI_Leptospirosis_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Leptospirosis_GG'
AND pfc.intRowStatus = 0


--NEW!!! 22.06.2016
--@ft_HEI_Pneumonae_GG 
SELECT @ft_HEI_Pneumonae_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Pneumonae_GG'
AND pfc.intRowStatus = 0
	
--@ft_HEI_Acute_Viral_Hepatitis_A_GG 
SELECT @ft_HEI_Acute_Viral_Hepatitis_A_GG = ft.idfsFormTemplate 
FROM trtFFObjectForCustomReport pfc
	INNER JOIN ffFormTemplate ft
	on pfc.idfsFFObject = ft.idfsFormTemplate
	AND ft.intRowStatus = 0
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ft_HEI_Acute_Viral_Hepatitis_A_GG'
AND pfc.intRowStatus = 0	

--SELECT 
--	 @ft_HEI_Acute_viral_hepatitis_B_GG 
--	,@ft_HEI_AFP_Acute_poliomyelitis_GG 
--	,@ft_HEI_Anthrax_GG 
--	,@ft_HEI_Botulism_GG 
--	,@ft_HEI_Brucellosis_GG 
--	,@ft_HEI_CRS_GG 
--	,@ft_HEI_Congenital_Syphilis_GG 
--	,@ft_HEI_CCHF_GG 
--	,@ft_HEI_Diphtheria_GG 
--	,@ft_HEI_Gonococcal_Infection_GG 
--	,@ft_HEI_Bacterial_Meningitis_GG 
--	,@ft_HEI_HFRS_GG 
--	,@ft_HEI_Influenza_Virus_GG 
--	,@ft_HEI_Measles_GG 
--	,@ft_HEI_Mumps_GG 
--	,@ft_HEI_Pertussis_GG 
--	,@ft_HEI_Plague_GG 
--	,@ft_HEI_Post_vaccination_unusual_reactions_AND_complications_GG 
--	,@ft_HEI_Rabies_GG 
--	,@ft_HEI_Rubella_GG 
--	,@ft_HEI_Smallpox_GG 
--	,@ft_HEI_Syphilis_GG 
--	,@ft_HEI_Tetanus_GG 
--	,@ft_HEI_TBE_GG 
--	,@ft_HEI_Tularemia_GG 
--	,@ft_UNI_HEI_GG 
--	,@ft_HEI_Leptospirosis_GG  as ft_HEI_Leptospirosis_GG
--	,@ft_HEI_Pneumonae_GG as ft_HEI_Pneumonae_GG
--	,@ft_HEI_Acute_Viral_Hepatitis_A_GG as ft_HEI_Acute_Viral_Hepatitis_A_GG
	

---- Diagnosis groups
  
--DG_MotherTtetanusToxoidHistoryPriorToChildDisease
SELECT @DG_MotherTtetanusToxoidHistoryPriorToChildDisease = dg.idfsReportDiagnosisGroup
FROM dbo.trtReportDiagnosisGroup dg
WHERE dg.intRowStatus = 0 AND
   dg.strDiagnosisGroupAlias = 'DG_MotherTtetanusToxoidHistoryPriorToChildDisease'      
    

      
      
 
 INSERT INTO @ReportTable (
 	strName,
	LegacyCaseID,
	intRow,
 	strAge,
 	strGender,
 	strAddress,
 	strPlaceOfStudyWork,
 	datDiseaseOnsetDate,
 	datDateOfFirstPresentation,
 	strFacilityThatSentNotification,
 	strProvisionalDiagnosis,
 	datDateProvisionalDiagnosis,
 	datDateSpecificTreatment,
 	datDateSpecimenTaken,
 	strResultAndDate,
 	strVaccinationStatus,
 	datDateCaseInvestigation,
 	strFinalDS,
 	strFinalClassification,
 	datDateFinalDS,
 	strOutcome,
 	strCaseStatus,
 	strComments,
 	strCaseID
 ) 
 SELECT
   dbo.FN_GBL_ConcatFullName(h.strLastName, h.strFirstName, h.strSecondName) AS strName,
   hc.LegacyCaseID,
   ROW_NUMBER() OVER (PARTITION BY hc.LegacyCaseID ORDER BY hc.idfHumanCase),
   CAST(hc.intPatientAge AS VARCHAR(10)) + N' (' + ref_AgeType.[name] + N')' +
     CASE WHEN	(ISNULL(hc.intPatientAge, 100) < 15 AND ISNULL(hc.idfsHumanAgeType, 10042003) = 10042003 /*years*/)
 				or (ISNULL(hc.idfsHumanAgeType, 10042003) <> 10042003 /*years*/)
          THEN ISNULL(N', ' + CONVERT(VARCHAR(10), h.datDateofBirth , 104), N'')
          ELSE N'' 
     END AS strAge,
   ref_hg.[name] AS strGender,
   ISNULL(@CurrentResidence, N'') + 
 		report.FN_REP_CreateAddressString
 				(	gl_cr.Country,
 					gl_cr.Region,
 					gl_cr.Rayon,
 					gl_cr.PostalCode,
 					gl_cr.SettlementType,
 					gl_cr.Settlement,
 					gl_cr.Street,
 					gl_cr.House,
 					gl_cr.Building,
 					gl_cr.Appartment,
 					gl_cr.blnForeignAddress,
 					gl_cr.strForeignAddress
 				) +
     CASE WHEN report.FN_REP_CreateAddressString
 				(	gl_cr.Country,
 					gl_cr.Region,
 					gl_cr.Rayon,
 					gl_cr.PostalCode,
 					gl_cr.SettlementType,
 					gl_cr.Settlement,
 					gl_cr.Street,
 					gl_cr.House,
 					gl_cr.Building,
 					gl_cr.Appartment,
 					gl_cr.blnForeignAddress,
 					gl_cr.strForeignAddress
 				) <> 
 			report.FN_REP_CreateAddressString
 				(	gl_r.Country,
 					gl_r.Region,
 					gl_r.Rayon,
 					gl_r.PostalCode,
 					gl_r.SettlementType,
 					gl_r.Settlement,
 					gl_r.Street,
 					gl_r.House,
 					gl_r.Building,
 					gl_r.Appartment,
 					gl_r.blnForeignAddress,
 					gl_r.strForeignAddress
 				)
 				AND ISNULL(gl_r.Region, N'') <> N''
          THEN '; ' +  ISNULL(@PermanentResidence, N'') + 
 				report.FN_REP_CreateAddressString
 						(	gl_r.Country,
 							gl_r.Region,
 							gl_r.Rayon,
 							gl_r.PostalCode,
 							gl_r.SettlementType,
 							gl_r.Settlement,
 							gl_r.Street,
 							gl_r.House,
 							gl_r.Building,
 							gl_r.Appartment,
 							gl_r.blnForeignAddress,
 							gl_r.strForeignAddress
 						)
 		ELSE N''
     END AS strAddress,
   ISNULL(CASE WHEN h.strEmployerName = '' THEN NULL ELSE h.strEmployerName END + '; ', N'') + 
     CASE WHEN ISNULL(gl_em.Region, N'') <> N''
          THEN 		ISNULL(report.FN_REP_CreateAddressString
 					(	gl_em.Country,
 						gl_em.Region,
 						gl_em.Rayon,
 						gl_em.PostalCode,
 						gl_em.SettlementType,
 						gl_em.Settlement,
 						gl_em.Street,
 						gl_em.House,
 						gl_em.Building,
 						gl_em.Appartment,
 						gl_em.blnForeignAddress,
 						gl_em.strForeignAddress
 					), '')
 		ELSE N''
 	END AS   strPlaceOfStudyWork,
   hc.datOnSetDate AS datDiseaseOnsetDate,
   hc.datFirstSoughtCareDate AS datDateOfFirstPresentation,
   ISNULL(fi.name, '') + 
 	ISNULL(', ' + tp.strFamilyName, '') + ISNULL(' ' + tp.strFirstName, '') + ISNULL(' ' + tp.strSecondName, '') + 
     ISNULL(', ' + CONVERT(VARCHAR(10),hc.datNotificationDate, 104),'') AS strFacilityThatSentNotification,
   ref_diag.[name] AS strProvisionalDiagnosis,
   hc.datTentativeDiagnosisDate AS datDateProvisionalDiagnosis,
   CASE WHEN hc.idfsYNAntimicrobialTherapy = 10100001 THEN
         (SELECT TOP 1 a.datFirstAdministeredDate 
           FROM tlbAntimicrobialTherapy a
           WHERE a.idfHumanCase = hc.idfHumanCase 
 				AND a.intRowStatus = 0
           ORDER BY 1 ASC)
      ELSE NULL END AS datDateSpecificTreatment,
 	CAST((SELECT 	
   	          ref_st_collected.[name] +
   	          ISNULL(', ' + CONVERT(VARCHAR, m_collected.datFieldCollectionDate, 103), '') + '; '
 			FROM tlbMaterial m_collected
 			INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000087 /*rftSpecimenType*/) ref_st_collected
   						ON ref_st_collected.idfsReference = m_collected.idfsSampleType
 			WHERE m_collected.idfHuman = h.idfHuman
 				AND m_collected.idfHumanCase = hc.idfHumanCase
 				AND m_collected.blnShowInLabList = 1
 					AND m_collected.intRowStatus = 0
 					
 			ORDER BY	m_collected.datFieldCollectionDate 	                
   	        FOR XML PATH('')		
     ) AS NVARCHAR(MAX))  AS datDateSpecimenTaken,
 	CAST((SELECT 	
   	          ref_st.[name] +
   	          ISNULL(', ' + ref_tt.[name], '') +
   	          ISNULL(', ' + ref_tr.[name], '') +
   	          ISNULL(', ' + CONVERT(VARCHAR, b.datValidatedDate, 103), '') + '; '
   	        FROM	(
 				tlbTesting t
   	            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000097 /*rftTestName*/)  AS ref_tt
   	            ON ref_tt.idfsReference = t.idfsTestName
 					)
 			INNER JOIN	(
 				tlbMaterial m
   	                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000087 /*rftSpecimenType*/) ref_st
   	                ON ref_st.idfsReference = m.idfsSampleType
 						)
   	            ON m.idfMaterial = t.idfMaterial AND
   	               m.intRowStatus = 0
   	            LEFT OUTER JOIN tlbBatchTest b
   	            ON t.idfBatchTest = b.idfBatchTest
 					AND b.intRowStatus = 0
   	            
   	            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000096 /*rftTestResult*/)  AS ref_tr
   	            ON ref_tr.idfsReference = t.idfsTestResult
   	         WHERE t.intRowStatus = 0 AND
   	                m.idfHuman = h.idfHuman
   	        ORDER BY	b.datValidatedDate
   	        FOR XML PATH('')		
     ) AS NVARCHAR(MAX))  AS strResultANDDate,
   --------------------------------------------------------------------------------------------------------------------
   CASE 
 --------------------
     /*Number of immunizations received + Date of last vaccination*/ 
     WHEN obs.idfsFormTemplate in (@ft_HEI_Acute_viral_hepatitis_B_GG) 
         THEN ISNULL(ref_ap1.name + ', ','') + CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103) 
 --------------------    
     /*Are patient is immunization records available*/    
     WHEN obs.idfsFormTemplate in (@ft_HEI_AFP_Acute_poliomyelitis_GG) 
         /*
			Show the following string "{1} [- {2} - {3}; ][[{4}: {5} - {6}; ]]{7}", 
			WHERE {1} is the value of the parameter with tooltip "Are patient's immunization records available";
			{2} is the tooltip of the first not blank parameter with a value different 
				from "Unknown", which is taken from the following list 
				in specified order: "OPV-5", "OPV-4", "OPV-3", "OPV-2", and "OPV-1";
			{3} is the value of the parameter SELECTed for {2};
			{4} is the name of the section with full 
				path “Immunization history>Additional OPV doses received during mass campaigns”;
			{5} is the tooltip of the first not blank parameter with a value different 
				from "Unknown", which is taken from the following list in specified order: 
				"Third additional OPV dose", "Second additional OPV dose", "First additional OPV dose";
			{6} is the value of the parameter SELECTed for {5};
			{7} is the value of the parameter with tooltip "Date of last OPV dose received";
			and the parts [...] and [[...]] are optional and depend on the following conditions:
			- the part [...] shall be displayed if {1} is equal to "Yes"
			- the part [[...]] shall be displayed if {6} is not blank;
			the square brackets that indicate the beginning and end of the optional parts 
			shall not be displayed in the report
		*/
         THEN 
             /*{1} -*/
              ISNULL(ref_ap2.name + '- ', '')
             /*{2} - {3};*/  
              +
              CASE WHEN ref_ap2.idfsReference = 10100001 /*yes*/
                   THEN 
                     CASE WHEN ref_ap26.name IS NOT NULL AND ref_ap26.idfsReference <> 995360000000 /*Unknown*/ 
                          THEN (SELECT [name] 
                                 FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                 WHERE idfsReference = @OPV5field -- /*"OPV-5" field*/
                                ) + '-' + ref_ap26.name + '; '
                          ELSE
                          CASE WHEN ref_ap25.name IS NOT NULL AND ref_ap25.idfsReference <> 995360000000 /*Unknown*/ 
                              THEN (SELECT [name] 
                                     FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                     WHERE idfsReference = @OPV4field -- /*"OPV-4" field*/
                                    ) + '-' + ref_ap25.name + '; '
                              ELSE
                              CASE WHEN ref_ap24.name IS NOT NULL AND ref_ap24.idfsReference <> 995360000000 /*Unknown*/ 
                                  THEN (SELECT [name] 
                                         FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                         WHERE idfsReference = @OPV3field -- /*"OPV-3" field*/
                                        ) + '-' + ref_ap24.name + '; '
                                  ELSE
                                  CASE WHEN ref_ap23.name IS NOT NULL AND ref_ap23.idfsReference <> 995360000000 /*Unknown*/ 
                                      THEN (SELECT [name] 
                                             FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                             WHERE idfsReference = @OPV2field -- /*"OPV-2" field*/
                                            ) + '-' + ref_ap23.name + '; '
                                      ELSE
                                      CASE WHEN ref_ap22.name IS NOT NULL AND ref_ap22.idfsReference <> 995360000000 /*Unknown*/ 
                                          THEN (SELECT [name] 
                                                 FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                                 WHERE idfsReference = @OPV1field -- /*"OPV-1" field*/
                                                ) + '-' + ref_ap22.name + '; '
                                          ELSE ''
                                      END /*OPV-1*/                                      
                                  END /*OPV-2*/                              
                              END /*OPV-3*/                              
                          END /*OPV-4*/   
                      END /*OPV-5*/          
                   ELSE ''
              END --CASE WHEN ref_ap2.idfsReference = 10100001 /*yes*/    
             /* {4} : */  
              +
              CASE WHEN ref_ap29.name /*"Third" field*/ IS NOT NULL OR 
                        ref_ap28.name /*"Second" field*/ IS NOT NULL OR
                        ref_ap27.name /*"First" field*/ IS NOT NULL
                   THEN (SELECT snt.strTextString FROM trtStringNameTranslation snt
                            WHERE snt.idfsBaseReference = @Section_AdditionalOPVdoses /*section name - Additional OPV doses received during mass campaigns*/
                                   AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID) 
                                   AND snt.intRowStatus = 0                
                         ) + ':' +
                             /*{5} - {6}; */  
                             CASE WHEN ref_ap29.name IS NOT NULL AND ref_ap29.idfsReference <> 995360000000 /*Unknown*/ 
                                  THEN (SELECT [name] 
                                         FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                         WHERE idfsReference = @Thirdfield -- /*"Third" field*/
                                        ) + '-' + ref_ap29.name
                                  ELSE
                                  CASE WHEN ref_ap28.name IS NOT NULL AND ref_ap28.idfsReference <> 995360000000 /*Unknown*/ 
                                      THEN (SELECT [name] 
                                             FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                             WHERE idfsReference = @Secondfield -- /*"Second" field*/
                                            ) + '-' + ref_ap28.name
                                      ELSE
                                      CASE WHEN ref_ap27.name IS NOT NULL AND ref_ap27.idfsReference <> 995360000000 /*Unknown*/ 
                                          THEN (SELECT [name] 
                                                 FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                                                 WHERE idfsReference = @Firstfield -- /*"First" field*/
                                                ) + '-' + ref_ap27.name
                                          ELSE ''
                                      END /*First*/               
                                  END /*Second*/
                              END /*Third*/  
                              /*7)*/
                              + '; '                       
                   ELSE ''
              END  
             /* {7} */  
              +    
             CONVERT(VARCHAR(10), CAST(ap30.varValue AS DATETIME), 103) 
 
 --------------------    
     /*Was specific vaccination administered? + Date of last vaccination*/
     WHEN  obs.idfsFormTemplate IN  (
     									@ft_HEI_Anthrax_GG,
     									@ft_HEI_Botulism_GG,
     									@ft_HEI_Brucellosis_GG,
     									@ft_HEI_Congenital_Syphilis_GG,
     									@ft_HEI_CCHF_GG,    
     									@ft_HEI_Gonococcal_Infection_GG, 
     									@ft_HEI_HFRS_GG,
     									@ft_HEI_Plague_GG ,
     									@ft_HEI_Smallpox_GG,
     									@ft_HEI_Syphilis_GG,
     									@ft_HEI_TBE_GG,
     									@ft_HEI_Tularemia_GG   
     
									)
         THEN ISNULL(ref_ap3.name + ', ','') + CONVERT(VARCHAR(10), CAST(ap18_2.varValue AS DATETIME), 103) 
 --------------------    
     /*Vaccinated against rubella
		 name of section "Maternal history" then ":" then name of "Vaccinated against rubella" 
		 then "-" and value in "Vaccinated against rubella".*/    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_CRS_GG         
									)
         THEN (SELECT snt.strTextString FROM trtStringNameTranslation snt
                 WHERE snt.idfsBaseReference = @Section_Maternalhistory /*name of section "Maternal history"*/
                       AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID) 
                       AND snt.intRowStatus = 0                
               ) + ':' + 
               (SELECT [name] 
                 FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000066/*rftParameter*/) 
                 WHERE idfsReference = @VaccinatedAgainstRubella
                ) + '-' +  ref_ap4.name
 --------------------    
     /* Number of received doses (any vaccine with diphtheria component) + Date of last vaccination
        1) value in "Number of received doses (any vaccine with diphtheria component)"; 
        2) if value in 1) is not blank then "," otherwise nothing; 
        3) value in "Immunization history: Date of last vaccination". 
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Diphtheria_GG         
									)
         
         THEN ISNULL(ref_ap5.name + ', ','') + CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103) 
 --------------------    
     /*Hib vaccination status + If "Yes", number of vaccines received + Date of last vaccination
      1) value in "Hib vaccination status"; 
      2) if value in 1) is not blank then "," otherwise nothing;
      3) value in "Number of Hib vaccines received"; 
      4) if value in 3) is not blank then "," otherwise nothing; 
      5) value in "Immunization history: Date of last vaccination".
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Bacterial_Meningitis_GG         
									)
         THEN ISNULL(ref_ap8.name + ', ','') + 
              ISNULL(ref_ap20.name + ', ','') + 
              CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103) 
 --------------------    
     /*Number of received doses (any vaccine with measles component) + Date of last vaccination
     1) value in "Number of received doses (any vaccine with measles component)"; 
     2) if value in 1) is not blank then "," otherwise nothing; 
     3) value in "Immunization history: Date of last vaccination".
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Measles_GG         
									)
         THEN ISNULL(ref_ap7.name + ', ','') + CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103) 
--------------------    
     /*Number of received doses (any vaccine with mumps component) + Date of last vaccination
     1) value in "Number of received doses (any vaccine with mumps component)"; 
     2) if value in 1) is not blank then "," otherwise nothing; 
     3) value in "Immunization history: Date of last vaccination".
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Mumps_GG         
									)
         THEN ISNULL(ref_ap9.name+ ', ','') + CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103)  
--------------------    
     /*Number of received doses (any vaccine with pertussis component) + Date of last vaccination
     1) value in "Number of received doses (any vaccine with pertussis component)";
     2) if value in 1) is not blank then "," otherwise nothing; 
     3) value in "Immunization history: Date of last vaccination".
     */    
     WHEN  obs.idfsFormTemplate IN  (
     									@ft_HEI_Pertussis_GG         
									)
         THEN ISNULL(ref_ap11.name+ ', ','') + CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103)
 --------------------    
     /*Vaccine type that caused post vaccination complications: Name of vaccine
     Show all distinct values from the column of the table section, 
     which is linked to the parameter tooltip "Vaccine type that caused post vaccination complications: Name of vaccine", 
     combined in the string of the following format: "{1};{2};{3}", WHERE {n} is a unique value from the specified column.
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Post_vaccination_unusual_reactions_and_complications_GG         
									)
         THEN 
			cast(	(	SELECT distinct
							ISNULL(ref_ap34.name + '; ', '') 
     	 				FROM	tlbObservation obs34
							 INNER JOIN tlbActivityParameters ap34
							 ON ap34.idfObservation = obs34.idfObservation AND
								ap34.idfsParameter = @NameVaccine /* Vaccine type that caused post vaccination complications: Name of vaccine*/ AND 
								ap34.intRowStatus = 0   
				 
							 LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_VaccineTypes /*Vaccine types*/)  ref_ap34
							 ON ref_ap34.idfsReference = ap34.varValue
			     	 	WHERE	obs34.idfObservation = hc.idfEpiObservation AND
								obs34.intRowStatus = 0  
					FOR	XML PATH('')
					) AS NVARCHAR(MAX)
				)         	
 --------------------    
	-- UPDATED
     /*Show combination of following: 
     *	1) value in "Rabies vaccine given?"; 
     *	2) if value in 1) is not blank then ";" otherwise nothing; 
     *	3) value from "Rabies vaccine dose" field that corresponds the latest value in "Rabies vaccination date" field of table 
     *	section "Rabies Immunization Details" followed by ","; 
     *	4) respective value in "Rabies vaccination date" field.
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Rabies_GG         
									)
         THEN ISNULL(ref_ap6.name+ '; ','') + ISNULL(RabiesVacination.RabiesVaccinationDate + ', ', '') + ISNULL(RabiesVacination.RabiesVaccineDose, '')
---------------------   
     /*Number of received doses (any vaccine with rubella component) + Date of last vaccination
     1) value in "Number of received doses (any vaccine with rubella component)"; 
     2) if value in 1) is not blank then "," otherwise nothing; 
     3) value in "Immunization history: Date of last vaccination".
     */    
     WHEN obs.idfsFormTemplate IN  (
     									@ft_HEI_Rubella_GG         
									)
         THEN ISNULL(ref_ap12.name+ ', ','')  + CONVERT(VARCHAR(10), CAST(ap18.varValue AS DATETIME), 103)       
                 
 --------------------    
     /*Mother's tetanus toxoid history prior to child's disease (known doses only) + Interval since last tetanus toxoid dose (years)
     For cases, WHERE "Final Diagnosis" = "Neonatal Tetanus": show combination of following: 
     1) value in "Mother's tetanus toxoid history prior to child's disease (known doses only)"; 
     2) if value in 1) is not blank then ";" otherwise nothing; 
     3) value in "Interval since last tetanus toxoid dose (years) (mother's)"
     */    
     when	obs.idfsFormTemplate in		(
     										@ft_HEI_Tetanus_GG         
										) 
			AND				
			COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) IN
			(SELECT idfsDiagnosis 
				FROM dbo.trtDiagnosisToGroupForReportType 
				WHERE idfsCustomReportType = @idfsCustomReportType
				AND idfsReportDiagnosisGroup = @DG_MotherTtetanusToxoidHistoryPriorToChildDisease --"Final Diagnosis" = "Neonatal Tetanus"
			)
         THEN ISNULL(ref_ap10.name + '; ', '') + CAST(ap21.varValue AS NVARCHAR(300))
 --------------------    
     /*Include doses of ALL tetanus-containing toxoids. Exclude doses received after this particular injury + 
      Interval since last tetanus toxoid dose (years)
     For cases, WHERE "Final Diagnosis" does not equal to "Neonatal Tetanus": show combination of following: 
     1) value in "Include doses of ALL tetanus-containing toxoids. Exclude doses received after this particular injury"; 
     2) if value in 1) is not blank then "," otherwise nothing 
     3) value in "Interval since last tetanus toxoid dose (years)".
     */    
     WHEN obs.idfsFormTemplate in		(
     										@ft_HEI_Tetanus_GG         
										) 
			AND				
			COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) not IN
			(SELECT idfsDiagnosis 
				FROM dbo.trtDiagnosisToGroupForReportType 
				WHERE idfsCustomReportType = @idfsCustomReportType
				AND idfsReportDiagnosisGroup = @DG_MotherTtetanusToxoidHistoryPriorToChildDisease --"Final Diagnosis" = "Neonatal Tetanus"
			)
         THEN ISNULL(ref_ap13.name  + '; ','') + CAST(ap21.varValue AS NVARCHAR(300))
         
 --------------------    
     /*Revaccination + Date of revaccination
     1)  if the value in "Revaccination" is "Yes" show the combination of the following:
     a) the value in "Revaccination"
     b) if the value in 1a) is not blank then "," otherwise nothing
     c) the value in "Date of revaccination" 
     */    
     WHEN  obs.idfsFormTemplate in		(
     										@ft_UNI_HEI_GG         
										)
         AND ref_ap15.idfsReference = 10100001
         THEN ISNULL(ref_ap15.name + ', ','') + CONVERT(VARCHAR(10), CAST(ap17.varValue AS DATETIME), 103)
 
 --------------------    
     /*Was vaccination administered? + Date of vaccination
     if the value in "Revaccination" is empty, or equals to "No", or "Unknown" show the combination of the following:
     a) the value in "Was vaccination administered?"
     b) if the value in 2a) is not blank then "," otherwise nothing
     c) the value in "Date of vaccination"
     */    
     WHEN obs.idfsFormTemplate in		(
     										@ft_UNI_HEI_GG         
										)
         AND ref_ap15.idfsReference <> 10100001
         THEN ISNULL(ref_ap14.name + ', ','') + CONVERT(VARCHAR(10), CAST(ap16.varValue AS DATETIME), 103)        
         
  
 
  --------------------    
  --NEW!!!
     /*Show combination of following: 
     *			1) value in "Is patient vaccinated against leptospirosis?"; 
     *			2) if value in 1) is not blank then "," otherwise nothing; 
     *			3) value in "Date of vaccination of patient against leptospirosis".
     */    
     WHEN obs.idfsFormTemplate IN		(
     										@ft_HEI_Leptospirosis_GG         
										)
         THEN ISNULL(ref_ap31.name,'') + CASE WHEN ref_ap31.name IS NOT NULL AND ap32.varValue IS NOT NULL THEN ',' ELSE '' END +   ISNULL( CONVERT(VARCHAR(10),CAST(ap32.varValue AS DATETIME), 103), '')      
         
  
 
  --------------------      
  --NEW!!!
     /*Show combination of following: 
     * 1) value in "HEI S. pneumonae caused infection GG: S. pneumonae vaccination status"; 
     * 2) if value in 1) is not blank then "," otherwise nothing; 
     * 3) value in "HEI S. pneumonae caused infection GG: Number of received doses of S. pneumonae vaccine"; 
     * 4) if value in 3) is not blank then "," otherwise nothing; 
     * 5) value in "HEI S. pneumonae caused infection GG: Date of last vaccination".
     */    
     WHEN obs.idfsFormTemplate in		(
     										@ft_HEI_Pneumonae_GG         
										)
         THEN ISNULL(ref_ap37.name, '') + ISNULL(', ' + ref_ap38.name, '') + ISNULL( ', ' + CONVERT(VARCHAR(10),CAST(ap39.varValue AS DATETIME), 103), '')      

  --------------------    
  --NEW!!!
     /*Show combination of following: 
     * 1) value in "HEI Acute Viral Hepatitis A GG: Number of received doses of Hepatitis A vaccine"; 
     * 2) if value in 1) is not blank then "," otherwise nothing; 
     * 3) value in "HEI Acute Viral Hepatitis A GG: Date of last vaccination".
     */    
     WHEN obs.idfsFormTemplate in		(
     										@ft_HEI_Acute_Viral_Hepatitis_A_GG         
										)
         THEN ISNULL(ref_ap40.name,'') + CASE WHEN ref_ap40.name IS NOT NULL AND ap41.varValue IS NOT NULL THEN ',' ELSE '' END +   ISNULL( CONVERT(VARCHAR(10),CAST(ap41.varValue AS DATETIME), 103), '')      
         

  --------------------      
  
  
     ELSE NULL
   END AS strVaccinationStatus,
  
 ----------------------------------------------------------------------------------------------
   hc.datInvestigationStartDate AS datDateCaseInvestigation,
   ISNULL(ref_diag_f.[name], ref_diag.[name]) AS strFinalDS,
   ISNULL(ref_final_cs.[name], ref_init_cs.[name]) AS strFinalClassification,
   CASE WHEN hc.datFinalDiagnosisDate IS NULL AND ref_diag_f.idfsReference IS NULL 
         THEN hc.datTentativeDiagnosisDate
         ELSE hc.datFinalDiagnosisDate 
        END AS datDateFinalDS,
   ref_outcome.[name] +  CASE WHEN hc.idfsOutcome = 10760000000 /*outRecovered*/ 
                                 THEN ISNULL(', ' + CONVERT(VARCHAR(10),hc.datDischargeDate, 104), '')
                              WHEN hc.idfsOutcome = 10770000000 /*outDied*/ 
                                 THEN ISNULL(', ' + CONVERT(VARCHAR(10),h.datDateOfDeath, 104), '')
                              ELSE ''
                          END AS strOutcome      ,
   ISNULL(@OutbreakID, N'') + o.strOutbreakID  AS  strCaseStatus,
 	ISNULL(CASE WHEN hc.strNote = '' THEN NULL ELSE hc.strNote END + N'; ', N'') + 
 		ISNULL(CASE WHEN hc.strClinicalNotes = '' THEN NULL ELSE hc.strClinicalNotes END + N'; ', N'') + 
 		ISNULL(CASE WHEN hc.strSummaryNotes = '' THEN NULL ELSE hc.strSummaryNotes END + N';', N'') AS strComments,
 ----------------------------------------------------------------------------------------------
          
   hc.strCaseID
   
 FROM tlbHumanCase hc
		INNER JOIN 
		(tlbHuman h
		   LEFT OUTER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000043/*rftHumanGender*/) ref_hg
		   ON ref_hg.idfsReference = h.idfsHumanGender
		    
		   LEFT JOIN		report.FN_GBL_AdressAsRow(@LangID) gl_cr
					on			gl_cr.idfGeoLocation = h.idfCurrentResidenceAddress
		    
		   LEFT JOIN		report.FN_GBL_AdressAsRow(@LangID) gl_r
					on			gl_r.idfGeoLocation = h.idfRegistrationAddress
		    
		   LEFT JOIN		report.FN_GBL_AdressAsRow(@LangID) gl_em
					on			gl_em.idfGeoLocation = h.idfEmployerAddress
		)
		ON hc.idfHuman = h.idfHuman AND
		  h.intRowStatus = 0
             
             
         LEFT OUTER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000042/*rftHumanAgeType*/) ref_AgeType
         ON ref_AgeType.idfsReference = hc.idfsHumanAgeType
         
         LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019/*rftDiagnosis*/) ref_diag
         ON ref_diag.idfsReference = hc.idfsTentativeDiagnosis
         
         LEFT OUTER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019/*rftDiagnosis*/) ref_diag_f
         ON ref_diag_f.idfsReference = hc.idfsFinalDiagnosis
         
         LEFT OUTER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011/*rftCaseStatus*/) ref_final_cs
         ON ref_final_cs.idfsReference = hc.idfsFinalCaseStatus
         
         LEFT OUTER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000011/*rftCaseStatus*/) ref_init_cs
         ON ref_init_cs.idfsReference = hc.idfsInitialCaseStatus
 
         LEFT OUTER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000064 /*rftOutcome*/) ref_outcome
         ON ref_outcome.idfsReference = hc.idfsOutcome
         
         LEFT OUTER JOIN tlbObservation obs
         ON obs.idfObservation = hc.idfEpiObservation AND
            obs.intRowStatus = 0
                     
         LEFT OUTER JOIN 
         (tlbObservation obs1
             INNER JOIN tlbActivityParameters ap1
             ON ap1.idfObservation = obs1.idfObservation AND
                ap1.idfsParameter = @NumberOfImmunizationsReceived --  /*Number of immunizations received*/ 
                AND ap1.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap1
             ON ref_ap1.idfsReference = ap1.varValue 
         )
         ON obs1.idfObservation = hc.idfEpiObservation AND
            obs1.intRowStatus = 0
            
         LEFT OUTER JOIN 
         (tlbObservation obs2
             INNER JOIN tlbActivityParameters ap2
             ON ap2.idfObservation = obs2.idfObservation AND
                ap2.idfsParameter =  @ArePatientsImmunizationRecordsAvailable/* Are patient�s immunization records available*/ AND 
                ap2.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap2
             ON ref_ap2.idfsReference = ap2.varValue 
         )
         ON obs2.idfObservation = hc.idfEpiObservation AND
            obs2.intRowStatus = 0
      
         LEFT OUTER JOIN 
         (tlbObservation obs3
             INNER JOIN tlbActivityParameters ap3
             ON ap3.idfObservation = obs3.idfObservation AND
                ap3.idfsParameter =  @WasSpecificVaccinationAdministered/* Was specific vaccination administered?*/ AND 
                ap3.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap3
             ON ref_ap3.idfsReference = ap3.varValue 
         )
         ON obs3.idfObservation = hc.idfEpiObservation AND
            obs3.intRowStatus = 0  
               
         LEFT OUTER JOIN 
         (tlbObservation obs4
             INNER JOIN tlbActivityParameters ap4
             ON ap4.idfObservation = obs4.idfObservation AND
                ap4.idfsParameter =  @VaccinatedAgainstRubella/* Vaccinated against rubella*/ AND 
                ap4.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap4
             ON ref_ap4.idfsReference = ap4.varValue 
         )
         ON obs4.idfObservation = hc.idfEpiObservation AND
            obs4.intRowStatus = 0     
            
         LEFT OUTER JOIN 
         (tlbObservation obs5
             INNER JOIN tlbActivityParameters ap5
             ON ap5.idfObservation = obs5.idfObservation AND
                ap5.idfsParameter =  @NumberOfReceivedDoses_WithDiphtheriaComponent/* Number of received doses (any vaccine with diphtheria component)*/ AND 
                ap5.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap5
             ON ref_ap5.idfsReference = ap5.varValue 
         )
         ON obs5.idfObservation = hc.idfEpiObservation AND
            obs5.intRowStatus = 0             
            
         LEFT OUTER JOIN 
         (tlbObservation obs6
             INNER JOIN tlbActivityParameters ap6
             ON ap6.idfObservation = obs6.idfObservation AND
                ap6.idfsParameter =  @RabiesVaccineGiven/* Rabies vaccine given?*/ AND 
                ap6.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap6
             ON ref_ap6.idfsReference = ap6.varValue 
         )
         ON obs6.idfObservation = hc.idfEpiObservation AND
            obs6.intRowStatus = 0             
            
            
         LEFT OUTER JOIN 
         (tlbObservation obs7
             INNER JOIN tlbActivityParameters ap7
             ON ap7.idfObservation = obs7.idfObservation AND
                ap7.idfsParameter =  @NumberOfReceivedDoses_WithMeaslesComponent/* Number of received doses (any vaccine with measles component)*/ AND 
                ap7.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization3 /*Immunization 3+*/)  ref_ap7
             ON ref_ap7.idfsReference = ap7.varValue 
         )
         ON obs7.idfObservation = hc.idfEpiObservation AND
            obs7.intRowStatus = 0             
            
            
         LEFT OUTER JOIN 
         (tlbObservation obs8
             INNER JOIN tlbActivityParameters ap8
             ON ap8.idfObservation = obs8.idfObservation AND
                ap8.idfsParameter =  @HibVaccinationStatus/* Hib vaccination status*/ AND 
                ap8.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap8
             ON ref_ap8.idfsReference = ap8.varValue 
         )
         ON obs8.idfObservation = hc.idfEpiObservation AND
            obs8.intRowStatus = 0                 
            
         LEFT OUTER JOIN 
         (tlbObservation obs9
             INNER JOIN tlbActivityParameters ap9
             ON ap9.idfObservation = obs9.idfObservation AND
                ap9.idfsParameter =  @NumberOfReceivedDoses_WithMumpsComponent/* Number of received doses (any vaccine with mumps component)*/ AND 
                ap9.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization3 /*Immunization 3+*/)  ref_ap9
             ON ref_ap9.idfsReference = ap9.varValue 
         )
         ON obs9.idfObservation = hc.idfEpiObservation AND
            obs9.intRowStatus = 0      
                    
         LEFT OUTER JOIN 
         (tlbObservation obs10
             INNER JOIN tlbActivityParameters ap10
             ON ap10.idfObservation = obs10.idfObservation AND
                ap10.idfsParameter =  @MothersTetanusToxoidHistoryPriorToChildsDisease/* Mother's tetanus toxoid history prior to child's disease (known doses only)*/ AND 
                ap10.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap10
             ON ref_ap10.idfsReference = ap10.varValue 
         )
         ON obs10.idfObservation = hc.idfEpiObservation AND
            obs10.intRowStatus = 0      
               
         LEFT OUTER JOIN 
         (tlbObservation obs11
             INNER JOIN tlbActivityParameters ap11
             ON ap11.idfObservation = obs11.idfObservation AND
                ap11.idfsParameter =  @NumberOfReceivedDoses_WithPertussisComponent/* Number of received doses (any vaccine with pertussis component)*/ AND 
                ap11.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap11
             ON ref_ap11.idfsReference = ap11.varValue 
         )
         ON obs11.idfObservation = hc.idfEpiObservation AND
            obs11.intRowStatus = 0      
                             
         LEFT OUTER JOIN 
         (tlbObservation obs12
             INNER JOIN tlbActivityParameters ap12
             ON ap12.idfObservation = obs12.idfObservation AND
                ap12.idfsParameter =  @NumberOfReceivedDoses_WithRubellaComponent/* Number of received doses (any vaccine with rubella component)*/ AND 
                ap12.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization3 /*Immunization 3+*/)  ref_ap12
             ON ref_ap12.idfsReference = ap12.varValue 
         )
         ON obs12.idfObservation = hc.idfEpiObservation AND
            obs12.intRowStatus = 0      
                
         LEFT OUTER JOIN 
         (tlbObservation obs13
             INNER JOIN tlbActivityParameters ap13
             ON ap13.idfObservation = obs13.idfObservation AND
                ap13.idfsParameter = @IncludeDosesOfALLTetanusContainingToxoids /* Include doses of ALL tetanus-containing toxoids. Exclude doses received after this particular injury*/ AND 
                ap13.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap13
             ON ref_ap13.idfsReference = ap13.varValue 
         )
         ON obs13.idfObservation = hc.idfEpiObservation AND
            obs13.intRowStatus = 0                 
                
         LEFT OUTER JOIN 
         (tlbObservation obs14
             INNER JOIN tlbActivityParameters ap14
             ON ap14.idfObservation = obs14.idfObservation AND
                ap14.idfsParameter =  @WasVaccinationAdministered /* Was vaccination administered?*/ AND 
                ap14.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap14
             ON ref_ap14.idfsReference = ap14.varValue 
         )
         ON obs14.idfObservation = hc.idfEpiObservation AND
            obs14.intRowStatus = 0                      
                      
         LEFT OUTER JOIN 
         (tlbObservation obs15
             INNER JOIN tlbActivityParameters ap15
             ON ap15.idfObservation = obs15.idfObservation AND
                ap15.idfsParameter = @Revaccination /*Revaccination*/ AND 
                ap15.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap15
             ON ref_ap15.idfsReference = ap15.varValue 
         )
         ON obs15.idfObservation = hc.idfEpiObservation AND
            obs15.intRowStatus = 0 
         LEFT OUTER JOIN 
         (tlbObservation obs16
             INNER JOIN tlbActivityParameters ap16
             ON ap16.idfObservation = obs16.idfObservation AND
                ap16.idfsParameter = @DateOfVaccination /* Date of vaccination*/ AND 
                ap16.intRowStatus = 0
         )
         ON obs16.idfObservation = hc.idfEpiObservation AND
            obs16.intRowStatus = 0            
            
                         
         LEFT OUTER JOIN 
         (tlbObservation obs17
             INNER JOIN tlbActivityParameters ap17
             ON ap17.idfObservation = obs17.idfObservation AND
                ap17.idfsParameter = @DateOfRevaccination /* Date of revaccination*/ AND 
                ap17.intRowStatus = 0
         )
         ON obs17.idfObservation = hc.idfEpiObservation AND
            obs17.intRowStatus = 0     
         LEFT OUTER JOIN 
         (tlbObservation obs18
             INNER JOIN tlbActivityParameters ap18
             ON ap18.idfObservation = obs18.idfObservation AND
                ap18.idfsParameter = @ImmunizationHistory_DateOfLastVaccination /* Date of last vaccination*/ AND 
                ap18.intRowStatus = 0
         )
         ON obs18.idfObservation = hc.idfEpiObservation AND
            obs18.intRowStatus = 0   
                      
         LEFT OUTER JOIN 
         (tlbObservation obs18_2
             INNER JOIN tlbActivityParameters ap18_2
             ON ap18_2.idfObservation = obs18_2.idfObservation AND
                ap18_2.idfsParameter =  @SpecificVaccination_DateOfLastVaccination /* Date of last vaccination*/ AND 
                ap18_2.intRowStatus = 0
         )
         ON obs18_2.idfObservation = hc.idfEpiObservation AND
            obs18_2.intRowStatus = 0             
 
         --LEFT OUTER JOIN 
         --(tlbObservation obs19
         --    INNER JOIN tlbActivityParameters ap19
         --    ON ap19.idfObservation = obs19.idfObservation AND
         --       ap19.idfsParameter = @IfYes_IndicateDatesOfDoses /* Dates and doses of rabies vaccine given*/ AND 
         --       ap19.intRowStatus = 0
         --)
         --ON obs19.idfObservation = hc.idfEpiObservation AND
         --   obs19.intRowStatus = 0     
         
         OUTER APPLY(
         		SELECT TOP 1
         					convert(VARCHAR(10),cast(ap35.varValue as DATETIME), 104) as RabiesVaccinationDate,
         					cast(ap36.varValue as NVARCHAR(20)) as RabiesVaccineDose
     	 				FROM	tlbObservation obs35
							 INNER JOIN tlbActivityParameters ap35
							 on ap35.idfObservation = obs35.idfObservation AND
								ap35.idfsParameter = @RabiesVaccinationDate /* Rabies vaccination date*/ AND 
								ap35.intRowStatus = 0   
								AND (cast(SQL_VARIANT_PROPERTY(ap35.varValue, 'BaseType') as NVARCHAR) like N'%date%' or
									(
										cast(SQL_VARIANT_PROPERTY(ap35.varValue, 'BaseType') as NVARCHAR) like N'%char%' AND ISDATE(cast(ap35.varValue as NVARCHAR)) = 1 )	)
							 left  JOIN tlbActivityParameters ap36
							 on ap36.idfObservation = obs35.idfObservation AND
								ap36.idfsParameter = @RabiesVaccineDose /* Rabies vaccination dose*/ AND 
								ap36.intRowStatus = 0   
								AND ap35.idfRow = ap36.idfRow
			     	 	WHERE	obs35.idfObservation = hc.idfEpiObservation AND
								obs35.intRowStatus = 0  
         		ORDER BY cast(ap35.varValue as DATETIME) desc
         ) as RabiesVacination
 
         LEFT OUTER JOIN 
         (tlbObservation obs20
             INNER JOIN tlbActivityParameters ap20
             ON ap20.idfObservation = obs20.idfObservation AND
                ap20.idfsParameter = @IfYes_NumberOfVaccinesReceived /* Number of vaccines received*/ AND 
                ap20.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap20
             ON ref_ap20.idfsReference = ap20.varValue 
         )
         ON obs20.idfObservation = hc.idfEpiObservation AND
            obs20.intRowStatus = 0 
 
         LEFT OUTER JOIN 
         (tlbObservation obs21
             INNER JOIN tlbActivityParameters ap21
             ON ap21.idfObservation = obs21.idfObservation AND
                ap21.idfsParameter = @IntervalSinceLastTetanusToxoidDose /* Interval since last tetanus toxoid dose (years)*/ AND 
                ap21.intRowStatus = 0     
         )
         ON obs21.idfObservation = hc.idfEpiObservation AND
            obs21.intRowStatus = 0  
 
         --LEFT OUTER JOIN 
         --(tlbObservation obs21_2
         --    INNER JOIN tlbActivityParameters ap21_2
         --    ON ap21_2.idfObservation = obs21_2.idfObservation AND
         --       ap21_2.idfsParameter = @IntervalSinceLastTetanusToxoidDose1 /* Interval since last tetanus toxoid dose (years)*/ AND 
         --       ap21_2.intRowStatus = 0     
         --)
         --ON obs21_2.idfObservation = hc.idfEpiObservation AND
         --   obs21_2.intRowStatus = 0  
 
         LEFT OUTER JOIN 
         (tlbObservation obs22
             INNER JOIN tlbActivityParameters ap22
             ON ap22.idfObservation = obs22.idfObservation AND
                ap22.idfsParameter = @OPV1field   /* OPV-1*/ 
                AND ap22.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap22
             ON ref_ap22.idfsReference = ap22.varValue 
         )
         ON obs22.idfObservation = hc.idfEpiObservation AND
            obs22.intRowStatus = 0 
 
         LEFT OUTER JOIN 
         (tlbObservation obs23
             INNER JOIN tlbActivityParameters ap23
             ON ap23.idfObservation = obs23.idfObservation AND
                ap23.idfsParameter = @OPV2field  /* OPV-2*/ 
                AND ap23.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap23
             ON ref_ap23.idfsReference = ap23.varValue 
         )
         ON obs23.idfObservation = hc.idfEpiObservation AND
            obs23.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs24
             INNER JOIN tlbActivityParameters ap24
             ON ap24.idfObservation = obs24.idfObservation AND
                ap24.idfsParameter = @OPV3field  /* OPV-3*/ 
                AND ap24.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap24
             ON ref_ap24.idfsReference = ap24.varValue 
         )
         ON obs24.idfObservation = hc.idfEpiObservation AND
            obs24.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs25
             INNER JOIN tlbActivityParameters ap25
             ON ap25.idfObservation = obs25.idfObservation AND
                ap25.idfsParameter = @OPV4field  /* OPV-4*/  
                AND ap25.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap25
             ON ref_ap25.idfsReference = ap25.varValue 
         )
         ON obs25.idfObservation = hc.idfEpiObservation AND
            obs25.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs26
             INNER JOIN tlbActivityParameters ap26
             ON ap26.idfObservation = obs26.idfObservation AND
                ap26.idfsParameter = @OPV5field  /* OPV-5*/  
                AND ap26.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap26
             ON ref_ap26.idfsReference = ap26.varValue 
         )
         ON obs26.idfObservation = hc.idfEpiObservation AND
            obs26.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs27
             INNER JOIN tlbActivityParameters ap27
             ON ap27.idfObservation = obs27.idfObservation AND
                ap27.idfsParameter = @Firstfield  /* First*/ 
                AND ap27.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap27
             ON ref_ap27.idfsReference = ap27.varValue 
         )
         ON obs27.idfObservation = hc.idfEpiObservation AND
            obs27.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs28
             INNER JOIN tlbActivityParameters ap28
             ON ap28.idfObservation = obs28.idfObservation AND
                ap28.idfsParameter = @Secondfield  /* Second*/ 
                AND ap28.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap28
             ON ref_ap28.idfsReference = ap28.varValue 
         )
         ON obs28.idfObservation = hc.idfEpiObservation AND
            obs28.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs29
             INNER JOIN tlbActivityParameters ap29
             ON ap29.idfObservation = obs29.idfObservation AND
                ap29.idfsParameter = @Thirdfield   /* Third*/ 
                AND ap29.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_OPVDoses /*OPV Doses*/)  ref_ap29
             ON ref_ap29.idfsReference = ap29.varValue 
         )
         ON obs29.idfObservation = hc.idfEpiObservation AND
            obs29.intRowStatus = 0
 
         LEFT OUTER JOIN 
         (tlbObservation obs30
             INNER JOIN tlbActivityParameters ap30
             ON ap30.idfObservation = obs30.idfObservation AND
                ap30.idfsParameter = @DateOfLastOPVDoseReceived /* Date of last OPV dose received*/ AND 
                ap30.intRowStatus = 0     
         )
         ON obs30.idfObservation = hc.idfEpiObservation AND
            obs30.intRowStatus = 0  
		
		--NEW!!!
		 LEFT OUTER JOIN 
         (tlbObservation obs31
             INNER JOIN tlbActivityParameters ap31
             ON ap31.idfObservation = obs31.idfObservation AND
                ap31.idfsParameter =  @IsPatientVaccinatedAgainstLeptospirosis /*Is patient vaccinated against leptospirosis?*/ AND 
                ap31.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap31
             ON ref_ap31.idfsReference = ap31.varValue 
         )
         ON obs31.idfObservation = hc.idfEpiObservation AND
            obs31.intRowStatus = 0   
            
         LEFT OUTER JOIN 
         (tlbObservation obs32
             INNER JOIN tlbActivityParameters ap32
             ON ap32.idfObservation = obs32.idfObservation AND
                ap32.idfsParameter = @DateOfVaccinationOfPatientAgainstLeptospirosis /*Date of vaccination of patient against leptospirosis*/ AND 
                ap32.intRowStatus = 0     
         )
         ON obs32.idfObservation = hc.idfEpiObservation AND
            obs32.intRowStatus = 0              
 
         --LEFT OUTER JOIN 
         --(tlbObservation obs31
         --    INNER JOIN tlbActivityParameters ap31
         --    ON ap31.idfObservation = obs31.idfObservation AND
         --       ap31.idfsParameter = @NameVaccine1 /* Vaccine 1: Name of vaccine*/ AND 
         --       ap31.intRowStatus = 0   
 
         --    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_VaccineTypes /*Vaccine types*/)  ref_ap31
         --    ON ref_ap31.idfsReference = ap31.varValue 
                  
         --)
         --ON obs31.idfObservation = hc.idfEpiObservation AND
         --   obs31.intRowStatus = 0  
 
         --LEFT OUTER JOIN 
         --(tlbObservation obs32
         --    INNER JOIN tlbActivityParameters ap32
         --    ON ap32.idfObservation = obs32.idfObservation AND
         --       ap32.idfsParameter = @NameVaccine2 /* Vaccine 2: Name of vaccine*/ AND 
         --       ap32.intRowStatus = 0   
 
         --    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_VaccineTypes /*Vaccine types*/)  ref_ap32
         --    ON ref_ap32.idfsReference = ap32.varValue 
                  
         --)
         --ON obs32.idfObservation = hc.idfEpiObservation AND
         --   obs32.intRowStatus = 0  
            
         --LEFT OUTER JOIN 
         --(tlbObservation obs33
         --    INNER JOIN tlbActivityParameters ap33
         --    ON ap33.idfObservation = obs33.idfObservation AND
         --       ap33.idfsParameter = @NameVaccine3 /* Vaccine 3: Name of vaccine*/ AND 
         --       ap33.intRowStatus = 0   
 
         --    LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_VaccineTypes /*Vaccine types*/)  ref_ap33
         --    ON ref_ap33.idfsReference = ap33.varValue 
                  
         --)
         --ON obs33.idfObservation = hc.idfEpiObservation AND
         --   obs33.intRowStatus = 0         
         
     LEFT OUTER JOIN 
         (tlbObservation obs37
             INNER JOIN tlbActivityParameters ap37
             ON ap37.idfObservation = obs37.idfObservation AND
                ap37.idfsParameter =  @PneumonaeNumberReceivedDoses/*HEI S. pneumonae caused infection GG: Number of received doses of S. pneumonae vaccine*/ AND 
                ap37.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization3 /*Immunization 3+*/)  ref_ap37
             ON ref_ap37.idfsReference = ap37.varValue 
         )
         ON obs37.idfObservation = hc.idfEpiObservation AND
            obs37.intRowStatus = 0    
     
     LEFT OUTER JOIN 
         (tlbObservation obs38
             INNER JOIN tlbActivityParameters ap38
             ON ap38.idfObservation = obs38.idfObservation AND
                ap38.idfsParameter =  @PneumonaeVaccinationStatus /*HEI S. pneumonae caused infection GG: S. pneumonae vaccination status*/ AND 
                ap38.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Y_N_Unk /*Y_N_Unk*/)  ref_ap38
             ON ref_ap38.idfsReference = ap38.varValue 
         )
         ON obs38.idfObservation = hc.idfEpiObservation AND
            obs38.intRowStatus = 0     
            
     LEFT OUTER JOIN 
         (tlbObservation obs39
             INNER JOIN tlbActivityParameters ap39
             ON ap39.idfObservation = obs39.idfObservation AND
                ap39.idfsParameter = @PneumonaeDateLastVaccination /*HEI S. pneumonae caused infection GG: Date of last vaccination*/ AND 
                ap39.intRowStatus = 0     
                AND (cast(SQL_VARIANT_PROPERTY(ap39.varValue, 'BaseType') as NVARCHAR) like N'%date%' or
					(cast(SQL_VARIANT_PROPERTY(ap39.varValue, 'BaseType') as NVARCHAR) like N'%char%' AND ISDATE(cast(ap39.varValue as NVARCHAR)) = 1 )	)
         )
         ON obs39.idfObservation = hc.idfEpiObservation AND
            obs39.intRowStatus = 0         

         LEFT OUTER JOIN 
         (tlbObservation obs40
             INNER JOIN tlbActivityParameters ap40
             ON ap40.idfObservation = obs40.idfObservation AND
                ap40.idfsParameter = @HepatitisANumberReceivedDoses /* HEI Acute Viral Hepatitis A GG: Number of received doses of Hepatitis A vaccine*/ AND 
                ap40.intRowStatus = 0
             LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, @PVT_Immunization5 /*Immunization 5+*/)  ref_ap40
             ON ref_ap40.idfsReference = ap40.varValue 
         )
         ON obs40.idfObservation = hc.idfEpiObservation AND
            obs40.intRowStatus = 0             
            
      LEFT OUTER JOIN 
         (tlbObservation obs41
             INNER JOIN tlbActivityParameters ap41
             ON ap41.idfObservation = obs41.idfObservation AND
                ap41.idfsParameter = @HepatitisADateLastVaccination /*HEI Acute Viral Hepatitis A GG: Date of last vaccination*/ AND 
                ap41.intRowStatus = 0     
                AND (cast(SQL_VARIANT_PROPERTY(ap41.varValue, 'BaseType') as NVARCHAR) like N'%date%' or
					(cast(SQL_VARIANT_PROPERTY(ap41.varValue, 'BaseType') as NVARCHAR) like N'%char%' AND ISDATE(cast(ap41.varValue as NVARCHAR)) = 1 )	)
         )
         ON obs41.idfObservation = hc.idfEpiObservation AND
            obs41.intRowStatus = 0   
 
 
 
 
     LEFT OUTER JOIN tlbOutbreak o
     ON hc.idfOutbreak = o.idfOutbreak
 		AND o.intRowStatus = 0
 		
 	LEFT JOIN tlbPerson tp ON
 		tp.idfPerson = hc.idfSentByPerson
 
 	LEFT JOIN dbo.FN_GBL_Institution(@LangID) fi ON
 		fi.idfOffice = hc.idfSentByOffice
 		
 		
 		
 WHERE    hc.idfsSite = ISNULL(@SiteID, dbo.FN_GBL_SITEID_GET()) AND
          hc.intRowStatus = 0 AND 
          DATEDIFF(D, @StartDate, ISNULL(hc.datNotificationDate ,hc.datEnteredDate)) >= 0 AND
          DATEDIFF(D, @FinishDate, ISNULL(hc.datNotificationDate ,hc.datEnteredDate)) <= 0 AND
 			(ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = @Diagnosis OR @Diagnosis is null)
 		
 		
SELECT
	strName,	
 	strAge, 
 	strGender,
 	strAddress,
 	strPlaceOfStudyWork,
 	datDiseaseOnsetDate,
 	datDateOfFirstPresentation,
 	strFacilityThatSentNotification,
 	strProvisionalDiagnosis,
 	datDateProvisionalDiagnosis,
 	datDateSpecificTreatment,
 	datDateSpecimenTaken,
 	strResultAndDate,
 	strVaccinationStatus,
 	datDateCaseInvestigation,
 	strFinalDS,
 	strFinalClassification,
 	datDateFinalDS,
 	strOutcome,
 	strCaseStatus,
 	strComments,
 	strCaseID,
	datEnteredDate
FROM @ReportTable
ORDER BY datEnteredDate
 

GO
