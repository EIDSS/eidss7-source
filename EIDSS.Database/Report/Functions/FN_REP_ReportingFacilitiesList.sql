


--*************************************************************************
-- Name 				: report.FN_REP_ReportingFacilitiesList
-- DescriptiON			: Select Reporting Facilities List for Rayon
-- 
-- Author               : Srini Goli
-- RevisiON History
--		Name			Date       Change Detail
--		
-- Testing code:
/*

DECLARE @idfsRayon BIGINT = 3370000000
DECLARE @LangID NVARCHAR(20) = 'en'
SELECT * FROM report.FN_REP_ReportingFacilitiesList(dbo.FN_GBL_LanguageCode_GET(@LangID), @idfsRayon)

*/

CREATE FUNCTION [Report].[FN_REP_ReportingFacilitiesList](@idfsLanguage BIGINT, @idfsRayon BIGINT)
RETURNS TABLE
AS
RETURN
(
	SELECT 
		ts.idfsSite,
		ISNULL(snt.strTextString, br.strDefault) AS strNameOfRespondent ,
		report.FN_REP_AddressSharedString(@idfsLanguage, o.idfLocation) AS strActualAddress,
		o.strContactPhone AS strContactPhone
	FROM tstRayonToReportSite trtrs
		INNER JOIN tstSite ts
			INNER JOIN tlbOffice o
			ON ts.idfOffice = o.idfOffice
			AND o.intRowStatus = 0

			INNER JOIN trtBaseReference br
			ON o.idfsOfficeName = br.idfsBaseReference

			left outer join trtStringNameTranslation snt
			ON br.idfsBaseReference = snt.idfsBaseReference
			AND snt.idfsLanguage = @idfsLanguage
			AND snt.intRowStatus = 0
		ON ts.idfsSite = trtrs.idfsSite 
		AND ts.intRowStatus = 0
	WHERE trtrs.idfsRayon = @idfsRayon 
)	

