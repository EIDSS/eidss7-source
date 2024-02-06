


-- This stored proc is to be used the report:
--
--	Veterinary
--
--  Mark Wilson updated for EIDSS7 standards
--  Procedure Renamed by Srini

/*
Example of a procedure call:
EXEC report.USP_REP_VET_YearlySituation 'en',2016
EXEC report.USP_REP_VET_YearlySituation 'ka',2016
*/ 

-------------------------------------------------------------------------------------------

CREATE PROCEDURE [Report].[USP_REP_VET_YearlySituation]
(
	@LangID NVARCHAR(50),
	@Year INT,
	@UserID NVARCHAR = NULL,
	@UseArchiveData	AS BIT = 0 --if User selected Use Archive Data then 1
)
AS
	
	-- Table for Yearly totals
	DECLARE @TotalTable TABLE
	(
	  strDiagnosis NVARCHAR(200),
	  intTotal INT
	)

	-- Table for Monthly totals
	DECLARE @MonthlyTable TABLE
	(
	  strDiagnosis NVARCHAR(200),
	  intMonth INT,
	  intCount INT
	)
	-- Insert to yearly table
	INSERT INTO @TotalTable	

	SELECT 
		DiagnosisName AS strDiagnosis,
		COUNT(idfsShowDiagnosis) AS intCount
	FROM report.FN_REP_VetCase_Get(@LangID, NULL) 

	WHERE MONTH (DateOfRecord) IS NOT NULL
	AND idfsShowDiagnosis IS NOT NULL
	AND YEAR (DateOfRecord) = @Year

	GROUP BY DiagnosisName
	
	IF (SELECT COUNT(*) FROM @TotalTable) = 0
	INSERT INTO @TotalTable
	SELECT '' as strDiagnosis,
			NULL as intCount
	 

	-- Insert to monthly table
	INSERT INTO @MonthlyTable	

	SELECT  
		DiagnosisName AS strDiagnosis,
		MONTH(DateOfRecord) AS intMonth,
		COUNT(idfsShowDiagnosis) AS intCount 

	FROM report.FN_REP_VetCase_Get(@LangID, NULL)

	WHERE YEAR(DateOfRecord) = @Year
	GROUP BY 
		MONTH(DateOfRecord), 
		DiagnosisName

	SELECT	
		total.strDiagnosis AS Disease, 
		tJan.intCount AS Jan,
		tFeb.intCount AS Feb,
		tMar.intCount AS Mar,
		tApr.intCount AS Apr,
		tMay.intCount AS May,
		tJun.intCount AS Jun,
		tJul.intCount AS Jul,
		tAug.intCount AS Aug,
		tSep.intCount AS Sep,
		tOct.intCount AS Oct,
		tNov.intCount AS Nov,
		tDec.intCount AS Dec,
		total.intTotal AS Total

	FROM @TotalTable AS total
	LEFT JOIN @MonthlyTable tJan ON total.strDiagnosis = tJan.strDiagnosis AND tJan.intMonth = 1
	LEFT JOIN @MonthlyTable tFeb ON total.strDiagnosis = tFeb.strDiagnosis AND tFeb.intMonth = 2
	LEFT JOIN @MonthlyTable tMar ON total.strDiagnosis = tMar.strDiagnosis AND tMar.intMonth = 3
	LEFT JOIN @MonthlyTable tApr ON total.strDiagnosis = tApr.strDiagnosis AND tApr.intMonth = 4
	LEFT JOIN @MonthlyTable tMay ON total.strDiagnosis = tMay.strDiagnosis AND tMay.intMonth = 5
	LEFT JOIN @MonthlyTable tJun ON total.strDiagnosis = tJun.strDiagnosis AND tJun.intMonth = 6
	LEFT JOIN @MonthlyTable tJul ON total.strDiagnosis = tJul.strDiagnosis AND tJul.intMonth = 7
	LEFT JOIN @MonthlyTable tAug ON total.strDiagnosis = tAug.strDiagnosis AND tAug.intMonth = 8
	LEFT JOIN @MonthlyTable tSep ON total.strDiagnosis = tSep.strDiagnosis AND tSep.intMonth = 9
	LEFT JOIN @MonthlyTable tOct ON total.strDiagnosis = tOct.strDiagnosis AND tOct.intMonth = 10
	LEFT JOIN @MonthlyTable tNov ON total.strDiagnosis = tNov.strDiagnosis AND tNov.intMonth = 11
	LEFT JOIN @MonthlyTable tDec ON total.strDiagnosis = tDec.strDiagnosis AND tDec.intMonth = 12


