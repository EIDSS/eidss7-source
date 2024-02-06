

--*************************************************************************
-- Name 				: report.USP_REP_HUM_FormN1InfectiousDiseases_IntrahospitalInfections
-- Description			: This procedure returns Intrahospital Infections data set for Form N1 for both A4 and A3 Format Reports
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_HUM_FormN1InfectiousDiseases_IntrahospitalInfections 'en', 2014, 1, 12
EXEC report.USP_REP_HUM_FormN1InfectiousDiseases_IntrahospitalInfections 'en', 2016, 1, 12, null, null, 868
*/


CREATE PROCEDURE [Report].[USP_REP_HUM_FormN1InfectiousDiseases_IntrahospitalInfections]
	@LangID				AS VARCHAR(36),
	@Year				AS INT, 
	@StartMonth			AS INT = null,
	@EndMonth			AS INT = null,
	@RegionID			AS BIGINT = null,
	@RayonID			AS BIGINT = null,
	@OrganizationID		AS BIGINT = null
	
AS
BEGIN

	EXEC dbo.spSetFirstDay

	DECLARE	@ReportTable	TABLE
	(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
		intRowNumber		INT NULL, --1
		strDiseaseName		NVARCHAR(300) COLLATE database_default NOT NULL, --2
		strICD10			NVARCHAR(200) COLLATE database_default NULL,	--3
		intTotal			INT NOT NULL, --4
		intOrder			INT NOT NULL
	)


  DECLARE 		
	@StartDate				DATETIME,	 
	@FinishDate				DATETIME,
	@idfsCustomReportType	BIGINT,
	@idfsLanguage			BIGINT,
	@FFP_Total				BIGINT,
	@CountryID				BIGINT
	  
	  
	SET	@CountryID = 170000000  
	SET @idfsCustomReportType = 10290031	--AZ Form #1 - Intrahospital infections


	SELECT @FFP_Total = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Total'
	AND intRowStatus = 0

	--Transport CHE
 	DECLARE @TransportCHE BIGINT
 
 	SELECT @TransportCHE = frr.idfsReference
 	FROM report.FN_GBL_GIS_ReferenceRepair_GET('en', 19000020) frr
 	WHERE frr.name =  'Transport CHE'
		
			
			
	SET @idfsLanguage = report.FN_GBL_LanguageCode_GET (@LangID)		
			
	IF @StartMonth IS NULL
	BEGIN
		SET @StartDate = (CAST(@Year AS VARCHAR(4)) + '01' + '01')
		SET @FinishDate = dateADD(yyyy, 1, @StartDate)
	END
	ELSE
	BEGIN	
	  IF @StartMonth < 10	
			SET @StartDate = (CAST(@Year AS VARCHAR(4)) + '0' +CAST(@StartMonth AS VARCHAR(2)) + '01')
	  ELSE				
			SET @StartDate = (CAST(@Year AS VARCHAR(4)) + CAST(@StartMonth AS VARCHAR(2)) + '01')
			
	  IF (@EndMonth IS NULL) or (@StartMonth = @EndMonth)
			SET @FinishDate = dateADD(mm, 1, @StartDate)
	  ELSE	BEGIN
			IF @EndMonth < 10	
				SET @FinishDate = (CAST(@Year AS VARCHAR(4)) + '0' +CAST(@EndMonth AS VARCHAR(2)) + '01')
			ELSE				
				SET @FinishDate = (CAST(@Year AS VARCHAR(4)) + CAST(@EndMonth AS VARCHAR(2)) + '01')
				
			SET @FinishDate = DATEADD(mm, 1, @FinishDate)
			END
	END		

	INSERT INTO @ReportTable (
		idfsBaseReference,
		intRowNumber,
		strDiseaseName,
		strICD10,
		intTotal,
		intOrder
	) 
	SELECT 
	  rr.idfsDiagnosisOrReportDiagnosisGroup,
	  CASE
		WHEN	ISNULL(br.idfsReferenceType, -1) = 19000130	-- Diagnosis Group
				AND ISNULL(br.strDefault, N'') = N'Total'
			THEN	null
		ELSE	rr.intRowOrder
	  END,
	  CASE
		WHEN	ISNULL(br.idfsReferenceType, -1) = 19000130	-- Diagnosis Group
				AND ISNULL(br.strDefault, N'') = N'Total'
			THEN	ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault) + N'*'
		ELSE	ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault)
	  END,
	  ISNULL(d.strIDC10, dg.strCode),
	  0,
	  rr.intRowOrder
	FROM   dbo.trtReportRows rr
		LEFT JOIN trtBaseReference br
			LEFT JOIN trtStringNameTranslation snt
			ON br.idfsBaseReference = snt.idfsBaseReference
				AND snt.idfsLanguage = @idfsLanguage
			LEFT OUTER JOIN trtDiagnosis d
			ON br.idfsBaseReference = d.idfsDiagnosis
			LEFT OUTER JOIN trtReportDiagnosisGroup dg
			ON br.idfsBaseReference = dg.idfsReportDiagnosisGroup
		ON rr.idfsDiagnosisOrReportDiagnosisGroup = br.idfsBaseReference
	   
		LEFT OUTER JOIN trtBaseReference br1
			LEFT OUTER JOIN trtStringNameTranslation snt1
			ON br1.idfsBaseReference = snt1.idfsBaseReference
				AND snt1.idfsLanguage = @idfsLanguage
		ON rr.idfsReportAdditionalText = br1.idfsBaseReference
	    

	WHERE rr.idfsCustomReportType = @idfsCustomReportType
			AND rr.intRowStatus = 0
	ORDER BY rr.intRowOrder  



	DECLARE	@Form1DiagnosisTable	TABLE
	(	idfsDiagnosis		BIGINT NOT NULL PRIMARY KEY,
		blnIsAggregate		BIT,
		intTotal			INT NOT NULL
	)

	INSERT INTO @Form1DiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal
	) 
	SELECT DISTINCT
	  fdt.idfsDiagnosis,
	  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
	  END,
	  0

	FROM dbo.trtDiagnosisToGroupForReportType fdt
		INNER JOIN trtDiagnosis trtd
		ON trtd.idfsDiagnosis = fdt.idfsDiagnosis
	WHERE  fdt.idfsCustomReportType = @idfsCustomReportType 

	       
	INSERT INTO @Form1DiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal
	) 
	SELECT DISTINCT
	  trtd.idfsDiagnosis,
	  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
	  END,
	  0

	FROM dbo.trtReportRows rr
		INNER JOIN trtBaseReference br
		ON	br.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
			AND br.idfsReferenceType = 19000019 --'rftDiagnosis'
			AND br.intRowStatus = 0
	    INNER JOIN   dbo.trtBaseReferenceToCP br_tc
			INNER JOIN tstCustomizationPackage cp
			on cp.idfCustomizationPackage = br_tc.idfCustomizationPackage
			AND  cp.idfsCountry = @CountryID
	    ON br_tc.idfsBaseReference = br.idfsBaseReference
		INNER JOIN trtDiagnosis trtd
		ON trtd.idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup 
	WHERE  rr.idfsCustomReportType = @idfsCustomReportType 
		   AND  rr.intRowStatus = 0 
		   AND NOT EXISTS 
		   (
			   SELECT * FROM @Form1DiagnosisTable
			   WHERE idfsDiagnosis = rr.idfsDiagnosisOrReportDiagnosisGroup
		   )      


DECLARE @MinAdminLevel BIGINT
DECLARE @MinTimeInterval BIGINT
DECLARE @AggrCaseType BIGINT

/*

19000091	rftStatisticPeriodType:
    10091001	sptMonth	Month
    10091002	sptOnday	Day
    10091003	sptQuarter	Quarter
    10091004	sptWeek	Week
    10091005	sptYear	Year

19000089	rftStatisticAreaType
    10089001	satCountry	Country
    10089002	satRayon	Rayon
    10089003	satRegion	Region
    10089004	satSettlement	Settlement


19000102	rftAggregateCaseType:
    10102001  Aggregate Case

*/

SET @AggrCaseType = 10102001

SELECT	@MinAdminLevel = idfsStatisticAreaType,
		@MinTimeInterval = idfsStatisticPeriodType
FROM report.FN_GBL_AggregateSettings_GET (@AggrCaseType)--@AggrCaseType

DECLARE	@Form1HumanAggregateCase	TABLE
(	idfAggrCase	BIGINT NOT NULL PRIMARY KEY,
	idfCaseObservation BIGINT,
	datStartDate DATETIME,
	idfVersion BIGINT
)


INSERT INTO	@Form1HumanAggregateCase
(	idfAggrCase,
  idfCaseObservation,
  datStartDate,
  idfVersion
)
SELECT	  a.idfAggrCase,
          a.idfCaseObservation,
          a.datStartDate,
		  a.idfVersion
FROM		tlbAggrCase a
	LEFT JOIN	report.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000001 /*Country*/) c
	ON			c.idfsReference = a.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Region_GET(@LangID, 19000003 /*Region*/) r
	ON			r.idfsRegion = a.idfsAdministrativeUnit 
	LEFT JOIN	report.FN_GBL_GIS_Rayon_GET(@LangID, 19000002 /*Rayon*/) rr
	ON			rr.idfsRayon = a.idfsAdministrativeUnit
	LEFT JOIN	report.FN_GBL_GIS_Settlement_GET(@LangID, 19000004 /*Settlement*/) s
	ON			s.idfsSettlement = a.idfsAdministrativeUnit
	LEFT JOIN tstSite ts
	ON			ts.idfsSite = a.idfsAdministrativeUnit
				AND ts.idfCustomizationPackage = 51577410000000 /*Azerbaijan*/
				AND ts.intRowStatus = 0
				AND ts.intFlags = 1	
WHERE 			
			a.idfsAggrCaseType = @AggrCaseType
			AND (	@StartDate <= a.datStartDate
					AND a.datFinishDate < @FinishDate
				)
			AND (	(	@MinTimeInterval = 10091005 --'sptYear'
						AND DateDiff(year, a.datStartDate, a.datFinishDate) = 0
						AND DateDiff(quarter, a.datStartDate, a.datFinishDate) > 1
					)
					OR	(	@MinTimeInterval = 10091003 --'sptQuarter'
							AND DateDiff(quarter, a.datStartDate, a.datFinishDate) = 0
							AND DateDiff(month, a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091001 --'sptMonth'
							AND DateDiff(month, a.datStartDate, a.datFinishDate) = 0
							AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091004 --'sptWeek'
							AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0
							AND DateDiff(day, a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091002--'sptOnday'
						AND DateDiff(day, a.datStartDate, a.datFinishDate) = 0)
				)    
			AND (	
        			(	@MinAdminLevel = 10089001 --'satCountry' 
						AND a.idfsAdministrativeUnit = c.idfsReference
						AND @OrganizationID IS NULL
		      )
		    OR	(	@MinAdminLevel = 10089003 --'satRegion' 
				    AND a.idfsAdministrativeUnit = r.idfsRegion
				    AND (r.idfsRegion = @RegionID OR @RegionID IS NULL)
					AND (@OrganizationID IS NULL)
			    )
		    OR	(	@MinAdminLevel = 10089002 --'satRayon' 
				    AND a.idfsAdministrativeUnit = rr.idfsRayon
				    AND (rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
				    AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
					AND (@OrganizationID IS NULL)
			    )
		    OR	(	@MinAdminLevel = 10089004 --'satSettlement' 
				    AND a.idfsAdministrativeUnit = s.idfsSettlement
				    AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
				    AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
					AND (@OrganizationID IS NULL)
			    )
				OR	(
		    			a.idfsAdministrativeUnit = ts.idfsSite
						AND (ts.idfsSite = @OrganizationID or @OrganizationID IS NULL)
						AND @RayonID IS NULL
						AND @RegionID IS NULL
	      )
			 )

  AND a.intRowStatus = 0


DECLARE	@Form1AggregateDiagnosisValuesTable	TABLE
(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
	intTotal			INT NOT NULL
)


INSERT INTO	@Form1AggregateDiagnosisValuesTable
(	idfsBaseReference,
	intTotal
)
SELECT		
      fdt.idfsDiagnosis,
	  SUM(ISNULL(CAST(agp_Total.varValue AS INT), 0))

FROM		@Form1HumanAggregateCase fhac
-- Updated for version 6
			
-- Matrix version
INNER JOIN	tlbAggrMatrixVersionHeader h
ON			h.idfsMatrixType = 71190000000	-- Human Aggregate Case
			AND (	-- Get matrix version selected by the user in aggregate case
					h.idfVersion = fhac.idfVersion 
					-- If matrix version is not selected by the user in aggregate case, 
					-- then select active matrix with the latest date activation that is earlier than aggregate case start date
					OR (	fhac.idfVersion IS NULL 
							AND	h.datStartDate <= fhac.datStartDate
							AND	h.blnIsActive = 1
							AND NOT EXISTS	(
										SELECT	*
										FROM	tlbAggrMatrixVersionHeader h_later
										WHERE	h_later.idfsMatrixType = 71190000000	-- Human Aggregate Case
												AND	h_later.datStartDate <= fhac.datStartDate
												AND	h_later.blnIsActive = 1
												AND h_later.intRowStatus = 0
												AND	h_later.datStartDate > h.datStartDate
						)
						))
			AND h.intRowStatus = 0
			
-- Matrix row
INNER JOIN	tlbAggrHumanCaseMTX mtx
ON			mtx.idfVersion = h.idfVersion
			AND mtx.intRowStatus = 0
INNER JOIN	@Form1DiagnosisTable fdt
ON			fdt.idfsDiagnosis = mtx.idfsDiagnosis        

        
        
--	Total		
LEFT JOIN	dbo.tlbActivityParameters agp_Total
ON			agp_Total.idfObservation= fhac.idfCaseObservation
			AND	agp_Total.idfsParameter = @FFP_Total
			AND agp_Total.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Total.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Total.varValue, 'BaseType') IN  ('bigint','decimal','float','int','numeric','real','smallint','tinyint')
			
GROUP BY	fdt.idfsDiagnosis

DECLARE	@Form1CaseTable	TABLE
(	idfsDiagnosis		BIGINT NOT NULL,
	idfCase				BIGINT NOT NULL PRIMARY KEY,
	intYear				int NULL,
	idfsHumanGender		BIGINT,
	idfsRegion			BIGINT,
	idfsRayon			BIGINT
)


INSERT INTO	@Form1CaseTable
(	idfsDiagnosis,
	idfCase,
	idfsRegion,
	idfsRayon
)
SELECT DISTINCT
			fdt.idfsDiagnosis,
			hc.idfHumanCase AS idfCase,
			CASE WHEN ts.idfsSite is NOT NULL THEN @TransportCHE /*Transport CHE*/ ELSE  gl.idfsRegion END,  /*region CR*/
			CASE WHEN ts.idfsSite is NOT NULL THEN ts.idfsSite ELSE gl.idfsRayon  END /*rayon CR*/
			
FROM tlbHumanCase hc     

    INNER JOIN	@Form1DiagnosisTable fdt
    ON			fdt.idfsDiagnosis = COALESCE(hc.idfsFinalDiagnosis, hc.idfsTentativeDiagnosis)

    INNER JOIN tlbHuman h
        LEFT OUTER JOIN tlbGeoLocation gl
        ON h.idfCurrentResidenceAddress = gl.idfGeoLocation AND gl.intRowStatus = 0
      ON hc.idfHuman = h.idfHuman AND
         h.intRowStatus = 0
      
			
    LEFT JOIN tstSite ts
    ON ts.idfsSite = hc.idfsSite
    AND ts.intRowStatus = 0
    AND ts.intFlags = 1
    			
WHERE		hc.datFinalCaseClassificationDate is NOT NULL AND
			(	@StartDate <= hc.datFinalCaseClassificationDate
				AND hc.datFinalCaseClassificationDate < @FinishDate				
			) AND
			(gl.idfsRegion = @RegionID AND ts.idfsSite IS NULL or @RegionID IS NULL) AND
			(gl.idfsRayon = @RayonID AND ts.idfsSite IS NULL OR @RayonID IS NULL) AND
			(ts.idfsSite = @OrganizationID or @OrganizationID IS NULL)

			AND hc.intRowStatus = 0 
			-- Cases should only be seleced for the report Final Case Classification = Confirmed
			-- updated 22.05.2012 by Romasheva S.
			AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/

--Total
DECLARE	@Form1CaseDiagnosisTotalValuesTable	TABLE
(	idfsDiagnosis	BIGINT NOT NULL PRIMARY KEY,
	intTotal		INT NOT NULL
)

INSERT INTO	@Form1CaseDiagnosisTotalValuesTable
(	idfsDiagnosis,
	intTotal
)
SELECT fct.idfsDiagnosis,
			count(fct.idfCase)
FROM		@Form1CaseTable fct
GROUP BY	fct.idfsDiagnosis

		

--aggregate cases
UPDATE		fdt
SET				
	fdt.intTotal = fadvt.intTotal
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1AggregateDiagnosisValuesTable fadvt
ON			fadvt.idfsBaseReference = fdt.idfsDiagnosis
		
		
		
		

--standard cases
UPDATE		fdt
SET			fdt.intTotal = ISNULL(fdt.intTotal, 0) + fcdvt.intTotal
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosisTotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
	
		



DECLARE	@Form1DiagnosisGroupTable	TABLE
(	idfsDiagnosisGroup	BIGINT NOT NULL PRIMARY KEY,
	intTotal			INT NOT NULL
)


INSERT INTO	@Form1DiagnosisGroupTable
(	idfsDiagnosisGroup,
	intTotal
)
SELECT		dtg.idfsReportDiagnosisGroup,
	    SUM(intTotal)
FROM		@Form1DiagnosisTable fdt
INNER JOIN	dbo.trtDiagnosisToGroupForReportType dtg
ON			dtg.idfsDiagnosis = fdt.idfsDiagnosis
			AND dtg.idfsCustomReportType = @idfsCustomReportType

GROUP BY	dtg.idfsReportDiagnosisGroup	


UPDATE		ft
SET	
  ft.intTotal = fdt.intTotal

FROM		@ReportTable ft
INNER JOIN	@Form1DiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
  ft.intTotal = fdgt.intTotal
FROM		@ReportTable ft
INNER JOIN	@Form1DiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference			
		
		
		
	SELECT * 
	FROM @ReportTable
	ORDER BY intOrder

END


