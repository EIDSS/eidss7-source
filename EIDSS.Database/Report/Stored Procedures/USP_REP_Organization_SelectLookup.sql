--*************************************************************************
-- Name: report.USP_REP_Organization_SelectLookup
--
-- Description: To Get the Organization List 
--          
-- Author: Srini Goli
--
-- Revision History:
-- Name			       Date       Change Detail
-- ------------------- ---------- ----------------------------------------
-- Stephen Long        05/08/2023 Changed from institution repair to min.
--
-- Testing code:
/*
--Example of procedure call:
EXEC report.USP_REP_Organization_SelectLookup 'en', NULL
EXEC report.USP_REP_Organization_SelectLookup 'en', 1152
*/
CREATE PROCEDURE [Report].[USP_REP_Organization_SelectLookup]
	@LangID AS NVARCHAR(50),	--##PARAM @LangID - language ID
	@ID AS BIGINT = NULL		--##PARAM @ID - organization ID, if not null only record with this organization is selected
AS
	DECLARE @CountryID BIGINT
	DECLARE @ReportTable TABLE   
	(  
		idfInstitution BIGINT PRIMARY KEY NOT NULL,   
		Name NVARCHAR(200),
		intRowStatus INT
	)  
  
BEGIN	
	SELECT	@CountryID= tcp1.idfsCountry
 	FROM	dbo.tstCustomizationPackage tcp1
	JOIN	dbo.tstSite s ON
		s.idfCustomizationPackage = tcp1.idfCustomizationPackage
 	INNER JOIN	dbo.tstLocalSiteOptions lso
 	ON		lso.strName = N'SiteID'
 			AND lso.strValue = CAST(s.idfsSite AS NVARCHAR(20))
 	
 	INSERT INTO @ReportTable 
 	SELECT 0 AS idfInstitution
 			,'' AS [name]
 			,0 AS intRowStatus	
 	UNION ALL			
	SELECT ts.idfsSite AS idfInstitution
		   ,fir.AbbreviatedName AS [name]
		   ,fir.intRowStatus
	FROM dbo.tstSite ts
	JOIN dbo.tstCustomizationPackage tcpac on
		tcpac.idfCustomizationPackage = ts.idfCustomizationPackage
	JOIN dbo.FN_GBL_Institution_Min(@LangID) fir	
		ON fir.idfOffice = ts.idfOffice
		and tcpac.idfsCountry = @CountryID
--		and ts.intFlags = 1
	JOIN dbo.trtBaseReference tbr1
	ON tbr1.idfsBaseReference = fir.idfsOfficeAbbreviation  
	
	SELECT idfInstitution
			,[name]
			,intRowStatus
	FROM @ReportTable
	WHERE idfInstitution = ISNULL(@ID, idfInstitution)
    ORDER BY [name]
END