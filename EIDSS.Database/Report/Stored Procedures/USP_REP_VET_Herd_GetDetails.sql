
-------------------------------------------------------------------------------------------------
-- Name 				: report.USP_REP_VET_Herd_GetDetails
-- DescriptiON			: Select data for Herd details for Vet Report.
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*

exec dbo.USP_REP_VET_Herd_GetDetails @ObjID=51580930000000,@LangID=N'en-US'

*/ 

CREATE PROCEDURE [Report].[USP_REP_VET_Herd_GetDetails]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS
	SELECT  
	H.strHerdCode						AS HerdCode,
	unSpecies.strSpeciesType			AS SpeciesID,
	unSpecies.intTotalAnimalQty			AS Total,
	unSpecies.intSickAnimalQty			AS Sick,
	unSpecies.intDeadAnimalQty			AS Dead,
	unSpecies.strAverageAge				AS AVGAge,
	unSpecies.datStartOfSignsDate		AS SignsDate,
	unSpecies.strType					AS [Type],
	unSpecies.strNote					AS strNote,
	unSpecies.idfHerd, 
	unSpecies.idfSpecies

	FROM dbo.tlbVetCase	AS VC
	-- Get Farm
	 INNER JOIN	dbo.tlbFarm AS F ON VC.idfFarm = F.idfFarm AND F.intRowStatus = 0
	 INNER JOIN	dbo.tlbHerd AS H ON H.idfFarm = F.idfFarm AND H.intRowStatus = 0
	 LEFT JOIN	(
	 
				SELECT		tInnerHerd.intSickAnimalQty,
							tInnerHerd.intTotalAnimalQty,
							tInnerHerd.intDeadAnimalQty,
							NULL					AS strAverageAge,
							NULL					AS datStartOfSignsDate,
							NULL					AS strSpeciesType,
							tInnerHerd.strNote,
							tInnerHerd.idfHerd,
							'pptCaseHerd'			AS strType,
							NULL					AS idfSpecies
						
				  FROM dbo.tlbHerd AS tInnerHerd
				  WHERE tInnerHerd.intRowStatus = 0
					   
			UNION					   
				SELECT		tSpecies.intSickAnimalQty,
							tSpecies.intTotalAnimalQty,
							tSpecies.intDeadAnimalQty,
							tSpecies.strAverageAge,
							tSpecies.datStartOfSignsDate,
							rfSpeciesType.[name]	AS strSpeciesType,
							tSpecies.strNote,
							tSpecies.idfHerd,
							'pptCaseHerdSpecies'	AS strType,
							tSpecies.idfSpecies		AS idfSpecies
						
				  FROM		dbo.tlbSpecies		AS tSpecies
				     LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000086) AS rfSpeciesType ON rfSpeciesType.idfsReference = tSpecies.idfsSpeciesType
				  WHERE tSpecies.intRowStatus = 0
				) AS unSpecies
			ON	unSpecies.idfHerd = H.idfHerd
		 WHERE	VC.idfVetCase = @ObjID
		 AND VC.intRowStatus = 0
		 ORDER BY unSpecies.idfHerd, unSpecies.idfSpecies

