

--*************************************************************************
-- Name 				: report.USP_REP_HUM_FormN1InfectiousDiseases
-- DescriptiON			: This procedure returns Header (Page 1) for Form N1 for both A4 and A3 Format Reports
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_HUM_FormN1InfectiousDiseases 'en', 2016, 1, 12
EXEC report.USP_REP_HUM_FormN1InfectiousDiseases 'en', 2012, 1, 12, null, null, 868
*/
 
CREATE PROCEDURE [Report].[USP_REP_HUM_FormN1InfectiousDiseases]
	@LangID				AS VARCHAR(36),
	@Year				AS INT, 
	@StartMonth			AS INT = NULL,
	@EndMonth			AS INT = NULL,
	@RegionID			AS BIGINT = NULL,
	@RayonID			AS BIGINT = NULL,
	@OrganizationID		AS BIGINT = NULL
	
AS
BEGIN

	EXEC dbo.USP_GBL_FIRSTDAY_SET

	DECLARE	@ReportTable	TABLE
	(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
		intRowNumber		INT NULL, --1
		strDiseaseName		NVARCHAR(300) collate database_default NOT NULL, --2
		strICD10			NVARCHAR(200) collate database_default null,	--3
		intTotal			INT NOT NULL, --4
		intWomen			INT NOT NULL, --5
		intAge_0_17			INT NOT NULL, --6
		intAge_0_1			INT NOT NULL, --7
		intAge_1_4			INT NOT NULL, --8
		intAge_5_13			INT NOT NULL, --9
		intAge_14_17		INT NOT NULL, --10
		intAge_18_more		INT NOT NULL, --11
		intRuralTotal		INT NOT NULL, --12
		intRuralAge_0_17	INT NOT NULL, --13
		intOrder			INT NOT NULL
	)


  DECLARE 		
	@StartDate				DATETIME,	 
	@FinishDate				DATETIME,
	@idfsCustomReportType	BIGINT,
	@idfsLanguage			BIGINT,

	@FFP_Total			BIGINT,
	@FFP_Women			BIGINT,
	@FFP_Age_0_17		BIGINT,
	@FFP_Age_0_1		BIGINT,
	@FFP_Age_1_4		BIGINT,
	@FFP_Age_5_13		BIGINT,
	@FFP_Age_14_17		BIGINT,
	@FFP_Age_18_more	BIGINT,
	@FFP_RuralTotal		BIGINT,
	@FFP_RuralAge_0_17	BIGINT,
	
	@CountryID			BIGINT
	  
	  
	SET	@CountryID = 170000000  
	SET @idfsCustomReportType = 10290000 /*Form number 1*/

	-- added 22.05.2012 by Romasheva S.
	SELECT @FFP_Total = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType and strFFObjectAlias = 'FFP_Total'
	AND intRowStatus = 0

	SELECT @FFP_Women = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Women'
	AND intRowStatus = 0
	
	SELECT @FFP_Age_0_17 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_0_17'
	AND intRowStatus = 0
	
	SELECT @FFP_Age_0_1 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_0_1'
	AND intRowStatus = 0

	SELECT @FFP_Age_1_4 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_1_4'
	AND intRowStatus = 0
	  
	SELECT @FFP_Age_5_13 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_5_13'
	AND intRowStatus = 0
	  
	SELECT @FFP_Age_14_17 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_14_17'
	AND intRowStatus = 0
	  
	SELECT @FFP_Age_18_more = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_Age_18_more'
	AND intRowStatus = 0
	  
	SELECT @FFP_RuralTotal = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_RuralTotal'
	AND intRowStatus = 0
	  
	SELECT @FFP_RuralAge_0_17 = idfsFFObject FROM trtFFObjectForCustomReport
	WHERE idfsCustomReportType = @idfsCustomReportType AND strFFObjectAlias = 'FFP_RuralAge_0_17'
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
		intWomen,
		intAge_0_17,
		intAge_0_1,
		intAge_1_4,
		intAge_5_13,
		intAge_14_17,
		intAge_18_more,
		intRuralTotal,
		intRuralAge_0_17,
		intOrder
	) 
	SELECT 
	  rr.idfsDiagnosisOrReportDiagnosisGroup,
	  CASE
		WHEN ISNULL(br.idfsReferenceType, -1) = 19000130	-- Diagnosis Group
				AND ISNULL(br.strDefault, N'') = N'Total'
			THEN NULL
		ELSE rr.intRowOrder
	  END,
	  CASE
		WHEN ISNULL(br.idfsReferenceType, -1) = 19000130	-- Diagnosis Group
				AND ISNULL(br.strDefault, N'') = N'Total'
			THEN ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault) + N'*'
		ELSE ISNULL(ISNULL(snt1.strTextString, br1.strDefault) +  N' ', N'') + ISNULL(snt.strTextString, br.strDefault)
	  END,
	  ISNULL(d.strIDC10, dg.strCode),
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
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
		intTotal			INT NOT NULL,
		intWomen			INT NOT NULL,
		intAge_0_17			INT NOT NULL,
		intAge_0_1			INT NOT NULL,
		intAge_1_4			INT NOT NULL,
		intAge_5_13			INT NOT NULL,
		intAge_14_17		INT NOT NULL,
		intAge_18_more		INT NOT NULL,
		intRuralTotal		INT NOT NULL,
		intRuralAge_0_17	INT NOT NULL
	)

	INSERT INTO @Form1DiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal,
		intWomen,
		intAge_0_17,
		intAge_0_1,
		intAge_1_4,
		intAge_5_13,
		intAge_14_17,
		intAge_18_more,
		intRuralTotal,
		intRuralAge_0_17
	) 
	SELECT DISTINCT
	  fdt.idfsDiagnosis,
	  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
	  END,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0

	FROM dbo.trtDiagnosisToGroupForReportType fdt
		INNER JOIN trtDiagnosis trtd
		ON trtd.idfsDiagnosis = fdt.idfsDiagnosis
	WHERE  fdt.idfsCustomReportType = @idfsCustomReportType 

	       
	INSERT INTO @Form1DiagnosisTable (
		idfsDiagnosis,
		blnIsAggregate,
		intTotal,
		intWomen,
		intAge_0_17,
		intAge_0_1,
		intAge_1_4,
		intAge_5_13,
		intAge_14_17,
		intAge_18_more,
		intRuralTotal,
		intRuralAge_0_17
	) 
	SELECT DISTINCT
	  trtd.idfsDiagnosis,
	  CASE WHEN  trtd.idfsUsingType = 10020002  --dutAggregatedCase
		THEN 1
		ELSE 0
	  END,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0,
	  0

	FROM dbo.trtReportRows rr
		INNER JOIN trtBaseReference br
		ON	br.idfsBaseReference = rr.idfsDiagnosisOrReportDiagnosisGroup
			AND br.idfsReferenceType = 19000019 --'rftDiagnosis'
			AND br.intRowStatus = 0
	    INNER JOIN   dbo.trtBaseReferenceToCP br_tc
			inner join tstCustomizationPackage cp
			ON cp.idfCustomizationPackage = br_tc.idfCustomizationPackage
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
(	
  idfAggrCase,
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
						AND DATEDIFF(YEAR, a.datStartDate, a.datFinishDate) = 0
						AND DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) > 1
					)
					OR (	@MinTimeInterval = 10091003 --'sptQuarter'
							AND DATEDIFF(QUARTER, a.datStartDate, a.datFinishDate) = 0
							AND DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091001 --'sptMonth'
							AND DATEDIFF(MONTH, a.datStartDate, a.datFinishDate) = 0
							AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091004 --'sptWeek'
							AND report.FN_GBL_WeekDateDiff_GET(a.datStartDate, a.datFinishDate) = 0
							AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) > 1
						)
					OR (	@MinTimeInterval = 10091002--'sptOnday'
						AND DATEDIFF(DAY, a.datStartDate, a.datFinishDate) = 0)
				)    
			AND (	
        			(	@MinAdminLevel = 10089001 --'satCountry' 
						AND a.idfsAdministrativeUnit = c.idfsReference
						AND @OrganizationID IS NULL
		      )
		    OR (	@MinAdminLevel = 10089003 --'satRegion' 
				    AND a.idfsAdministrativeUnit = r.idfsRegion
				    AND (r.idfsRegion = @RegionID OR @RegionID IS NULL)
					AND (@OrganizationID IS NULL)
			    )
		    OR (	@MinAdminLevel = 10089002 --'satRayon' 
				    AND a.idfsAdministrativeUnit = rr.idfsRayon
				    AND (rr.idfsRayon = @RayonID OR @RayonID IS NULL) 
				    AND (rr.idfsRegion = @RegionID OR @RegionID IS NULL)
					AND (@OrganizationID IS NULL)
			    )
		    OR (	@MinAdminLevel = 10089004 --'satSettlement' 
				    AND a.idfsAdministrativeUnit = s.idfsSettlement
				    AND (s.idfsRayon = @RayonID OR @RayonID IS NULL) 
				    AND (s.idfsRegion = @RegionID OR @RegionID IS NULL)
					AND (@OrganizationID IS NULL)
			    )
				OR (
		    			a.idfsAdministrativeUnit = ts.idfsSite
						AND (ts.idfsSite = @OrganizationID OR @OrganizationID IS NULL)
						AND @RayonID IS NULL
						AND @RegionID IS NULL
	      )
			 )

  AND a.intRowStatus = 0


DECLARE	@Form1AggregateDiagnosisValuesTable	TABLE
(	idfsBaseReference	BIGINT NOT NULL PRIMARY KEY,
	intTotal			INT NOT NULL,
	intWomen			INT NOT NULL,
	intAge_0_17			INT NOT NULL,
	intAge_0_1			INT NOT NULL,
	intAge_1_4			INT NOT NULL,
	intAge_5_13			INT NOT NULL,
	intAge_14_17		INT NOT NULL,
	intAge_18_more		INT NOT NULL,
	intRuralTotal		INT NOT NULL,
	intRuralAge_0_17	INT NOT NULL)


 


INSERT INTO @Form1AggregateDiagnosisValuesTable
(	idfsBaseReference,
	intTotal,
	intWomen,
	intAge_0_17,
	intAge_0_1,
	intAge_1_4,
	intAge_5_13,
	intAge_14_17,
	intAge_18_more,
	intRuralTotal,
	intRuralAge_0_17
)
SELECT		
      fdt.idfsDiagnosis      ,
			SUM(ISNULL(CAST(agp_Total.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Women.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Age_0_17.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Age_0_1.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Age_1_4.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Age_5_13.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Age_14_17.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_Age_18_more.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_RuralTotal.varValue AS INT), 0)),
			SUM(ISNULL(CAST(agp_RuralAge_0_17.varValue AS INT), 0))

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
			AND SQL_VARIANT_PROPERTY(agp_Total.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			
--	Women		
LEFT JOIN	dbo.tlbActivityParameters agp_Women
ON			agp_Women.idfObservation= fhac.idfCaseObservation
			AND	agp_Women.idfsParameter = @FFP_Women
			AND agp_Women.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Women.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Women.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')
			
--	Age_0_17		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_0_17
ON			agp_Age_0_17.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_0_17.idfsParameter = @FFP_Age_0_17
			AND agp_Age_0_17.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_0_17.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_0_17.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

--	Age_0_1		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_0_1
ON			agp_Age_0_1.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_0_1.idfsParameter = @FFP_Age_0_1
			AND agp_Age_0_1.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_0_1.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_0_1.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

			
--	Age_1_4		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_1_4
ON			agp_Age_1_4.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_1_4.idfsParameter = @FFP_Age_1_4
			AND agp_Age_1_4.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_1_4.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_1_4.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

			
--	Age_5_13		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_5_13
ON			agp_Age_5_13.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_5_13.idfsParameter = @FFP_Age_5_13
			AND agp_Age_5_13.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_5_13.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_5_13.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

			
--	Age_14_17		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_14_17
ON			agp_Age_14_17.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_14_17.idfsParameter = @FFP_Age_14_17
			AND agp_Age_14_17.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_14_17.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_14_17.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')



--	Age_18_more		
LEFT JOIN	dbo.tlbActivityParameters agp_Age_18_more
ON			agp_Age_18_more.idfObservation = fhac.idfCaseObservation
			AND	agp_Age_18_more.idfsParameter = @FFP_Age_18_more
			AND agp_Age_18_more.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_Age_18_more.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_Age_18_more.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')



--	RuralTotal		
LEFT JOIN	dbo.tlbActivityParameters agp_RuralTotal
ON			agp_RuralTotal.idfObservation = fhac.idfCaseObservation
			AND	agp_RuralTotal.idfsParameter = @FFP_RuralTotal
			AND agp_RuralTotal.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_RuralTotal.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_RuralTotal.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')



--	RuralAge_0_17		
LEFT JOIN	dbo.tlbActivityParameters agp_RuralAge_0_17
ON			agp_RuralAge_0_17.idfObservation = fhac.idfCaseObservation
			AND	agp_RuralAge_0_17.idfsParameter = @FFP_RuralAge_0_17
			AND agp_RuralAge_0_17.idfRow = mtx.idfAggrHumanCaseMTX
			AND agp_RuralAge_0_17.intRowStatus = 0
			AND SQL_VARIANT_PROPERTY(agp_RuralAge_0_17.varValue, 'BaseType') in  ('BIGINT','decimal','float','int','numeric','real','smallint','tinyint')

GROUP BY	fdt.idfsDiagnosis

DECLARE @Form1CaseTable	TABLE
(	idfsDiagnosis		BIGINT  NOT NULL,
	idfCase				BIGINT NOT NULL PRIMARY KEY,
	intYear				INT NULL,
	idfsHumanGender		BIGINT,
	idfsRegiON			BIGINT,
	idfsRayON			BIGINT,
	
	idfsRegionAdr		BIGINT,
	idfsRayonAdr		BIGINT
)


INSERT INTO @Form1CaseTable
(	idfsDiagnosis,
	idfCase,
	intYear,
	idfsHumanGender,
	idfsRegion,
	idfsRayon,
	idfsRegionAdr, 
	idfsRayonAdr
)
SELECT DISTINCT
			fdt.idfsDiagnosis,
			hc.idfHumanCase AS idfCase,
			CASE
				WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042003	-- Years 
						AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 200)
					THEN	hc.intPatientAge
				WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042002	-- Months
						AND (ISNULL(hc.intPatientAge, -1) >= 0 AND ISNULL(hc.intPatientAge, -1) <= 60)
					THEN	cast(hc.intPatientAge / 12 AS INT)
				WHEN	ISNULL(hc.idfsHumanAgeType, -1) = 10042001	-- Days
						AND (ISNULL(hc.intPatientAge, -1) >= 0)
					THEN	0
				ELSE	null
			END,			
			
			h.idfsHumanGender, /*gender*/
			CASE WHEN ts.idfsSite is not null THEN @TransportCHE /*Transport CHE*/ ELSE  gl.idfsRegion END,  /*region CR*/
			CASE WHEN ts.idfsSite is not null THEN ts.idfsSite ELSE gl.idfsRayon  END, /*rayon CR*/
			
			gl.idfsRegion,
			gl.idfsRayon
			
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
    			
WHERE		hc.datFinalCaseClassificationDate IS NOT NULL AND
			(	@StartDate <= hc.datFinalCaseClassificationDate
				AND hc.datFinalCaseClassificationDate < @FinishDate				
			) AND
			(gl.idfsRegion = @RegionID and ts.idfsSite IS NULL OR @RegionID IS NULL) AND
			(gl.idfsRayon = @RayonID and ts.idfsSite IS NULL OR @RayonID IS NULL)	AND
			(ts.idfsSite = @OrganizationID OR @OrganizationID IS NULL)

			AND hc.intRowStatus = 0 
			-- Cases should only be seleced for the report Final Case Classification = Confirmed
			-- updated 22.05.2012 by Romasheva S.
			AND hc.idfsFinalCaseStatus = 350000000 /*Confirmed Case*/

--Total
DECLARE @Form1CaseDiagnosisTotalValuesTable	TABLE
(	idfsDiagnosis	BIGINT NOT NULL primary key,
	intTotal		INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosisTotalValuesTable
(	idfsDiagnosis,
	intTotal
)
SELECT fct.idfsDiagnosis,
			count(fct.idfCase)
FROM		@Form1CaseTable fct
GROUP BY	fct.idfsDiagnosis





--Total Women
DECLARE @Form1CaseDiagnosisWomenValuesTable	TABLE
(	idfsDiagnosis	BIGINT NOT NULL PRIMARY KEY,
	intWomen		INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosisWomenValuesTable
(	idfsDiagnosis,
	intWomen
)
SELECT fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE fct.idfsHumanGender = 10043001
group by	fct.idfsDiagnosis



--Total Age_0_17
DECLARE @Form1CaseDiagnosis_Age_0_17_TotalValuesTable	table
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_0_17				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_Age_0_17_TotalValuesTable
(	idfsDiagnosis,
	intAge_0_17
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		(fct.intYear >= 0 and fct.intYear <= 17)
group by	fct.idfsDiagnosis



--Total Age_0_1
DECLARE @Form1CaseDiagnosis_Age_0_1_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_0_1				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_Age_0_1_TotalValuesTable
(	idfsDiagnosis,
	intAge_0_1
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		(fct.intYear >= 0 and fct.intYear < 1)
group by	fct.idfsDiagnosis




--Total Age_1_4
DECLARE @Form1CaseDiagnosis_Age_1_4_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_1_4				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_Age_1_4_TotalValuesTable
(	idfsDiagnosis,
	intAge_1_4
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		(fct.intYear >= 1 and fct.intYear <= 4)
group by	fct.idfsDiagnosis




--Total Age_5_13
DECLARE @Form1CaseDiagnosis_Age_5_13_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_5_13				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_Age_5_13_TotalValuesTable
(	idfsDiagnosis,
	intAge_5_13
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		(fct.intYear >= 5 and fct.intYear <= 13)
group by	fct.idfsDiagnosis



--Total Age_14_17
DECLARE @Form1CaseDiagnosis_Age_14_17_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_14_17				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_Age_14_17_TotalValuesTable
(	idfsDiagnosis,
	intAge_14_17
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		(fct.intYear >= 14 and fct.intYear <= 17)
group by	fct.idfsDiagnosis




--Total Age_18_more
DECLARE @Form1CaseDiagnosis_Age_18_more_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intAge_18_more				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_Age_18_more_TotalValuesTable
(	idfsDiagnosis,
	intAge_18_more
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		(fct.intYear >= 18 )
group by	fct.idfsDiagnosis



--Total RuralTotal
DECLARE @Form1CaseDiagnosis_RuralTotal_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intRuralTotal				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_RuralTotal_TotalValuesTable
(	idfsDiagnosis,
	intRuralTotal
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		
/*EXCEPT:
 If Region=Baku, or 
 if (Region=Nakhichevan AR and Rayon=Nakhichevan) or 
 if (Region=Other rayons and Rayon= Genje or Mingechevir or Naftalan or Shirvan or Sumgayit)
*/
(fct.idfsRegionAdr <> 1344330000000/*Baku*/ ) AND
(fct.idfsRegionAdr <> 1344350000000 AND fct.idfsRayonAdr <> 1345180000000) AND
(fct.idfsRayonAdr NOT IN (1344920000000, 1344830000000, 1344890000000, 1344650000000, 1344470000000))
group by	fct.idfsDiagnosis



--Total RuralAge_0_17
DECLARE @Form1CaseDiagnosis_RuralAge_0_17_TotalValuesTable	TABLE
(	idfsDiagnosis			BIGINT NOT NULL PRIMARY KEY,
	intRuralAge_0_17				INT NOT NULL
)

INSERT INTO @Form1CaseDiagnosis_RuralAge_0_17_TotalValuesTable
(	idfsDiagnosis,
	intRuralAge_0_17
)
SELECT		fct.idfsDiagnosis,
			COUNT(fct.idfCase)
FROM		@Form1CaseTable fct
WHERE		
/*EXCEPT:
 If Region=Baku, or 
 if (Region=Nakhichevan AR and Rayon=Nakhichevan) or 
 if (Region=Other rayons and Rayon= Genje or Mingechevir or Naftalan or Shirvan or Sumgayit)
*/
(fct.intYear >= 0 and fct.intYear <= 17) AND 
(fct.idfsRegionAdr <> 1344330000000/*Baku*/ ) AND
(fct.idfsRegionAdr <> 1344350000000 AND fct.idfsRayonAdr <> 1345180000000) AND
(fct.idfsRayonAdr NOT IN (1344920000000, 1344830000000, 1344890000000, 1344650000000, 1344470000000))
GROUP BY	fct.idfsDiagnosis
		
		
		

--aggregate cases
UPDATE		fdt
SET				
	fdt.intAge_0_17 = fadvt.intAge_0_17,
	fdt.intAge_0_1 = fadvt.intAge_0_1,
	fdt.intAge_1_4 = fadvt.intAge_1_4,	
	fdt.intAge_5_13 = fadvt.intAge_5_13,	
	fdt.intAge_14_17 = fadvt.intAge_14_17,	
	fdt.intAge_18_more = fadvt.intAge_18_more,	
	fdt.intTotal = fadvt.intTotal,	
	fdt.intWomen = fadvt.intWomen,	
	fdt.intRuralTotal = fadvt.intRuralTotal,	
	fdt.intRuralAge_0_17 = fadvt.intRuralAge_0_17		
FROM		@Form1DiagnosisTable fdt
    INNER JOIN	@Form1AggregateDiagnosisValuesTable fadvt
    ON			fadvt.idfsBaseReference = fdt.idfsDiagnosis
		
		
		
		

--standard cases
UPDATE		fdt
SET			fdt.intTotal = ISNULL(fdt.intTotal, 0) + fcdvt.intTotal
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosisTotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
	
		

UPDATE		fdt
SET			fdt.intWomen = ISNULL(fdt.intWomen, 0) + fcdvt.intWomen
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosisWomenValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
	


UPDATE		fdt
SET			fdt.intAge_0_17 = ISNULL(fdt.intAge_0_17, 0) + fcdvt.intAge_0_17
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_Age_0_17_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis



UPDATE		fdt
SET			fdt.intAge_0_1 = ISNULL(fdt.intAge_0_1, 0) + fcdvt.intAge_0_1
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_Age_0_1_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis

		
		
UPDATE		fdt
SET			fdt.intAge_1_4 = ISNULL(fdt.intAge_1_4, 0) + fcdvt.intAge_1_4
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_Age_1_4_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
		


UPDATE		fdt
SET			fdt.intAge_5_13 = ISNULL(fdt.intAge_5_13, 0) + fcdvt.intAge_5_13
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_Age_5_13_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis



UPDATE		fdt
SET			fdt.intAge_14_17 = ISNULL(fdt.intAge_14_17, 0) + fcdvt.intAge_14_17
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_Age_14_17_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis



UPDATE		fdt
SET			fdt.intAge_18_more = ISNULL(fdt.intAge_18_more, 0) + fcdvt.intAge_18_more
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_Age_18_more_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis

		
		
UPDATE		fdt
SET			fdt.intRuralTotal = ISNULL(fdt.intRuralTotal, 0) + fcdvt.intRuralTotal
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_RuralTotal_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
	
		
		
UPDATE		fdt
SET			fdt.intRuralAge_0_17 = ISNULL(fdt.intRuralAge_0_17, 0) + fcdvt.intRuralAge_0_17
FROM		@Form1DiagnosisTable fdt
INNER JOIN	@Form1CaseDiagnosis_RuralAge_0_17_TotalValuesTable fcdvt
ON			fcdvt.idfsDiagnosis = fdt.idfsDiagnosis
		


DECLARE	@Form1DiagnosisGroupTable	TABLE
(	idfsDiagnosisGroup	BIGINT NOT NULL PRIMARY KEY,
	intTotal			INT NOT NULL,
	intWomen			INT NOT NULL,
	intAge_0_17			INT NOT NULL,
	intAge_0_1			INT NOT NULL,
	intAge_1_4			INT NOT NULL,
	intAge_5_13			INT NOT NULL,
	intAge_14_17		INT NOT NULL,
	intAge_18_more		INT NOT NULL,
	intRuralTotal		INT NOT NULL,
	intRuralAge_0_17	INT NOT NULL
)


INSERT INTO @Form1DiagnosisGroupTable
(	idfsDiagnosisGroup,
	intTotal,
	intWomen,
	intAge_0_17,
	intAge_0_1,
	intAge_1_4,
	intAge_5_13,
	intAge_14_17,
	intAge_18_more,
	intRuralTotal,
	intRuralAge_0_17
)
SELECT		dtg.idfsReportDiagnosisGroup,
	    SUM(intTotal),	
	    SUM(intWomen), 
	    SUM(intAge_0_17), 
	    SUM(intAge_0_1), 
	    SUM(intAge_1_4), 
	    SUM(intAge_5_13), 
	    SUM(intAge_14_17), 
	    SUM(intAge_18_more), 
	    SUM(intRuralTotal),		
	    SUM(intRuralAge_0_17)
FROM		@Form1DiagnosisTable fdt
INNER JOIN	dbo.trtDiagnosisToGroupForReportType dtg
ON			dtg.idfsDiagnosis = fdt.idfsDiagnosis
			AND dtg.idfsCustomReportType = @idfsCustomReportType

GROUP BY	dtg.idfsReportDiagnosisGroup	


UPDATE		ft
SET	
  ft.intTotal = fdt.intTotal,	
	ft.intWomen = fdt.intWomen, 
	ft.intAge_0_17 = fdt.intAge_0_17, 
	ft.intAge_0_1 = fdt.intAge_0_1, 
	ft.intAge_1_4 = fdt.intAge_1_4, 
	ft.intAge_5_13 = fdt.intAge_5_13, 
	ft.intAge_14_17 = fdt.intAge_14_17, 
	ft.intAge_18_more = fdt.intAge_18_more, 
	ft.intRuralTotal = fdt.intRuralTotal, 
	ft.intRuralAge_0_17 = fdt.intRuralAge_0_17

FROM		@ReportTable ft
INNER JOIN	@Form1DiagnosisTable fdt
ON			fdt.idfsDiagnosis = ft.idfsBaseReference	
		
		
UPDATE		ft
SET	
  ft.intTotal = fdgt.intTotal,	
	ft.intWomen = fdgt.intWomen, 
	ft.intAge_0_17 = fdgt.intAge_0_17, 
	ft.intAge_0_1 = fdgt.intAge_0_1, 
	ft.intAge_1_4 = fdgt.intAge_1_4, 
	ft.intAge_5_13 = fdgt.intAge_5_13, 
	ft.intAge_14_17 = fdgt.intAge_14_17, 
	ft.intAge_18_more = fdgt.intAge_18_more, 
	ft.intRuralTotal = fdgt.intRuralTotal, 
	ft.intRuralAge_0_17 = fdgt.intRuralAge_0_17
FROM		@ReportTable ft
INNER JOIN	@Form1DiagnosisGroupTable fdgt
ON			fdgt.idfsDiagnosisGroup = ft.idfsBaseReference			
		
		
		
	SELECT * 
	FROM @ReportTable
	ORDER BY intOrder

END


