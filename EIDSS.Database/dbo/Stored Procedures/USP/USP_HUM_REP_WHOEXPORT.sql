


--*************************************************************************
-- Name 				: dbo.USP_HUM_REP_WHOEXPORT
--
-- Description			: SINT03 - WHO Export dbo on Measles and Rubella.
-- 
-- Author               : Mandar Kulkarni
-- Revision History
--		Name			Date		Change Detail
--		Ann Xiong		12/02/2022	Renamed @StartDate, @EndDate, and @idfsDiagnosis to @DateFrom, @DateTo, and @DiseaseID

-- Testing code:
/*
--Example of a call of procedure:
   --GG
   --Measles
   EXEC dbo.[USP_HUM_REP_WHOEXPORT] @LangID=N'en',@StartDate='20130101',@EndDate='20131101', @idfsDiagnosis = 9843460000000
   
   --Rubella   
   EXEC dbo.[USP_HUM_REP_WHOEXPORT] @LangID=N'en',@StartDate='20130101',@EndDate='20131101', @idfsDiagnosis = 9843820000000
   
   --AZ
   --Measles
   EXEC dbo.[USP_HUM_REP_WHOEXPORT] @LangID=N'en',@StartDate='20120101',@EndDate='20131101', @idfsDiagnosis = 7720040000000
   --rubella
   EXEC dbo.[USP_HUM_REP_WHOEXPORT] @LangID=N'en',@StartDate='20130101',@EndDate='20131201', @idfsDiagnosis = 7720770000000

*/
  
CREATE  PROCEDURE [dbo].[USP_HUM_REP_WHOEXPORT]
(
   	@LangID		AS NVARCHAR(50), 
   	@DateFrom DATETIME,
   	@DateTo DATETIME,
   	@DiseaseID BIGINT
)
AS	
   	
BEGIN
    	
	DECLARE @idfsCountry BIGINT
   		
	SELECT	@idfsCountry = tcpac.idfsCountry
	FROM tstCustomizationPackage tcpac
	JOIN tstSite s ON
		s.idfCustomizationPackage = tcpac.idfCustomizationPackage
	JOIN tstLocalSiteOptions lso ON
		lso.strName = N'SiteID'
		AND lso.strValue = CAST(s.idfsSite AS NVARCHAR(200))

	IF @idfsCountry = 780000000
		EXEC [dbo].[USSP_HUM_REP_WHOEXPORT_GG] @LangID, @DateFrom, @DateTo, @DiseaseID
	ELSE IF @idfsCountry = 170000000
 		EXEC [dbo].[USSP_HUM_REP_WHOEXPORT_AJ] @LangID, @DateFrom, @DateTo, @DiseaseID
   	
END


