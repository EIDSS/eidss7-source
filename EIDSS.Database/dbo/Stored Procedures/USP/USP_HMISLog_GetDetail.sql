

CREATE PROCEDURE [dbo].[USP_HMISLog_GetDetail]
( 
	@strHmisCaseId AS VARCHAR(36),
	@strHmisICD10Code AS VARCHAR(36)
)
	
AS
SELECT 
	[hmisLog],
	[datImport],
	[strHmisCaseId],
	[strHmisICD10Code],
	[strHmisPatientLastName],
	[strHmisRegionId],
	[strHmisRayonId],
	[intStatus],
	[strComments],
	[idfsHumanCase]
FROM hmisLog
WHERE 
	strHmisCaseId = @strHmisCaseId
	AND strHmisICD10Code = @strHmisICD10Code

