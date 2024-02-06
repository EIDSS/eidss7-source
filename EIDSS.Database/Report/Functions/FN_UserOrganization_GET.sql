--*************************************************************************
-- Name: report.FN_UserOrganization_GET
--
-- Description: Get the User Organization - For Comparative Report Footer
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
SELECT report.FN_UserOrganization_GET('en')
SELECT report.FN_UserOrganization_GET('ru')
*/
CREATE FUNCTION [Report].[FN_UserOrganization_GET](@LangID AS NVARCHAR(50))
RETURNS VARCHAR(2000)
AS
BEGIN
	DECLARE @ret VARCHAR(2000);

	SELECT @ret = Organization.EnglishFullName
	FROM dbo.FN_GBL_Institution_Min(@LangID) Organization
	INNER JOIN dbo.tstLocalSiteOptions S 
			ON S.strName = 'SiteID' AND Organization.idfsSite = CAST(S.strValue AS BIGINT)
	WHERE Organization.intRowStatus = 0

	RETURN @ret
END