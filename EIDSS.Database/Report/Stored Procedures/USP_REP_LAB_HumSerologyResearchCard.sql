--*************************************************************************
-- Name 				: report.USP_REP_LAB_HumSerologyResearchCard
-- Description			: Select data for Serology Research Card.
-- 
-- Author               : Srini Goli
-- Revision History
--		Name			Date		Change Detail
--		Srini Goli		11/13/2022	Function returning worong SiteId --Commented that like
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_LAB_HumSerologyResearchCard @LangID=N'en-US',@SampleID='SE01130039'
*/

CREATE PROCEDURE [Report].[USP_REP_LAB_HumSerologyResearchCard]
	(
		@LangID		AS NVARCHAR(10), 
		@SampleID	AS VARCHAR(36),	 
		@LastName	AS NVARCHAR(200) = NULL,
		@FirstName	AS NVARCHAR(200) = NULL,
		@SiteID		AS BIGINT = NULL
	)
AS	

-- Field description may be found here
-- "https://repos.btrp.net/BTRP/Project_Documents/08x-Implementation/Customizations/GG/Reports/Specification for report development - Serology Research Card Human GG v1.0.doc"
-- by number marked red at screen form prototype 

DECLARE	@ReportTable 	TABLE
(	idfTesting				BIGINT,
	strSiteName				NVARCHAR(200), --1
	strSiteAddress			NVARCHAR(200), --2
	strSampleId				NVARCHAR(200), --4
	datSampleReceived		DATETIME,	   --5
	datSampleCollected		DATETIME,	   --6
	strNameSurname			NVARCHAR(200), --8
	strAge					NVARCHAR(200), --9
	strResearchedSample		NVARCHAR(200), --10
	strSampleReceivedFrom	NVARCHAR(200), --11
	strResearchMethod		NVARCHAR(200), --13
	strResearchedDiagnosis	NVARCHAR(200), --14
	strResultReceived		NVARCHAR(200), --15
	strNorm					NVARCHAR(200), --16
	strDiagnosticalMeaning	NVARCHAR(200), --17
	strResearchConductedBy	NVARCHAR(max), --19
	strResponsiblePerson	NVARCHAR(2000),--20
	datResultDate			DATETIME,	   --21
	strKey					NVARCHAR(200) -- it need's for merge with archive data in application
)	
DECLARE
	@idfsOffice				BIGINT,
	@strOfficeName			NVARCHAR(200),
	@strOfficeLocation		NVARCHAR(200),
	@idfsCustomReportType	BIGINT,
	@tel					NVARCHAR(10)
  
DECLARE	
	@FFResultReceived	BIGINT,
	@FFNorm				BIGINT
  
--IF @SiteID IS NULL SET @SiteID = report.FN_GBL_SiteID_GET() 
SET @idfsCustomReportType = 10290014 -- GG Serology Research Result

SELECT @FFResultReceived = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ffp_ResultReceived'
AND intRowStatus = 0

SELECT @FFNorm = idfsFFObject FROM trtFFObjectForCustomReport
WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'ffp_Norm'
AND intRowStatus = 0  
  

  
SELECT	@tel = ISNULL(RTRIM(r.[name]) + N' ', N'')
FROM	FN_GBL_ReferenceRepair(@LangID, 19000132) r -- Additional report Text
WHERE	r.strDefault = N'Tel.:'

  
SELECT 
	@idfsOffice = o.idfOffice,
	@strOfficeLocation = ISNULL(report.FN_REP_AddressSharedString(@LangID, o.idfLocation), '') + ISNULL(', ' + @tel + o.strContactPhone, ''),
	@strOfficeName = fni.[name]
FROM	tstSite s
	INNER JOIN	tlbOffice o
	ON			o.idfOffice = s.idfOffice
	INNER JOIN	dbo.FN_GBL_Institution(@LangID) fni
	ON			o.idfOffice = fni.idfOffice
WHERE	 s.idfsSite = @SiteID



INSERT INTO @ReportTable (
	idfTesting				,
	strSiteName				, --1
	strSiteAddress			, --2
	strSampleId				, --4
	datSampleReceived		, --5
	datSampleCollected		, --6
	strNameSurname			, --8
	strAge					, --9
	strResearchedSample		, --10
	strSampleReceivedFrom	, --11
	strResearchMethod		, --13
	strResearchedDiagnosis	, --14
	strResultReceived		, --15
	strNorm					, --16
	strDiagnosticalMeaning	, --17
	strResearchConductedBy	, --19
	strResponsiblePerson	, --20
	datResultDate			, --21
	strKey
) 

SELECT
	testing.idfTesting,
	@strOfficeName,			--1
	@strOfficeLocation,		--2
	m.strBarcode,				--strSampleId --4
	m.datAccession,			--datSampleReceived	--5
	m.datFieldCollectionDate, --datSampleCollected --6
	ISNULL(h.strFirstName + ' ', '') + ISNULL(h.strLastName,''), --strNameSurname--8
	CAST(hc.intPatientAge AS NVARCHAR(10)) + N' (' + ref_age.[name] + N')', --strAge --9
	SampleType.[name],      --strResearchedSample --10
	CollectedByOffice.[name], --strSampleReceivedFrom --11
	TestName.[name],    --strResearchMethod --13
	TestDiagnosis.[name],   --strResearchedDiagnosis --14
	CAST(ap_ResultRec.varValue AS NVARCHAR(200)), --strResultReceived --15
	CAST(ap_Norm.varValue AS NVARCHAR(200)), --strNorm --16
	TestResult.[name],  --strDiagnosticalMeaning	, --17
	
  	CAST(	(	SELECT 
			 ISNULL(t.strFirstName + ' ', '') + ISNULL(t.strFamilyName, '') + N', '
     	 	FROM
     	 	(
     	 			SELECT TOP 1 WITH TIES
     	 				prcb.strFirstName,
     	 				prcb.strFamilyName,
     	 				Diagnosis.[name] AS DiagnosisName,
     	 				test.datConcludedDate,
     	 				tn.[name] AS TestName
				FROM tlbTesting test 
					INNER JOIN	trtTestTypeForCustomReport ttfcr
					ON		ttfcr.idfsTestName = test.idfsTestName
					AND		ttfcr.intRowStatus = 0
					AND		ttfcr.idfsCustomReportType = @idfsCustomReportType

					LEFT JOIN	dbo.FN_GBL_Reference_GETList(@LangID,19000019) Diagnosis
					ON		test.idfsDiagnosis = Diagnosis.idfsReference

					LEFT JOIN	dbo.FN_GBL_Reference_GETList(@LangID,19000097) tn
					ON			test.idfsTestName = tn.idfsReference		
	            	        
					LEFT JOIN	( tlbEmployee ercb
							INNER JOIN	tlbPerson prcb
							ON			prcb.idfPerson = ercb.idfEmployee
					)
					ON		ercb.idfEmployee = test.idfTestedByPerson	
					AND		ercb.intRowStatus = 0	
				WHERE test.idfMaterial = m.idfMaterial
					AND test.blnNonLaboratoryTest = 0
  					AND test.blnExternalTest = 0
  					AND test.blnReadOnly = 0
					AND test.intRowStatus = 0
				ORDER BY ROW_NUMBER() OVER(PARTITION BY prcb.strFirstName, prcb.strFamilyName ORDER BY test.datConcludedDate, tn.[name], Diagnosis.[name])

     	 	) AS t
     	 	ORDER BY t.datConcludedDate, t.TestName, t.DiagnosisName
		FOR	XML PATH('')
		) AS NVARCHAR(MAX)
	)	AS strResearchConductedBy, --  strResearchConductedBy --19
  
	(	SELECT TOP 1
  				 ISNULL(prcb.strFirstName + ' ', '') + ISNULL(prcb.strFamilyName, '')
  				FROM tlbTesting t 
  					INNER JOIN trtTestTypeForCustomReport ttfcr
					ON  ttfcr.idfsTestName = t.idfsTestName
						AND ttfcr.intRowStatus = 0
						AND ttfcr.idfsCustomReportType = @idfsCustomReportType
				  						        
  					LEFT JOIN	( tlbEmployee ercb
  							INNER JOIN	tlbPerson prcb
  							ON			prcb.idfPerson = ercb.idfEmployee
  					)
  					ON		ercb.idfEmployee = t.idfValidatedByPerson
  					AND		ercb.intRowStatus = 0	
  						          			    
         	 		WHERE	t.idfMaterial = m.idfMaterial
         	 				AND t.blnNonLaboratoryTest = 0
  							AND t.blnExternalTest = 0
  							AND t.blnReadOnly = 0
  							AND t.intRowStatus = 0
	 	ORDER BY t.datConcludedDate, t.idfTesting DESC
	)	AS strResponsiblePerson, --  strResponsiblePerson --20
  
  
	(	SELECT TOP 1
  				 t.datConcludedDate 
  				FROM tlbTesting t 
  					INNER JOIN trtTestTypeForCustomReport ttfcr
					ON  ttfcr.idfsTestName = t.idfsTestName
						AND ttfcr.intRowStatus = 0
						AND ttfcr.idfsCustomReportType = @idfsCustomReportType
				          			    
         	 		WHERE	t.idfMaterial = m.idfMaterial
         	 				AND t.blnNonLaboratoryTest = 0
  							AND t.blnExternalTest = 0
  							AND t.blnReadOnly = 0
  							AND t.intRowStatus = 0
	 	ORDER BY t.datConcludedDate, t.idfTesting DESC
	)	AS datResultDate, --datResultDate --21
  
  
  CONVERT(NVARCHAR(20), ISNULL(testing.datConcludedDate, testing.datStartedDate), 112)  + '_' + CAST(testing.idfTesting AS NVARCHAR(50)) AS strKey -- it need's for merge with archive data in application



FROM tlbMaterial m
	INNER JOIN	FN_GBL_ReferenceRepair(@LangID, 19000087) SampleType	-- Sample Type
	ON			SampleType.idfsReference = m.idfsSampleType

	LEFT JOIN	dbo.FN_GBL_Institution(@LangID) CollectedByOffice
	ON			CollectedByOffice.idfOffice = m.idfFieldCollectedByOffice
	
	LEFT JOIN	dbo.FN_GBL_Department(@LangID) dep
	ON			dep.idfDepartment = m.idfInDepartment

	INNER JOIN	( tlbHumanCase hc
					LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000042) ref_age	-- Human Age Type
					ON			ref_age.idfsReference = hc.idfsHumanAgeType
				    
					LEFT JOIN	FN_GBL_ReferenceRepair(@LangID,19000019) ref_diag_c
					ON			COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = ref_diag_c.idfsReference
				)
	ON		hc.idfHumanCase = m.idfHumanCase
	AND		hc.intRowStatus = 0
			
	INNER JOIN	tlbHuman h
	ON			h.idfHuman = m.idfHuman
	AND			h.intRowStatus = 0

	INNER JOIN (tlbTesting testing 
            INNER JOIN trtTestTypeForCustomReport ttfcr
            ON  ttfcr.idfsTestName = testing.idfsTestName
                AND ttfcr.intRowStatus = 0
                AND ttfcr.idfsCustomReportType = @idfsCustomReportType
                
            LEFT JOIN tlbBatchTest tbt
            ON tbt.idfBatchTest = testing.idfBatchTest
            AND tbt.intRowStatus = 0
            
            LEFT JOIN tlbObservation BatchObs
			ON BatchObs.idfObservation = tbt.idfObservation
			AND BatchObs.intRowStatus = 0
			            
			LEFT JOIN tlbObservation TestObs
			ON TestObs.idfObservation = testing.idfObservation
			AND TestObs.intRowStatus = 0
			
			LEFT JOIN tlbActivityParameters ap_ResultRec
			ON ap_ResultRec.idfObservation = TestObs.idfObservation
			AND ap_ResultRec.intRowStatus = 0
			AND ap_ResultRec.idfsParameter = @FFResultReceived
			
			LEFT JOIN tlbActivityParameters ap_Norm
			ON ap_Norm.idfObservation = BatchObs.idfObservation
			AND ap_Norm.intRowStatus = 0
			AND ap_Norm.idfsParameter = @FFNorm		
         			
            LEFT JOIN	dbo.FN_GBL_Reference_GETList(@LangID,19000097) TestName
            ON			testing.idfsTestName=TestName.idfsReference			   

            LEFT JOIN	dbo.FN_GBL_Reference_GETList(@LangID,19000019) TestDiagnosis
            ON			testing.idfsDiagnosis = TestDiagnosis.idfsReference

	        LEFT JOIN	dbo.FN_GBL_ReferenceRepair (@LangID, 19000096) TestResult
	        ON			testing.idfsTestResult = TestResult.idfsReference
	) 
	ON	testing.idfMaterial = m.idfMaterial 
		AND testing.blnNonLaboratoryTest = 0
  		AND testing.blnExternalTest = 0
  		AND testing.blnReadOnly = 0
		AND testing.intRowStatus = 0
           
WHERE	
		m.strBarcode = @SampleID
		AND (m.idfsSite = @SiteID OR ISNULL(@SiteID, N'') = N'')
		AND ((h.strLastName LIKE @LastName + '%') OR ISNULL(@LastName, N'') = N'')
		AND ((h.strFirstName LIKE @FirstName + '%') OR ISNULL(@FirstName, N'') = N'')

ORDER BY ISNULL(testing.datConcludedDate, testing.datStartedDate), testing.idfTesting



UPDATE	@ReportTable
SET		strResearchConductedBy = SUBSTRING(LTRIM(RTRIM(strResearchConductedBy)), 0, LEN(LTRIM(RTRIM(strResearchConductedBy))))
WHERE	LTRIM(RTRIM(strResearchConductedBy)) LIKE N'%,'


IF NOT EXISTS (SELECT * FROM @ReportTable)
BEGIN
  INSERT INTO @ReportTable (strSiteName, strSiteAddress)
  VALUES  (@strOfficeName, @strOfficeLocation)
END

    

SELECT 	
	idfTesting				,
	strSiteName				, --1
	strSiteAddress			, --2
	strSampleId				, --4
	datSampleReceived		, --5
	datSampleCollected		, --6
	strNameSurname			, --8
	strAge					, --9
	strResearchedSample		, --10
	strSampleReceivedFrom	, --11
	strResearchMethod		, --13
	strResearchedDiagnosis	, --14
	strResultReceived		, --15
	strNorm					, --16
	strDiagnosticalMeaning	, --17
	strResearchConductedBy	, --19
	strResponsiblePerson	, --20
	datResultDate			, --21
	strKey
 
FROM @ReportTable
ORDER BY strKey





GO

