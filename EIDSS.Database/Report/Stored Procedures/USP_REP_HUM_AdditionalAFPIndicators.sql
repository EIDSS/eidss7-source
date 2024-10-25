

--##SUMMARY This procedure returns resultset for Main indicators of AFP surveillance report

--##REMARKS Author: 
--##REMARKS CREATE date: 

--##REMARKS UPDATED BY: Vorobiev E. --deleted tlbCase
--##REMARKS Date: 22.04.2013

--##RETURNS Don't use 

/*
--Example of a call of procedure:

exec report.USP_REP_HUM_AdditionalAFPIndicators 'en', '20140101', '20161231'

*/ 
 
CREATE PROCEDURE [Report].[USP_REP_HUM_AdditionalAFPIndicators]
(
	 @LangID		AS NVARCHAR(50),
	 @SD			AS DATETIME, 
	 @ED			AS DATETIME
)
AS	

	DECLARE 
		@CountryID BIGINT,
		@idfsLanguage BIGINT,
		@idfsCustomReportType BIGINT,

		@idfsSample_FecesStool BIGINT,
		@idfsRegionBaku BIGINT,
		@idfsRegionOtherRayons BIGINT,
		@idfsRegionNakhichevanAR BIGINT,
		@FFP_Date_of_onset_of_paralysis   BIGINT,
		@FFP_Hastheclinicalexamination BIGINT,
		@FFP_DateOfFinalClassification BIGINT,
		@FFP_NumberOfVaccineDoses_SupplementaryImmunization   BIGINT,
		@FFP_NumberOfVaccineDoses_RoutineImmunization   BIGINT


		
	SET @CountryID = 170000000	
	SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)		
	SET @idfsCustomReportType =  10290007
  
	--7721770000000 --Feces-Stool
	SELECT @idfsSample_FecesStool = tbra.idfsBaseReference
	FROM trtBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'Sample type'
		
		INNER JOIN trtBaseReferenceAttribute tbra2
			INNER JOIN trtAttributeType tat2
			ON tat2.idfAttributeType = tbra2.idfAttributeType
			AND tat2.strAttributeTypeName = 'attr_part_in_report'
		ON tbra.idfsBaseReference = tbra2.idfsBaseReference
		AND tbra2.varValue = @idfsCustomReportType 
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Feces-Stool'
	
	--print '@idfsSample_FecesStool' + CAST(@idfsSample_FecesStool AS varchar(20))
	--1344330000000 --Baku
	SELECT @idfsRegionBaku = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Baku'

	--1344340000000 --Other rayons
	SELECT @idfsRegionOtherRayons = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Other rayons'


	--1344350000000 --Nakhichevan AR
	SELECT @idfsRegionNakhichevanAR = tbra.idfsGISBaseReference
	FROM trtGISBaseReferenceAttribute tbra
		INNER JOIN	trtAttributeType at
		ON			at.strAttributeTypeName = N'AZ Region'
	WHERE CAST(tbra.varValue AS NVARCHAR(100)) = N'Nakhichevan AR'    
    

    --Flexible Form Type = �Human Clinical Signs� AND Tooltip = �Acute Flaccid Paralysis-Date of onset of paralysis�.
    SELECT @FFP_Date_of_onset_of_paralysis = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Date_of_onset_of_paralysis'
	AND intRowStatus = 0
    
    --Flexible Form Type = �Human Epi Investigations� AND Tooltip = �Acute Flaccid Paralysis-Follow up clinical examination at 60 days-Has the clinical examination of the patient been conducted� 
 	SELECT @FFP_Hastheclinicalexamination = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Hastheclinicalexamination'
	AND intRowStatus = 0
	
	--Flexible Form Type = �Human Epi Investigations� AND Tooltip = �Acute Flaccid Paralysis-AFP Final Classification-Date of final classification� 
 	SELECT @FFP_DateOfFinalClassification = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_DateOfFinalClassification'
	AND intRowStatus = 0
  
    --Flexible Form Type = �Human Epi Investigations� AND 
    --Tooltip 1 = �Acute Flaccid Paralysis-Vaccination status-Number of vaccine doses received through routine immunization� AND 
 	SELECT @FFP_NumberOfVaccineDoses_RoutineImmunization = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_NumberOfVaccineDoses_RoutineImmunization'
	AND intRowStatus = 0 	
	
 	--Tooltip 2 = �Acute Flaccid Paralysis-Vaccination status-Number of vaccine doses received through supplementary immunizationAcute �
 	SELECT @FFP_NumberOfVaccineDoses_SupplementaryImmunization = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_NumberOfVaccineDoses_SupplementaryImmunization'
	AND intRowStatus = 0
 
	
  
	DECLARE @ReportTable TABLE
	(
		idfsRegion BIGINT NOT NULL,
		idfsRayon BIGINT NOT NULL,
		strRegion NVARCHAR(200) NOT NULL,
		strRayon NVARCHAR(200) NOT NULL,
		intTotal INT,
		int7DayNotification INT,
		int2DayRegistration INT,
		int2FaecalSpecimen INT,
		intPositiveEnterovirus INT,
		intFollowUpInvestigation INT,
		intFinalClassification INT,
		intOPVDoses INT,
		intRegionOrder INT
	)
  
	INSERT INTO @ReportTable
	(
		idfsRegion,
		idfsRayon,
		strRegion,
		strRayon,
		intRegionOrder
	)
	SELECT
		ray.idfsRegion,
		ray.idfsRayon,

		ISNULL(gsnt_reg.strTextString, gbr_reg.strDefault),
		ISNULL(gsnt_ray.strTextString, gbr_ray.strDefault),


		CASE ray.idfsRegion
		  WHEN @idfsRegionBaku			--Baku
		  THEN 1
	      
		  WHEN @idfsRegionOtherRayons	--Other rayons
		  THEN 2
	      
		  WHEN @idfsRegionNakhichevanAR --Nakhichevan AR
		  THEN 3
	      
		  else 0
		end AS intRegionOrder
  
	FROM report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) ray
		INNER JOIN gisRegion reg
		ON ray.idfsRegion = reg.idfsRegion
		AND reg.intRowStatus = 0
		AND reg.idfsCountry = @CountryID

		INNER JOIN gisBaseReference gbr_reg
		ON gbr_reg.idfsGISBaseReference = reg.idfsRegion
		AND gbr_reg.intRowStatus = 0

		INNER JOIN dbo.gisStringNameTranslation gsnt_reg
		ON gsnt_reg.idfsGISBaseReference = gbr_reg.idfsGISBaseReference
		AND gsnt_reg.idfsLanguage = @idfsLanguage
		AND gsnt_reg.intRowStatus = 0

		INNER JOIN gisBaseReference gbr_ray
		ON gbr_ray.idfsGISBaseReference = ray.idfsRayon
		AND gbr_ray.intRowStatus = 0

		INNER JOIN dbo.gisStringNameTranslation gsnt_ray
		ON gsnt_ray.idfsGISBaseReference = gbr_ray.idfsGISBaseReference
		AND gsnt_ray.idfsLanguage = @idfsLanguage
		AND gsnt_ray.intRowStatus = 0
	WHERE ray.intRowStatus = 0


	DECLARE @DiagnosisTable TABLE
	(
		idfsDiagnosis BIGINT NOT NULL PRIMARY KEY
	)

	INSERT INTO @DiagnosisTable
	(
		idfsDiagnosis
	)
	SELECT 
		fdt.idfsDiagnosisOrReportDiagnosisGroup
	FROM  dbo.trtReportRows fdt
	  INNER JOIN trtDiagnosis trtd
	  ON trtd.idfsDiagnosis = fdt.idfsDiagnosisOrReportDiagnosisGroup AND
	  trtd.intRowStatus = 0
	WHERE  fdt.idfsCustomReportType = @idfsCustomReportType 



	DECLARE	@ReportCaseTable	TABLE
	(	
		idfCase					BIGINT NOT NULL PRIMARY KEY,
		idfsRegion				BIGINT NOT NULL,
		idfsRayon				BIGINT NOT NULL,
		Is7DayNotification		BIT NOT NULL DEFAULT(0),
		Is2DayRegistration		BIT NOT NULL DEFAULT(0),
		Is2FaecalSpecimen		BIT NOT NULL DEFAULT(0),
		IsFollowUpInvestigation	BIT NOT NULL DEFAULT(0),
		IsFinalClassification	BIT NOT NULL DEFAULT(0),
		IsOPVDoses				BIT NOT NULL DEFAULT(0)
	)
	



	INSERT INTO	@ReportCaseTable
	(	
		idfCase,
		idfsRegion,
		idfsRayon,
		Is7DayNotification,
		Is2DayRegistration
	)
	SELECT DISTINCT
		hc.idfHumanCase AS idfCase,
		gl.idfsRegion,  
		gl.idfsRayon,  
		CASE WHEN hc.datNotificationDate - CAST(tap.varValue AS DATETIME) <= 7 THEN 1 else 0 end,
		CASE WHEN hc.datInvestigationStartDate - hc.datNotificationDate <= 2 THEN 1 else 0 end
	FROM tlbHumanCase hc
		INNER JOIN tlbHuman h
			INNER  JOIN tlbGeoLocation gl
			ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
		ON hc.idfHuman = h.idfHuman AND
		   h.intRowStatus = 0

		INNER JOIN	@ReportTable fdt
		ON	fdt.idfsRegion = gl.idfsRegion
		AND fdt.idfsRayon = gl.idfsRayon
		
		INNER JOIN @DiagnosisTable dt
		ON dt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

		INNER JOIN tlbObservation obs
			INNER JOIN tlbActivityParameters tap
			ON tap.idfObservation = obs.idfObservation
			AND tap.intRowStatus = 0
			AND tap.idfsParameter = @FFP_Date_of_onset_of_paralysis
			AND (
					CAST(SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
					(CAST(SQL_VARIANT_PROPERTY(tap.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(tap.varValue AS NVARCHAR)) = 1 )	
				)  
		ON	obs.idfObservation = hc.idfCSObservation
			AND obs.intRowStatus = 0	
	  			
		LEFT JOIN tstSite ts
		ON ts.idfsSite = hc.idfsSite
		AND ts.intRowStatus = 0
		AND ts.intFlags = 1
  			
	WHERE		(@SD <= CAST(tap.varValue AS DATETIME) AND CAST(tap.varValue AS DATETIME) < DATEADD(day, 1, @ED)) 
				AND ts.idfsSite is NULL
				AND hc.intRowStatus = 0 
				AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed CASE*/

	UPDATE rct SET
	rct.Is2FaecalSpecimen = 1
	FROM @ReportCaseTable rct
	WHERE exists
      (
          SELECT  *
          FROM @ReportCaseTable  rct1
            INNER JOIN tlbMaterial m
            ON m.idfHumanCase = rct1.idfCase
            AND m.idfsSampleType = @idfsSample_FecesStool --7721770000000 --Feces-Stool
            AND m.intRowStatus = 0
            
            INNER JOIN tlbHumanCase hc
				INNER JOIN tlbObservation obs_hc
					INNER JOIN tlbActivityParameters tap_hc
					ON tap_hc.idfObservation = obs_hc.idfObservation
					AND tap_hc.intRowStatus = 0
					AND tap_hc.idfsParameter = @FFP_Date_of_onset_of_paralysis
					AND (
							CAST(SQL_VARIANT_PROPERTY(tap_hc.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
							(CAST(SQL_VARIANT_PROPERTY(tap_hc.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(tap_hc.varValue AS NVARCHAR)) = 1 )	
						)  
				ON	obs_hc.idfObservation = hc.idfCSObservation AND obs_hc.intRowStatus = 0
            ON hc.idfHumanCase = rct1.idfCase
            AND m.datFieldCollectionDate - CAST(tap_hc.varValue AS DATETIME) <=  14 
            
            INNER JOIN (
              SELECT rct2.idfCase, m2.datFieldCollectionDate
              FROM @ReportCaseTable  rct2
                  INNER JOIN tlbMaterial m2
                    ON m2.idfHumanCase = rct2.idfCase
                    AND m2.idfsSampleType = @idfsSample_FecesStool--7721770000000 --Feces-Stool
                    AND m2.intRowStatus = 0
                  
                  INNER JOIN tlbHumanCase hc2
						INNER JOIN tlbObservation obs_hc2
							INNER JOIN tlbActivityParameters tap_hc2
							ON tap_hc2.idfObservation = obs_hc2.idfObservation
							AND tap_hc2.intRowStatus = 0
							AND tap_hc2.idfsParameter = @FFP_Date_of_onset_of_paralysis
							AND (
									CAST(SQL_VARIANT_PROPERTY(tap_hc2.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
									(CAST(SQL_VARIANT_PROPERTY(tap_hc2.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(tap_hc2.varValue AS NVARCHAR)) = 1 )	
								)  
						ON	obs_hc2.idfObservation = hc2.idfCSObservation AND obs_hc2.intRowStatus = 0
                    ON hc2.idfHumanCase = rct2.idfCase
                    AND m2.datFieldCollectionDate - CAST(tap_hc2.varValue AS DATETIME) <=  14 
            
            ) AS rct2_m2
            ON rct2_m2.idfCase = rct1.idfCase
            AND rct2_m2.datFieldCollectionDate - m.datFieldCollectionDate < 2
            
          WHERE 
            rct.idfCase = rct1.idfCase
      )


	
	UPDATE rct SET
		rct.IsFollowUpInvestigation = 1
	FROM @ReportCaseTable rct
	WHERE exists
	  (
		  SELECT  *
		  FROM @ReportCaseTable  rct1
			INNER JOIN tlbHumanCase hc
			ON hc.idfHumanCase = rct1.idfCase
	        
			INNER JOIN tlbObservation obs
			ON obs.idfObservation = hc.idfEpiObservation
			AND obs.intRowStatus = 0
	        
			INNER JOIN dbo.tlbActivityParameters ap
				  INNER JOIN	dbo.ffParameter p
					ON	p.idfsParameter = ap.idfsParameter
					  AND p.intRowStatus = 0 
					  AND p.idfsParameter = @FFP_Hastheclinicalexamination
			ON ap.idfObservation = obs.idfObservation
			AND ap.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') = 'BIGINT'
			AND CAST(ap.varValue AS BIGINT) = 25460000000--217140000000 -- Yes
		  WHERE 
			rct.idfCase = rct1.idfCase
	  )


	UPDATE rct SET
		rct.IsFinalClassification = 1
	FROM @ReportCaseTable rct
	WHERE exists
	  (
		  SELECT  *
		  FROM @ReportCaseTable  rct1
			INNER JOIN tlbHumanCase hc
			ON hc.idfHumanCase = rct1.idfCase
	        
	        INNER JOIN tlbObservation obs_hc
				INNER JOIN tlbActivityParameters tap_hc
				ON tap_hc.idfObservation = obs_hc.idfObservation
				AND tap_hc.intRowStatus = 0
				AND tap_hc.idfsParameter = @FFP_Date_of_onset_of_paralysis
				AND (CAST(SQL_VARIANT_PROPERTY(tap_hc.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
						(CAST(SQL_VARIANT_PROPERTY(tap_hc.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(tap_hc.varValue AS NVARCHAR)) = 1 )	)  
			ON	obs_hc.idfObservation = hc.idfCSObservation
				AND obs_hc.intRowStatus = 0	
			
			INNER JOIN tlbObservation obs
			ON obs.idfObservation = hc.idfEpiObservation
			AND obs.intRowStatus = 0
	        
			INNER JOIN dbo.tlbActivityParameters ap
				  INNER JOIN	dbo.ffParameter p
					ON	p.idfsParameter = ap.idfsParameter
					  AND p.intRowStatus = 0 
					  AND p.idfsParameter = @FFP_DateOfFinalClassification
			ON ap.idfObservation = obs.idfObservation
			AND ap.intRowStatus = 0
			AND (CAST(SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') AS NVARCHAR) like N'%date%' or
						(CAST(SQL_VARIANT_PROPERTY(ap.varValue, 'BaseType') AS NVARCHAR) like N'%char%' AND ISDATE(CAST(ap.varValue AS NVARCHAR)) = 1 )	) 
	      
		  WHERE 
			rct.idfCase = rct1.idfCase
			AND CAST(ap.varValue AS DATETIME) - CAST(tap_hc.varValue AS DATETIME) <= 90
	  )
      
      
	UPDATE rct SET
		rct.IsOPVDoses  = 1
	FROM @ReportCaseTable rct
	WHERE exists
	  (
		  SELECT  *
		  FROM @ReportCaseTable  rct1
			INNER JOIN tlbHumanCase hc
			ON hc.idfHumanCase = rct1.idfCase
	        
			INNER JOIN tlbObservation obs
			ON obs.idfObservation = hc.idfEpiObservation
			AND obs.intRowStatus = 0
	        
			LEFT JOIN dbo.tlbActivityParameters ap
				  INNER JOIN	dbo.ffParameter p
					ON	p.idfsParameter = ap.idfsParameter
					  AND p.intRowStatus = 0 
					  AND p.idfsParameter = @FFP_NumberOfVaccineDoses_SupplementaryImmunization
			ON ap.idfObservation = obs.idfObservation
			AND ap.intRowStatus = 0
			AND (isnumeric( CAST(ap.varValue AS varchar(20))) =1 AND CAST(ap.varValue AS varchar(20)) NOT in ('.', ','))
	        
			LEFT JOIN dbo.tlbActivityParameters ap1
				  INNER JOIN	dbo.ffParameter p1
					ON	p1.idfsParameter = ap1.idfsParameter
					  AND p1.intRowStatus = 0 
					  AND p1.idfsParameter = @FFP_NumberOfVaccineDoses_RoutineImmunization
			ON ap1.idfObservation = obs.idfObservation
			AND ap1.intRowStatus = 0
			AND (isnumeric( CAST(ap1.varValue AS varchar(20))) =1 AND CAST(ap.varValue AS varchar(20)) NOT in ('.', ','))
	        
	      
		  WHERE 
			rct.idfCase = rct1.idfCase
			AND (
				  CAST(ap.varValue AS INT) is NOT NULL or 
				  CAST(ap1.varValue AS INT) is NOT NULL
				)
			AND ISNULL(CAST(ap.varValue AS INT) , 0)  +  ISNULL(CAST(ap1.varValue AS INT), 0) < 3
			AND
			CASE
					  WHEN	hc.idfsHumanAgeType =  10042003	--Years
							AND (hc.intPatientAge >= 0 AND hc.intPatientAge <= 150)
						THEN	hc.intPatientAge
					    
					  WHEN	hc.idfsHumanAgeType = 10042002 /*'hatMonth'*/
							AND hc.intPatientAge >= 0
						THEN hc.intPatientAge / 12
					    
					  WHEN	hc.idfsHumanAgeType = 10042001 /*'hatDays'*/
							AND hc.intPatientAge >= 0
						THEN  0
					  else	NULL
				  end >= 0.2  AND 
				  CASE
					  WHEN	hc .idfsHumanAgeType =  10042003	--Years
							AND (hc.intPatientAge >= 0 AND hc.intPatientAge <= 150)
						THEN	hc.intPatientAge
					    
					  WHEN	hc.idfsHumanAgeType = 10042002 /*'hatMonth'*/
							AND hc.intPatientAge >= 0
						THEN hc.intPatientAge / 12
					    
					  WHEN	hc.idfsHumanAgeType = 10042001 /*'hatDays'*/
							AND hc.intPatientAge >= 0
						THEN  0
					  else	NULL
				  end <= 5
	  )



    
    


  --Total
  DECLARE	@ReportCaseDiagnosisTotalValuesTable	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(fct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable fct
  GROUP BY	fct.idfsRegion, fct.idfsRayon



  --7DayNotification
  DECLARE	@ReportCaseDiagnosisTotalValuesTable_7DayNotification	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable_7DayNotification
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(rct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable rct
  WHERE rct.Is7DayNotification = 1
  GROUP BY	rct.idfsRegion, rct.idfsRayon


  --2DayRegistration
  DECLARE	@ReportCaseDiagnosisTotalValuesTable_2DayRegistration	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable_2DayRegistration
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(rct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable rct
  WHERE rct.Is2DayRegistration = 1
  GROUP BY	rct.idfsRegion, rct.idfsRayon


  --2FaecalSpecimen
  DECLARE	@ReportCaseDiagnosisTotalValuesTable_2FaecalSpecimen	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable_2FaecalSpecimen
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(rct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable rct
  WHERE rct.Is2FaecalSpecimen = 1
  GROUP BY	rct.idfsRegion, rct.idfsRayon



  --FollowUpInvestigation
  DECLARE	@ReportCaseDiagnosisTotalValuesTable_FollowUpInvestigation	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable_FollowUpInvestigation
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(rct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable rct
  WHERE rct.IsFollowUpInvestigation = 1
  GROUP BY	rct.idfsRegion, rct.idfsRayon


  --FinalClassification
  DECLARE	@ReportCaseDiagnosisTotalValuesTable_FinalClassification	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable_FinalClassification
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(rct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable rct
  WHERE rct.IsFinalClassification = 1
  GROUP BY	rct.idfsRegion, rct.idfsRayon


  --OPVDoses
  DECLARE	@ReportCaseDiagnosisTotalValuesTable_OPVDoses	TABLE
  (	
	  intTotal		INT NOT NULL,
	  idfsRegion BIGINT NOT NULL,
	  idfsRayon BIGINT NOT NULL
  )

  INSERT INTO	@ReportCaseDiagnosisTotalValuesTable_OPVDoses
  (	
	  intTotal,
	  idfsRegion,
	  idfsRayon
  )
  SELECT 
			  COUNT(rct.idfCase),
			  idfsRegion,
			  idfsRayon
  FROM		@ReportCaseTable rct
  WHERE rct.IsOPVDoses = 1
  GROUP BY	rct.idfsRegion, rct.idfsRayon
  
  


  -- UPDATE @ReportTable
  UPDATE		rt
  SET			rt.intTotal = fcdvt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable fcdvt
  ON			fcdvt.idfsRegion = rt.idfsRegion
      AND fcdvt.idfsRayon = rt.idfsRayon
  	   
  UPDATE		rt
  SET			rt.int7DayNotification = rtt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable_7DayNotification rtt
  ON			rtt.idfsRegion = rt.idfsRegion
      AND rtt.idfsRayon  = rt.idfsRayon
  	   
  UPDATE		rt
  SET			rt.int2DayRegistration = rtt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable_2DayRegistration rtt
  ON			rtt.idfsRegion = rt.idfsRegion
      AND rtt.idfsRayon  = rt.idfsRayon  	   
  	   
  UPDATE		rt
  SET			rt.int2FaecalSpecimen = rtt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable_2FaecalSpecimen rtt
  ON			rtt.idfsRegion = rt.idfsRegion
      AND rtt.idfsRayon  = rt.idfsRayon  	   
  	   
  UPDATE		rt
  SET			rt.intFollowUpInvestigation = rtt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable_FollowUpInvestigation rtt
  ON			rtt.idfsRegion = rt.idfsRegion
      AND rtt.idfsRayon  = rt.idfsRayon  	    	   
  	   
  UPDATE		rt
  SET			rt.intFinalClassification = rtt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable_FinalClassification rtt
  ON			rtt.idfsRegion = rt.idfsRegion
      AND rtt.idfsRayon  = rt.idfsRayon  	    	   
  	   
  UPDATE		rt
  SET			rt.intOPVDoses = rtt.intTotal
  FROM		@ReportTable rt
  INNER JOIN	@ReportCaseDiagnosisTotalValuesTable_OPVDoses rtt
  ON			rtt.idfsRegion = rt.idfsRegion
      AND rtt.idfsRayon  = rt.idfsRayon  	    	   
  	     
  	   
  SELECT   	   
    strRegion,
    strRayon,
    intTotal,
    int7DayNotification,
    int2DayRegistration,
    int2FaecalSpecimen,
    intPositiveEnterovirus,
    intFollowUpInvestigation,
    intFinalClassification,
    intOPVDoses,
    intRegionOrder  	   
 FROM @ReportTable   
 
