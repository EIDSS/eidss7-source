﻿
-- ================================================================================================
-- Name: report.USP_REP_DeniedReportsLookup
--
-- Description:	returns reports available for current site
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/* Sample Code

exec report.USP_REP_DeniedReportsLookup 1101, 3448480000000
 
 */
 
 CREATE  PROCEDURE [Report].[USP_REP_DeniedReportsLookup]
(
 	@SiteID AS BIGINT = NULL,
 	@UserID AS BIGINT = NULL
)
 AS	
 BEGIN
 
 
 
 	declare @Result as table
 	(
 	  idfsCustomReportType	bigint  not null primary key,
 	  strReportAlias		nvarchar(200),
 	  strReportEnglishName	nvarchar(200),
 	  blnReportDenied		bit
 	  
 	)
 
 	insert into @Result values (01, 'ReportsHumAberrationAnalysis', 'Human Cases Aberration Analysis', 0)
 	insert into @Result values (02, 'ReportsVetAberrationAnalysis', 'Avian/Livestock Cases Aberration Analysis', 0)
 	insert into @Result values (03, 'ReportsSyndrAberrationAnalysis', 'Syndromic Surveillance Aberration Analysis', 0)
 	insert into @Result values (04, 'ReportsILISyndrAberrationAnalysis',				'ILI Aberration Analysis', 0)
 	insert into @Result values (05, 'ReportsHumDiagnosisToChangedDiagnosis',			'Human Concordance of Initial and Final Diagnosis', 0)
 	insert into @Result values (06, 'ReportsHumMonthlyMorbidityAndMortality',			'Human Monthly Morbidity And Mortality', 0)
 	insert into @Result values (07, 'ReportsHumSummaryOfInfectiousDiseases',			'Human Summary Of Infectious Diseases', 0)
 								
 	insert into @Result values (09, 'ReportsJournal60BReportCard',						'60B Journal', 0)
 	insert into @Result values (10, 'ReportsHumInfectiousDiseaseMonth',					'Report on Cases of Infectious Diseases (Monthly Form IV–03/1 Old Revision)', 0)
 	insert into @Result values (11, 'ReportsHumInfectiousDiseaseMonthNew',				'Report on Certain Diseases/Conditions (Monthly Form IV–03)', 0)
 	insert into @Result values (12, 'HumInfectiousDiseaseIntermediateMonth',			'Intermediate Report by Monthly Form IV–03/1 (Old Revision)', 0)
 	insert into @Result values (13, 'HumInfectiousDiseaseIntermediateMonthNew',			'Intermediate Report by Monthly Form IV–03', 0)
 	insert into @Result values (14, 'ReportsHumInfectiousDiseaseYear',					'Report on Cases of Annually Reportable Infectious Diseases (Annual Form IV–03 Old Revision)', 0)
 	insert into @Result values (15, 'HumInfectiousDiseaseIntermediateYear',				'Intermediate Report by Annual Form IV–03 (Old Revision)', 0)
 																						
 	insert into @Result values (17, 'ReportsHumSerologyResearchCard',					'Serology Research Result', 0)
 	insert into @Result values (18, 'ReportsHumMicrobiologyResearchCard',				'Microbiology Research Result', 0)
 	insert into @Result values (19, 'HumAntibioticResistanceCard',						'Antibiotic Resistance Card (NCDC&PH)', 0)
 	insert into @Result values (20, 'VetLaboratoryResearchResult',						'Laboratory Research Result', 0)
 	insert into @Result values (22, 'HumAntibioticResistanceCardLMA',					'Antibiotic Resistance Card (LMA)', 0)
 								
 	insert into @Result values (23, 'HumFormN1A3',										'Form # 1 (A3)', 0)
 	insert into @Result values (24, 'HumFormN1A4',										'Form # 1 (A4)', 0)
 	insert into @Result values (25, 'HumDataQualityIndicators',							'Data Quality Indicators', 0)
 	insert into @Result values (26, 'HumDataQualityIndicatorsRayons',					'Data Quality Indicators for rayons', 0)
 	insert into @Result values (27, 'HumComparativeReport',								'Comparative Report', 0)
 	insert into @Result values (28, 'HumSummaryByRayonDiagnosisAgeGroups',				'Report of human cases by rayon, diagnosis', 0)
 	insert into @Result values (29, 'HumExternalComparativeReport',						'External comparative Report', 0)
 	insert into @Result values (30, 'HumMainIndicatorsOfAFPSurveillance',				'Main indicators of AFP surveillance', 0)
 	insert into @Result values (31, 'HumAdditionalIndicatorsOfAFPSurveillance',			'Additional indicators of AFP surveillance', 0)
 	insert into @Result values (32, 'HumWhoMeaslesRubellaReport',						'WHO Report on Measles and Rubella', 0)
 	insert into @Result values (34, 'HumComparativeReportOfTwoYears',					'Comparative Report of two years by month', 0)
 																					
 	insert into @Result values (35, 'VeterinaryCasesReport',							'Veterinary Cases Report', 0)
 	insert into @Result values (37, 'VeterinaryLaboratoriesAZ',							'Report of Activities Conducted in Veterinary Laboratories', 0)
 																					
 	insert into @Result values (38, 'HumFormN85Annual',									'National Statistic Form # 85 (annual)', 0)
 	insert into @Result values (40, 'HumFormN85Monthly',								'National Statistic Form # 85 (monthly)', 0)
 																					
 	insert into @Result values (41, 'WeeklySituationDiseasesByDistricts',				'Weekly situation on infectious diseases by districts', 0)
 	insert into @Result values (42, 'WeeklySituationDiseasesByAgeGroupAndSex',			'Weekly situation on infectious diseases by age group and sex', 0)
 	insert into @Result values (44, 'HumComparativeIQReport',							'Comparative Report', 0)
 																					
 	insert into @Result values (45, 'ReportsVetSamplesCount',							'Veterinary Samples Count', 0)
 	insert into @Result values (46, 'ReportsVetSamplesReportBySampleType',				'Veterinary Samples By Sample Type', 0)
 	insert into @Result values (47, 'ReportsVetSamplesReportBySampleTypesWithinRegions','Veterinary Samples By Sample Types Within Regions', 0)
 	insert into @Result values (48, 'ReportsVetYearlySituation',						'Veterinary Yearly Situation', 0)
 	insert into @Result values (51, 'ReportsActiveSurveillance',						'Active Surveillance Report', 0)
 																						
 																					
 	insert into @Result values (52, 'VetCountryPlannedDiagnosticTestsReport',			'Country Report "Planned diagnostic tests"', 0)
 	insert into @Result values (53, 'VetRegionPlannedDiagnosticTestsReport',			'Oblast Report "Planned diagnostic tests"', 0)
 	insert into @Result values (54, 'VetCountryPreventiveMeasuresReport',				'Country Report "Veterinary preventive measures"', 0)
 	insert into @Result values (55, 'VetRegionPreventiveMeasuresReport',				'Oblast Report "Veterinary preventive measures"', 0)
 	insert into @Result values (56, 'VetCountryProphilacticMeasuresReport',				'Country Report "Veterinary- sanitary measures"', 0)
 	insert into @Result values (57, 'VetRegionProphilacticMeasuresReport',				'Oblast Report "Veterinary- sanitary measures"', 0)
 																					
 	insert into @Result values (58, 'ReportsAdmEventLog',								'Administrative Event Log', 0)

 	insert into @Result values (59, 'LabTestingResultsAZ',								'Laboratory testing results', 0)
  	insert into @Result values (60, 'AssignmentLabDiagnosticAZ',						'Assignment for Laboratory Diagnostic', 0)	

	insert into @Result values (61, 'VeterinaryFormVet1',								'Veterinary Report Form Vet 1', 0)	
    insert into @Result values (62, 'VeterinaryFormVet1A',								'Veterinary Report Form Vet 1A', 0)	

	insert into @Result values (63, 'HumBorderRayonsComparativeReport',					'Border rayons’ incidence comparative report', 0)	
   
	insert into @Result values (64, 'HumTuberculosisCasesTested',						'Report on Tuberculosis cases tested for HIV', 0)	
 
 	--  “Veterinary Sites” 
 	--(22, 'HumAntibioticResistanceCardLMA',					'Antibiotic Resistance Card (LMA)', 0)
 	UPDATE res SET
 		blnReportDenied = 1
 	FROM @Result res
 	WHERE res.idfsCustomReportType IN (22) AND
 	NOT EXISTS (SELECT *
 				FROM Report.FN_VetOrHumanSiteList_GET(96) hvl
 				INNER JOIN tstSite ts ON ts.idfsSite = hvl.idfsSite AND ts.idfsSite = @SiteID
 			)
 	
 	
 	--  “Human/Vet Sites” 	
 	--(19, 'HumAntibioticResistanceCard',						'Antibiotic Resistance Card (NCDC&PH)', 0)
	--(18, 'ReportsHumMicrobiologyResearchCard',				'Microbiology Research Result', 0)
	--(17, 'ReportsHumSerologyResearchCard',					'Serology Research Result', 0)
	
 	UPDATE res SET
 		blnReportDenied = 1
 	FROM @Result res
 	WHERE res.idfsCustomReportType IN (17, 18, 19) AND
 	NOT EXISTS (SELECT *
 				FROM Report.FN_VetOrHumanSiteList_GET(2) hvl
 				INNER JOIN dbo.tstSite ts ON ts.idfsSite = hvl.idfsSite AND ts.idfsSite = @SiteID
 			)
 	
 	--  'Laboratory Research Result' - 20
 	UPDATE res SET
 		blnReportDenied = 1
 	FROM @Result res
 	WHERE res.idfsCustomReportType = 20 AND
 	NOT EXISTS (SELECT *
 				FROM Report.FN_SiteListForLMAReport_GET() hvl
 				INNER JOIN dbo.tstSite ts ON ts.idfsSite = hvl.idfsSite AND ts.idfsSite = @SiteID
 			)
 				
 	UPDATE res 
	SET	blnReportDenied = 1
 	FROM @Result res
 	WHERE res.idfsCustomReportType IN (34, 63, 59, 60, 64) AND
 	NOT EXISTS (
 					SELECT 
						*
					FROM dbo.tlbOffice o
 					INNER JOIN dbo.tstSite ts ON ts.idfOffice = o.idfOffice	AND ts.idfsSite = @SiteID
 					WHERE o.intHACode & 2 > 0 
					OR ISNULL(o.intHACode, 0) = 0 
 				)	
 								 
 	SELECT	* 
 	FROM	@Result
 	WHERE	blnReportDenied = 1		 
 									 
 								 
 END								 

