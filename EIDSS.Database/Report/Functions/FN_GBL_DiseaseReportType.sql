

--- This stored proc is to be used by reports to display the Report Type as either:
--- Active
--- Passive
--- Both
--- 
--- If User select Both, NULL is returned and all reports should be displayed
--- 

/*
DECLARE @LangID NVARCHAR(20) = 'en'
SELECT * FROM report.FN_GBL_DiseaseReportType(@LangID)

*/

CREATE FUNCTION [Report].[FN_GBL_DiseaseReportType]
(
	@LangID		AS NVARCHAR(10) 

)

RETURNS TABLE

AS 
RETURN
(
	SELECT 
		[name] AS strDiseaseReportType,
		CASE WHEN [name] = 'Active' THEN idfsReference
			 WHEN [name] = 'Passive'  THEN idfsReference
			 ELSE NULL END AS DiseaseReportTypeID
		
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000144)

)

