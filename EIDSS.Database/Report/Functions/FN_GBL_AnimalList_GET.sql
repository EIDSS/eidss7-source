



--*************************************************************
-- Name 				: report.FN_GBL_AnimalList_GET
-- Description			: Returns list of species and possibly associated animals
--          
-- Revision History
--		Name       Date       Change Detail
-- --------------- ---------- ---------------------------------
--	Mark Wilson		12/13/2021	Initial version
-- Testing code:

/*

select * from report.FN_GBL_AnimalList_GET('en-US')

*/


CREATE   FUNCTION [Report].[FN_GBL_AnimalList_GET]
(	
	@LangID NVARCHAR(20)
)
RETURNS TABLE 
AS
RETURN 

SELECT		
	A.idfAnimal AS idfParty,
	VC.idfVetCase AS idfCase,
	F.idfMonitoringSession,
	F.strFarmCode,
	F.strNationalName,
	F.idfHuman AS idfFarmOwner,
	A.idfAnimal,
	A.strAnimalCode,
	A.idfsAnimalGender,
	A.idfsAnimalAge,
	A.idfsAnimalCondition,
	S.idfSpecies,
	S.idfsSpeciesType,
	SpeciesName.name AS SpeciesName,
	H.strHerdCode,
	A.strAnimalCode AS AnimalName,
	obs.idfObservation,
	obs.idfsFormTemplate,
	H.idfFarm

FROM dbo.tlbAnimal A
LEFT JOIN dbo.tlbObservation obs ON A.idfObservation = obs.idfObservation
LEFT JOIN dbo.tlbSpecies S ON S.idfSpecies=A.idfSpecies AND S.intRowStatus = 0
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) SpeciesName ON SpeciesName.idfsReference=S.idfsSpeciesType
LEFT JOIN dbo.tlbHerd H ON H.idfHerd = S.idfHerd AND H.intRowStatus = 0
LEFT JOIN dbo.tlbFarm F ON F.idfFarm = H.idfFarm AND F.intRowStatus = 0
LEFT JOIN dbo.tlbVetCase VC ON VC.idfFarm = F.idfFarm

WHERE A.intRowStatus = 0

UNION ALL

SELECT		
	S.idfSpecies AS idfParty,
	VC.idfVetCase AS idfCase,
	F.idfMonitoringSession,
	F.strFarmCode,
	F.strNationalName,
	F.idfHuman AS idfFarmOwner,
	NULL AS idfAnimal,
	NULL AS strAnimalCode,
	NULL AS idfsAnimalGender,
	NULL AS idfsAnimalAge,
	NULL AS idfsAnimalCondition,
	S.idfSpecies,
	S.idfsSpeciesType,
	SpeciesName.name AS SpeciesName,
	H.strHerdCode,
	SpeciesName.name AS AnimalName,
	obs.idfObservation,
	obs.idfsFormTemplate, 
	H.idfFarm
FROM dbo.tlbSpecies S
LEFT JOIN dbo.tlbObservation obs ON S.idfObservation = obs.idfObservation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) SpeciesName ON SpeciesName.idfsReference = S.idfsSpeciesType
LEFT JOIN dbo.tlbHerd H ON	H.idfHerd = S.idfHerd AND H.intRowStatus = 0
LEFT JOIN dbo.tlbFarm F ON F.idfFarm = H.idfFarm AND F.intRowStatus = 0
LEFT JOIN dbo.tlbVetCase VC ON VC.idfFarm = F.idfFarm

WHERE S.intRowStatus = 0


