--*************************************************************
-- Name 				: Report.USP_VET_Vaccination
-- Description			: Dataset for Vet Vaccination Report.
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
--
--Example of a call of procedure:
/*

exec Report.USP_VET_Vaccination 'en-US', 1893
  
*/

CREATE  PROCEDURE [Report].[USP_VET_Vaccination]
    (
        @LangID AS NVARCHAR(10),
        @ObjID	AS BIGINT
    )
AS

	SELECT  	
		RD.[name] AS Diagnosis,
		Vac.datVaccinationDate, 
		fullSpecies.strFullSpeciesName AS strSpecies,
		Vac.intNumberVaccinated,
		rfType.[name] AS strType, 
		rfRoute.[name] AS strRouteAdministered,
		Vac.strLotNumber,
		Vac.strManufacturer,
		Vac.strNote
	
	FROM dbo.tlbVetCase AS VC
	INNER JOIN dbo.tlbVaccination AS Vac ON vc.idfVetCase = Vac.idfVetCase AND  Vac.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019)	AS RD ON RD.idfsReference = Vac.idfsDiagnosis
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000099)	AS rfType ON rfType.idfsReference = Vac.idfsVaccinationType
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000098)	AS rfRoute ON rfRoute.idfsReference = Vac.idfsVaccinationRoute
	LEFT JOIN 
		( 
				SELECT	sp.idfSpecies,
						rfSpeciesType.[name] + ' ' + h.strHerdCode AS strFullSpeciesName
					FROM dbo.tlbSpecies sp
				LEFT JOIN dbo.tlbHerd h ON sp.idfHerd = h.idfHerd
   				LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000086)	AS rfSpeciesType ON rfSpeciesType.idfsReference = sp.idfsSpeciesType
				WHERE  sp.intRowStatus = 0
				AND  h.intRowStatus = 0	
		) fullSpecies ON fullSpecies.idfSpecies = Vac.idfSpecies
	
	WHERE	vc.idfVetCase = @ObjID
	AND vc.intRowStatus = 0
		
		
