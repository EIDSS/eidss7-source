

--*************************************************************
-- Name: [USP_OMM_HeatMap]
-- Description: Get heat map data - need fixes
--          
-- Author: Maheshwar Deo
-- Revision History
--	Name			Date		Change Detail
--	Doug Albanees	10/19/2021	Refactored so EF would generate a return model
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_HeatMap]
	(
	@OutbreakId BIGINT = NULL
	, @CaseType VARCHAR(3) = NULL
	, @DiseaseReportId BIGINT = NULL
	)
AS

BEGIN    

	DECLARE	@returnCode	INT = 0;
	DECLARE @returnMsg	NVARCHAR(MAX) = 'SUCCESS';
	
	SELECT 
		@returnCode AS ReturnCode
		, @returnMsg AS ReturnMsg
		, coalesce(STUFF((SELECT ',' + Replace([HeatData],'''1''','''' + CaseType + '''')
	From 
		VM_OMM_HeatMap 
	Where
		OutbreakId = Case IsNull(@outbreakId, 0) When 0 Then OutbreakId Else @OutbreakId End
		AND
		CaseType = Case IsNull(@CaseType, '') When '' Then CaseType Else @CaseType End
		AND
		DiseaseReportId = Case IsNull(@DiseaseReportId, 0) When 0 Then DiseaseReportId Else @DiseaseReportId End
	FOR 
		XML PATH('')),1,1,''),'') AS [HeatData]			

END
