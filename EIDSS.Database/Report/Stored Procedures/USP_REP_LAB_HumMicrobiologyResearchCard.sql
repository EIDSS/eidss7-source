

--*************************************************************************
-- Name 				: report.USP_REP_LAB_HumMicrobiologyResearchCard
-- DescriptiON			: SELECT data for Serology Research Card.
-- 
-- Author               : Srini Goli
-- RevisiON History
--		Name			Date       Change Detail
--		
-- Testing code:
/*
--Example of a call of procedure:
EXEC report.USP_REP_LAB_HumMicrobiologyResearchCard @LangID=N'en',@SampleID='S070140007'
*/

CREATE PROCEDURE [Report].[USP_REP_LAB_HumMicrobiologyResearchCard]
	(
		@LangID		as NVARCHAR(10), 
  		@SampleID	as varchar(36),	 
  		@LastName	as NVARCHAR(200) = NULL,
  		@FirstName	as NVARCHAR(200) = NULL,
  		@SiteID		as BIGINT = NULL
	)
AS	

-- Field descriptiON may be found here
  -- "https://repos.btrp.net/BTRP/Project_Documents/08x-ImplementatiON/CustomizatiONs/GG/Reports/SpecIFicatiON for report development - Microbiology Research Card Human GG v1.0.doc"
  -- BY number marked red at screen form prototype 
  
  DECLARE	@ReportTABLE 	TABLE
  (	
  	strSiteName				NVARCHAR(2000), --1
  	strSiteAddress			NVARCHAR(2000), --2
  	strSampleId				NVARCHAR(200),  --4
  	datSampleReceived		DATETIME,		--5
  	datSampleCollected		DATETIME,		--6
  	strNameSurname			NVARCHAR(2000), --8
  	strAge					NVARCHAR(200),  --9
  	strResearchedSample		NVARCHAR(2000), --10
  	strResearchedDiagnosis	NVARCHAR(2000), --11
  	strSampleReceivedFROM	NVARCHAR(2000), --12
  
  	blnBacteriology			BIT,			--14 new
  	blnVirology				BIT,			--15 new
  	blnMicroscopy			BIT,			--16 new
  	blnPCR					BIT,			--17 new
  	blnOther				BIT,			--18 new
  	strOther				NVARCHAR(max),	--19 new
  		
  	strResearchResult		NVARCHAR(max),  --20
  	strResearchCONductedBy	NVARCHAR(max),  --21
  	strRespONsiblePersON	NVARCHAR(2000), --22 
  	datResultIssueDate		DATETIME		--23
  )	
  
  
  DECLARE
    @idfsOffice BIGINT,
    @strOfficeName NVARCHAR(200),
    @strOfficeLocatiON NVARCHAR(200),
    @idfsCustomReportType BIGINT,
    @tel NVARCHAR(10)
    
  
	SET @idfsCustomReportType = 10290011 -- GG Microbiology Research Result

	SET @SiteID  = ISNULL(@SiteID, report.FN_SiteID_GET())

	SELECT @tel = ISNULL(RTrim(r.[name]) + N' ', N'')
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000132) r -- AdditiONal report Text
	WHERE r.strDefault = N'Tel.:'
  
	SELECT 
		@idfsOffice = o.idfOffice,
		@strOfficeLocatiON = ISNULL(report.FN_REP_AddressSharedString(@LangID, o.idfLocatiON), '') + ISNULL(', ' + @tel + o.strCONtactPhONe, ''),
		@strOfficeName = fni.FullName
	FROM tstSite s
	INNER JOIN tlbOffice o
	ON o.idfOffice = s.idfOffice
	INNER JOIN	report.FN_REP_InstitutiONRepair(@LangID) fni
	ON			o.idfOffice = fni.idfOffice
	WHERE	 s.idfsSite = @SiteID
  
  
  INSERT into @ReportTABLE (
  	strSiteName,
  	strSiteAddress,
  	strSampleId,
  	datSampleReceived,
  	datSampleCollected,
  	strNameSurname,
  	strAge,
  	strResearchedSample,
  	strResearchedDiagnosis,
  	strSampleReceivedFROM,
  	blnBacteriology,			--14 new
  	blnVirology,			--15 new
  	blnMicroscopy,			--16 new
  	blnPCR,			--17 new
  	blnOther,			--18 new
  	strOther,	--19 new	
  	
  	strResearchResult,
  	strResearchCONductedBy,
  	strRespONsiblePersON,
  	datResultIssueDate
  )
  SELECT
  	@strOfficeName,
  	@strOfficeLocatiON,
  	m.strBarcode,             --strSampleId
  	m.datAccessiON,           --datSampleReceived
  	m.datFieldCollectiONDate, --datSampleCollected
  	ISNULL(h.strFirstName + ' ', '') + ISNULL(h.strLastName,''),            --strNameSurname
  	CAST(hc.intPatientAge AS NVARCHAR(10)) + N' (' + ref_age.[name] + N')', --strAge
  
  	ref_st.[name],      --strResearchedSample		-- 10
  	ref_diag_c.[name],  --strResearchedDiagnosis	--11
  	mcb.[name],         --strSampleReceivedFROM	--12
  
  	-- 14 blnBacteriology
  	-- Checkbox should be checked IF AND ONly IF there is at least ONe laboratory test 
  	-- (created in laboratory module (not added in H02, not added as external result) 
  	-- at the EIDSS site WHERE the report generatiON takes place) assigned to the sample 
  	-- SELECTed in the filters of the report with the name equal to any item FROM attachment 
  	-- Microbiology Tests List with Test Sub-type = �Bacteriology�, to which at least ONe 
  	-- InterpretatiON record in H02 form -> Tests tab -> Results Summary AND InterpretatiON 
  	-- zONe is cONnected AND has the attribute Validated Yes/No = �Yes� (SELECTed the Validated 
  	-- check-box for correspONding row in the grid).
 
 	-- IF there is no laboratory test that meets abovementiONed criteria, 
 	-- THEN the Bacteriology checkbox should be clear.
 
  	CASE WHEN EXISTS (
  			SELECT top 1 *
  			FROM		tlbTesting testing 
  				INNER JOIN	trtTestTypeForCustomReport ttfcr
  				ON		ttfcr.idfsTestName = testing.idfsTestName
  				AND		ttfcr.intRowStatus = 0
  				AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  			    
  			    INNER JOIN trtBaseReferenceAttribute tbra
  					INNER JOIN	trtAttributeType at
  					ON			at.strAttributeTypeName = N'Test Sub-type'
  			    ON tbra.idfsBaseReference = ttfcr.idfsTestName
  			    AND cast(tbra.varValue as NVARCHAR(100)) = 'Bacteriology'
  			    
  				INNER JOIN	tlbTestValidatiON tv
  				ON		testing.idfTesting = tv.idfTesting
  				AND		tv.blnValidateStatus = 1
  				AND		tv.intRowStatus = 0		
    
  			WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0    
  				AND testing.blnReadONly = 0    
  				AND testing.intRowStatus = 0
  	) THEN 1 ELSE NULL END as blnBacteriology,	--14 
  	
  	--15 blnVirology
  	CASE WHEN EXISTS (
  			SELECT top 1 *
  			FROM		tlbTesting testing 
  				INNER JOIN	trtTestTypeForCustomReport ttfcr
  				ON		ttfcr.idfsTestName = testing.idfsTestName
  				AND		ttfcr.intRowStatus = 0
  				AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  			    
  			    INNER JOIN trtBaseReferenceAttribute tbra
  					INNER JOIN	trtAttributeType at
  					ON			at.strAttributeTypeName = N'Test Sub-type'
  			    ON tbra.idfsBaseReference = ttfcr.idfsTestName
  			    AND cast(tbra.varValue as NVARCHAR(100)) = 'Virology'
  			      			    
  				INNER JOIN	tlbTestValidatiON tv
  				ON		testing.idfTesting = tv.idfTesting
  				AND		tv.blnValidateStatus = 1
  				AND		tv.intRowStatus = 0		
    
  			WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0  
  				AND testing.blnReadONly = 0          
  				AND testing.intRowStatus = 0
  	) THEN 1 ELSE NULL END as blnVirology,			--15 
  	
  	--16 blnMicroscopy
  	CASE WHEN EXISTS (
  			SELECT top 1 *
  			FROM		tlbTesting testing 
  				INNER JOIN	trtTestTypeForCustomReport ttfcr
  				ON		ttfcr.idfsTestName = testing.idfsTestName
  				AND		ttfcr.intRowStatus = 0
  				AND		ttfcr.idfsCustomReportType = @idfsCustomReportType

  			    INNER JOIN trtBaseReferenceAttribute tbra
  					INNER JOIN	trtAttributeType at
  					ON			at.strAttributeTypeName = N'Test Sub-type'
  			    ON tbra.idfsBaseReference = ttfcr.idfsTestName
  			    AND cast(tbra.varValue as NVARCHAR(100)) = 'Microscopy'
  			    		    
  				INNER JOIN	tlbTestValidatiON tv
  				ON		testing.idfTesting = tv.idfTesting
  				AND		tv.blnValidateStatus = 1
  				AND		tv.intRowStatus = 0		
    
  			WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0    
  				AND testing.blnReadONly = 0        
  				AND testing.intRowStatus = 0
  	) THEN 1 ELSE NULL END as blnMicroscopy,			--16 
  	
  	--17 blnPCR
  	CASE WHEN EXISTS (
  			SELECT top 1 *
  			FROM		tlbTesting testing 
  				INNER JOIN	trtTestTypeForCustomReport ttfcr
  				ON		ttfcr.idfsTestName = testing.idfsTestName
  				AND		ttfcr.intRowStatus = 0
  				AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  				
  				INNER JOIN trtBaseReferenceAttribute tbra
  					INNER JOIN	trtAttributeType at
  					ON			at.strAttributeTypeName = N'Test Sub-type'
  			    ON tbra.idfsBaseReference = ttfcr.idfsTestName
  			    AND cast(tbra.varValue as NVARCHAR(100)) = 'PCR'
  			    
  				INNER JOIN	tlbTestValidatiON tv
  				ON		testing.idfTesting = tv.idfTesting
  				AND		tv.blnValidateStatus = 1
  				AND		tv.intRowStatus = 0		
  		
  			WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0   
  				AND testing.blnReadONly = 0         
  				AND testing.intRowStatus = 0
  	) THEN 1 ELSE NULL END as blnPCR,			--17 
  	
  	--18 blnOther
  	CASE WHEN EXISTS (
  			SELECT top 1 *
  			FROM		tlbTesting testing 
  				INNER JOIN	trtTestTypeForCustomReport ttfcr
  				ON		ttfcr.idfsTestName = testing.idfsTestName
  				AND		ttfcr.intRowStatus = 0
  				AND		ttfcr.idfsCustomReportType = @idfsCustomReportType

  				INNER JOIN trtBaseReferenceAttribute tbra
  					INNER JOIN	trtAttributeType at
  					ON			at.strAttributeTypeName = N'Test Sub-type'
  			    ON tbra.idfsBaseReference = ttfcr.idfsTestName
  			    AND cast(tbra.varValue as NVARCHAR(100)) = 'Other'  				
 			    
  				INNER JOIN	tlbTestValidatiON tv
  				ON		testing.idfTesting = tv.idfTesting
  				AND		tv.blnValidateStatus = 1
  				AND		tv.intRowStatus = 0		
    
  			WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0     
  				AND testing.blnReadONly = 0       
  				AND testing.intRowStatus = 0
  	) THEN 1 ELSE NULL END as blnOther,			--18 
    
 	--19 strOther
 	--  Unique (dIFferent) names of laboratory tests that meet criteria described 
 	--  for the Other check-box (18) splitted BY comma AND given in alphabetical 
 	--  ORDER in current language of the report. 
 	
  	cast(	(	
  			SELECT top 1 with ties
  					ISNULL(TestName.[name], N'') + N', '
  			FROM		tlbTesting testing 
  				INNER JOIN	trtTestTypeForCustomReport ttfcr
  				ON		ttfcr.idfsTestName = testing.idfsTestName
  				AND		ttfcr.intRowStatus = 0
  				AND		ttfcr.idfsCustomReportType = @idfsCustomReportType

  				INNER JOIN trtBaseReferenceAttribute tbra
  					INNER JOIN	trtAttributeType at
  					ON			at.strAttributeTypeName = N'Test Sub-type'
  			    ON tbra.idfsBaseReference = ttfcr.idfsTestName
  			    AND cast(tbra.varValue as NVARCHAR(100)) = 'Other' 
  			      				
  				LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000097) TestName
  				ON			testing.idfsTestName=TestName.idfsReference
 			    
  				INNER JOIN	tlbTestValidatiON tv
  				ON		testing.idfTesting = tv.idfTesting
  				AND		tv.blnValidateStatus = 1
  				AND		tv.intRowStatus = 0		
  			WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0   
  				AND testing.blnReadONly = 0         
  				AND testing.intRowStatus = 0
  	     	ORDER BY row_number() over(partitiON BY TestName.[name] ORDER BY TestName.[name] asc) 
  			for	xml path('')
  			) as NVARCHAR(max)
  		) as strOther,			--19  
  	
  	--20 strResearchResult
  	-- Unique combinatiON of the �Diagnosis�, �Test Name�, AND �Rule Out/Rule In� attributes of all interpretatiON 
  	-- records FROM H02 form -> Tests tab -> Results Summary AND InterpretatiON zONe  that have the attribute 
  	-- Validated Yes/No = �Yes� (SELECTed the Validated check-box for correspONding row in the grid) AND are 
  	-- cONnected to the tests that meet at least ONe criteriON described for the check-boxes 14-18. 
  	-- Attributes should be displayed in following ORDER:

	--[data FROM Diagnosis field], THEN �:�, [data FROM Test Name field],  THEN �-�, [data FROM Rule Out/Rule In field]

	--NB:IF there are two interpretatiON records that meet abovementiONed criteria AND have the same combinatiON 
	--of the �Diagnosis�, �Test Name�, AND �Rule Out/Rule In� attributes, THEN include ONly ONe combinatiON of 
	--these attributes taken FROM the first interpretatiON record FROM these two records to the text displayed 
	--in the Research result (20) field.

	--Split informatiON taken FROM dIFferent interpretatiON records BY semicolON (;). Do not add semicolON
	-- after the attributes taken FROM the last interpretatiON record.

	--Sort interpretatiON records BY serial numbers of the test names as given in attachment Microbiology 
	--Tests List first, after that sort them BY the Date Interpreted attribute of interpretatiON records, 
	--after that sort them BY the Diagnosis attribute of interpretatiON records in alphabetical ORDER 
	--in current language of the report.

  	cast(	(	
  			SELECT	
  					t.DiagnosisName + 
  					ISNULL(N': ' + t.TestNameName, N'')+ 
  					ISNULL(N' - ' + t.RuleInOutName, N'') + N'; '
  			FROM		
  			(
  					SELECT	top 1 with ties
  							Diagnosis.[name]  as DiagnosisName, 
  							TestName.[name] as TestNameName, 
  							RuleInOut.[name] as RuleInOutName, 
  							ttfcr.intRowORDER, 
  							tv.datInterpretatiONDate
         	 			FROM		tlbTesting testing 
  					INNER JOIN	trtTestTypeForCustomReport ttfcr
  					ON		ttfcr.idfsTestName = testing.idfsTestName
  					AND		ttfcr.intRowStatus = 0
  					AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  				    
  					INNER JOIN trtBaseReferenceAttribute tbra
						INNER JOIN trtAttributeType tat
  						ON tat.idfAttributeType = tbra.idfAttributeType
  						AND tat.strAttributeTypeName = 'Test Sub-type'  					
  					ON tbra.idfsBaseReference = ttfcr.idfsTestName
  					AND cast(tbra.varValue as NVARCHAR(100)) in ('Bacteriology', 'Microscopy', 'Virology', 'PCR', 'Other')
  			      				    
  					INNER JOIN	tlbTestValidatiON tv
  					ON		testing.idfTesting = tv.idfTesting
  					AND		tv.blnValidateStatus = 1
  					AND		tv.intRowStatus = 0
  						    
  					LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000019) Diagnosis
  					ON			tv.idfsDiagnosis = Diagnosis.idfsReference
  		            
  					LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000097) TestName
  					ON			testing.idfsTestName=TestName.idfsReference
  		        
  					LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000106) RuleInOut
  					ON			tv.idfsInterpretedStatus = RuleInOut.idfsReference
  					WHERE
  						testing.idfMaterial = m.idfMaterial
  						AND testing.blnNONLaboratoryTest = 0
  						AND testing.blnExternalTest = 0     
  						AND testing.blnReadONly = 0       
  						AND testing.intRowStatus = 0
  					ORDER BY row_number() over(partitiON BY Diagnosis.[name], TestName.[name], RuleInOut.[name] ORDER BY ttfcr.intRowORDER, tv.datInterpretatiONDate, Diagnosis.[name])
  			)	as t
  	     	ORDER BY t.intRowORDER, t.datInterpretatiONDate, t.DiagnosisName
  			for	xml path('')
  			) as NVARCHAR(max)
  		)	as strResearchResult, --20
    
 	-- 21 strResearchCONductedBy
  	cast(	(	SELECT 
  				 ISNULL(t.strFirstName + ' ', '') + ISNULL(t.strFamilyName, '') + N', '
         	 	FROM
         	 	(
         	 			SELECT top 1 with ties
         	 				prcb.strFirstName,
         	 				prcb.strFamilyName,
         	 				ttfcr.intRowORDER, 
         	 				tv.datInterpretatiONDate, 
         	 				Diagnosis.[name] as DiagnosisName
  					FROM tlbTesting testing 
  					INNER JOIN	trtTestTypeForCustomReport ttfcr
  					ON		ttfcr.idfsTestName = testing.idfsTestName
  					AND		ttfcr.intRowStatus = 0
  					AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  
    				INNER JOIN trtBaseReferenceAttribute tbra
						INNER JOIN trtAttributeType tat
  						ON tat.idfAttributeType = tbra.idfAttributeType
  						AND tat.strAttributeTypeName = 'Test Sub-type'  	    				
  					ON tbra.idfsBaseReference = ttfcr.idfsTestName
  					AND cast(tbra.varValue as NVARCHAR(100)) in ('Bacteriology', 'Microscopy', 'Virology', 'PCR', 'Other')
  					
  					INNER JOIN dbo.tlbTestValidatiON tv
  					ON		testing.idfTesting = tv.idfTesting
  					AND		tv.blnValidateStatus = 1
  					AND		tv.intRowStatus = 0
  
  					LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000019) Diagnosis
  					ON		tv.idfsDiagnosis = Diagnosis.idfsReference
  		        
  					LEFT JOIN	( tlbEmployee ercb
  							INNER JOIN	tlbPersON prcb
  							ON			prcb.idfPersON = ercb.idfEmployee
  					)
  					ON		ercb.idfEmployee = tv.idfInterpretedByPersON
  					AND		ercb.intRowStatus = 0	
  						          			    
  					WHERE testing.idfMaterial = m.idfMaterial
  						AND testing.intRowStatus = 0
  						AND testing.blnNONLaboratoryTest = 0
  						AND testing.blnExternalTest = 0    	
  						AND testing.blnReadONly = 0    			
  					ORDER BY row_number() over(partitiON BY prcb.strFirstName, prcb.strFamilyName ORDER BY ttfcr.intRowORDER, tv.datInterpretatiONDate, Diagnosis.[name])
  
         	 	) as t
         	 	ORDER BY t.intRowORDER, t.datInterpretatiONDate, t.DiagnosisName
  			for	xml path('')
  			) as NVARCHAR(max)
  		)	as strResearchCONductedBy, --21
    
 	-- 22	strRespONsiblePersON
  	cast(	(	SELECT 
  				ISNULL(t.strFirstName + ' ', '') + ISNULL(t.strFamilyName, '') + N', '
         	 	FROM
         	 	(	
  			SELECT top 1 with ties
  				 prcb.strFirstName,
  				 prcb.strFamilyName,
  				 ttfcr.intRowORDER, 
  				 tv.datInterpretatiONDate,
  				 Diagnosis.[name] as DiagnosisName
  			FROM	tlbTesting testing 
  			INNER JOIN trtTestTypeForCustomReport ttfcr
  			ON		ttfcr.idfsTestName = testing.idfsTestName
  			AND		ttfcr.intRowStatus = 0
  			AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  
			INNER JOIN trtBaseReferenceAttribute tbra
						INNER JOIN trtAttributeType tat
  						ON tat.idfAttributeType = tbra.idfAttributeType
  						AND tat.strAttributeTypeName = 'Test Sub-type'  	    				
			ON tbra.idfsBaseReference = ttfcr.idfsTestName
			AND cast(tbra.varValue as NVARCHAR(100)) in ('Bacteriology', 'Microscopy', 'Virology', 'PCR', 'Other')
  					
  			INNER JOIN dbo.tlbTestValidatiON tv
  			ON		testing.idfTesting = tv.idfTesting
  			AND		tv.intRowStatus = 0
  			AND		tv.blnValidateStatus = 1
  			
  			LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000019) Diagnosis
  			ON			tv.idfsDiagnosis = Diagnosis.idfsReference
  			
  			LEFT JOIN	(tlbEmployee ercb
  						INNER JOIN	tlbPersON prcb
  						ON			prcb.idfPersON = ercb.idfEmployee
  						)
  			ON		ercb.idfEmployee = tv.idfValidatedByPersON
  			AND ercb.intRowStatus = 0				    
          WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0    
  				AND testing.blnReadONly = 0    			        
  				AND testing.intRowStatus = 0
  		ORDER BY row_number() over(partitiON BY prcb.strFirstName, prcb.strFamilyName ORDER BY ttfcr.intRowORDER, tv.datInterpretatiONDate, Diagnosis.[name])
         	) as t
         	
        ORDER BY t.intRowORDER, t.datInterpretatiONDate, t.DiagnosisName
  		for	xml path('')
  		) as NVARCHAR(max)
  		)	as strRespONsiblePersON, --22
    
 	-- 23 	datResultIssueDate
 	(	SELECT top 1 
  			tv.datInterpretatiONDate
  		FROM tlbTesting testing 
  		INNER JOIN	trtTestTypeForCustomReport ttfcr
  		ON		ttfcr.idfsTestName = testing.idfsTestName
  		AND		ttfcr.intRowStatus = 0
  		AND		ttfcr.idfsCustomReportType = @idfsCustomReportType
  
  		INNER JOIN	dbo.tlbTestValidatiON tv
  		ON		testing.idfTesting = tv.idfTesting
  		AND		tv.blnValidateStatus = 1
  		AND		tv.intRowStatus = 0
  
          WHERE testing.idfMaterial = m.idfMaterial
  				AND testing.blnNONLaboratoryTest = 0
  				AND testing.blnExternalTest = 0   
  				AND testing.blnReadONly = 0     		        
  				AND testing.intRowStatus = 0
          ORDER BY tv.datInterpretatiONDate desc
      ) as datResultIssueDate -- 23
                               
  FROM	tlbMaterial m
  	INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000087) ref_st	-- Sample Type
  	ON			ref_st.idfsReference = m.idfsSampleType
  	
  	LEFT JOIN	report.FN_REP_InstitutionRepair(@LangID) mcb
  	ON			mcb.idfOffice = m.idfFieldCollectedByOffice
  	
  	LEFT JOIN	dbo.FN_GBL_Department(@LangID) dep
  	ON			dep.idfDepartment = m.idfInDepartment
  	
    INNER JOIN	( tlbHumanCase hc
  				LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID, 19000042) ref_age	-- Human Age Type
  				ON			ref_age.idfsReference = hc.idfsHumanAgeType
  				LEFT JOIN	dbo.FN_GBL_ReferenceRepair(@LangID,19000019) ref_diag_c
  				ON			ISNULL(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis) = ref_diag_c.idfsReference
  				)
  	ON		hc.idfHumanCase = m.idfHumanCase
  	AND		hc.intRowStatus = 0
  	
  	INNER JOIN	tlbHuman h
  	ON		h.idfHuman = m.idfHuman
  	AND		h.intRowStatus = 0
  WHERE   
	m.strBarcode = @SampleID
	AND m.idfsSite = @SiteID
	AND ((h.strLastName like @LastName + '%') OR ISNULL(@LastName, N'') = N'')
	AND ((h.strFirstName like @FirstName + '%') OR ISNULL(@FirstName, N'') = N'')
	AND EXISTS (
		SELECT *
		FROM tlbTesting testing 
			INNER JOIN trtTestTypeForCustomReport ttfcr
			ON		ttfcr.idfsTestName = testing.idfsTestName
			AND		ttfcr.intRowStatus = 0
			AND		ttfcr.idfsCustomReportType = @idfsCustomReportType

			LEFT JOIN	dbo.tlbTestValidatiON tv
			ON		testing.idfTesting = tv.idfTesting
			AND		tv.intRowStatus = 0
			AND tv.blnValidateStatus = 1
	  WHERE testing.idfMaterial = m.idfMaterial
			AND testing.blnNONLaboratoryTest = 0
			AND testing.blnExternalTest = 0
			AND testing.blnReadONly = 0    
			AND testing.intRowStatus = 0    
	)
  
  
	update	@ReportTABLE
	SET		strOther = SUBSTRING(LTRIM(rtrim(strOther)), 0, LEN(LTRIM(rtrim(strOther))))
	WHERE	LTRIM(rtrim(strOther)) like N'%;'
	  
	update	@ReportTABLE
	SET		strResearchResult = SUBSTRING(LTRIM(rtrim(strResearchResult)), 0, LEN(LTRIM(rtrim(strResearchResult))))
	WHERE	LTRIM(rtrim(strResearchResult)) like N'%;'

	update	@ReportTABLE
	SET		strResearchCONductedBy = SUBSTRING(LTRIM(rtrim(strResearchCONductedBy)), 0, LEN(LTRIM(rtrim(strResearchCONductedBy))))
	WHERE	LTRIM(rtrim(strResearchCONductedBy)) like N'%,'
	
	update	@ReportTABLE
	SET		strRespONsiblePersON = SUBSTRING(LTRIM(rtrim(strRespONsiblePersON)), 0, LEN(LTRIM(rtrim(strRespONsiblePersON))))
	WHERE	LTRIM(rtrim(strRespONsiblePersON)) like N'%,'  
  
  
  
	IF not EXISTS (SELECT * FROM @ReportTABLE)
	BEGIN
	INSERT into @ReportTABLE (strSiteName, strSiteAddress)
	VALUES  (@strOfficeName, @strOfficeLocatiON)
	END

  
	SELECT * 
	FROM @ReportTABLE
 
 


