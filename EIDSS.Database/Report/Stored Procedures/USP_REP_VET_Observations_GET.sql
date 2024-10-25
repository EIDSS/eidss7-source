
-------------------------------------------------------------------------------------------------
-- Name 				: report.USP_REP_VET_Observations_GET
-- DescriptiON			: Select observations for Veterinary Case.
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
--Example of a call of procedure:

exec report.USP_REP_VET_Observations_GET 4970000002, 'en-US'

*/
--------------------------------------------------------------------------------------------------


CREATE  PROCEDURE [Report].[USP_REP_VET_Observations_GET]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS
BEGIN

	-- Get Case and Farm observations
	SELECT  	
		VC.idfVetCase AS idfCase,	
		VC.idfObservation AS idfCaseObservation,
		F.idfObservation AS idfFarmObservation

	FROM dbo.tlbVetCase	AS VC
	INNER JOIN	dbo.tlbFarm	AS F ON	VC.idfFarm = F.idfFarm  AND  F.intRowStatus = 0
	WHERE VC.idfVetCase = @ObjID
	AND  VC.intRowStatus = 0
		 
	-- Get Species observations 
	SELECT 
		VC.idfVetCase AS idfCase,	
		S.idfObservation AS idfSpeciesObservation,
		SR.[name] AS strSpeciesName,
		H.strHerdCode AS strHerdCode

	FROM dbo.tlbVetCase	VC
	INNER JOIN	dbo.tlbFarm	 AS F
      INNER JOIN dbo.tlbHerd AS H
	        INNER JOIN dbo.tlbSpecies	AS S
	           LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) AS SR ON S.idfsSpeciesType = SR.idfsReference
					ON	H.idfHerd = S.idfHerd AND S.intRowStatus = 0
				ON H.idfFarm = F.idfFarm AND H.intRowStatus = 0
			ON VC.idfFarm = F.idfFarm AND F.intRowStatus = 0
	WHERE	VC.idfVetCase = @ObjID
	AND  VC.intRowStatus = 0
		 
	-- Get Animal observations 
	SELECT  	
		VC.idfVetCase AS idfCase,	
		A.idfObservation AS idfAnimalObservation,
		A.strName AS strAnimalName

	FROM dbo.tlbVetCase	AS VC
	INNER JOIN	dbo.tlbFarm AS F
      INNER JOIN dbo.tlbHerd AS H
	        INNER JOIN	dbo.tlbSpecies AS S
	            INNER JOIN	dbo.tlbAnimal AS A ON S.idfSpecies = A.idfSpecies AND  A.intRowStatus = 0
	        ON	H.idfHerd = S.idfHerd AND S.intRowStatus = 0
      ON H.idfFarm = F.idfFarm AND H.intRowStatus = 0
	ON	VC.idfFarm = F.idfFarm AND F.intRowStatus = 0			
  WHERE	VC.idfVetCase = @ObjID AND VC.intRowStatus = 0
		 
END			

