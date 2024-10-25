-- =============================================
-- Author:		Steven L. Verner
-- Create date: 08.26.2020
-- Description:	Fetches a list of HMIS diagnosis.  This SP is based off of the original found in EIDSS 6.1 (HMISDiagnosis_SelectLookup)
-- =============================================
CREATE PROCEDURE [dbo].[USP_HMISDiagnosisListGet] 
	-- Add the parameters for the stored procedure here
	@langID nvarchar(50) = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		 h.hmisDiagnosis
		,t.idfsDiagnosis
		,h.strHmisICD10Code
		,h.strHmisDiagnosis
		,d.name
		,t.strIDC10
		,t.strOIECode 
		,d.intHACode
		,d.intRowStatus
	FROM dbo.fnReferenceRepair(@LangID, 19000019) d
	JOIN trtDiagnosis t ON t.idfsDiagnosis = d.idfsReference
	JOIN hmisDiagnosis h ON h.idfsDiagnosis = t.idfsDiagnosis 
	
END

