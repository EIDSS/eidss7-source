-- ============================================================================
-- Name: report.USP_VET_ASSessionFarm_GET
-- Description:	Get list of farms, heards, species amd animals related with specific monitoring session for report.
--                      
-- Author: Mark Wilson
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Mark Wilson		07/14/2022 Initial release
-- Srini Goli		09/07/2022 To get intRowStatus = 0 from tlbMaterial
-- Srini Goli		10/04/2022 Added strDiagnosis field
-- Mike Kornegay	10/19/2022 Remove inner joins on animals because a sample may not have an animal
--								and correct strDiagnosis to be concatenated list
-- Mike Kornegay	10/22/2022 Corrected problem where multiple farms or animals would cause duplicate samples.
--
/*

select * FROM dbo.tlbMonitoringSession where SessionCategoryID IN (10502009,10502002)  -- Avian, Livestock

--Example of a call of procedure:

EXEC report.USP_VET_ASSessionFarm_GET 155415660001540,'en-US'

*/

CREATE PROCEDURE [Report].[USP_VET_ASSessionFarm_GET]
(
	@idfCase BIGINT,
	@LangID NVARCHAR(20)
)
AS
BEGIN
	DECLARE @intTotalSamples INT
	DECLARE @intTotalAnimalSampled INT

	SELECT
		@intTotalSamples = COUNT(M.idfMaterial), 
		@intTotalAnimalSampled = COUNT(DISTINCT A.idfAnimal)
	FROM dbo.tlbMonitoringSession MS
	INNER JOIN dbo.tlbMaterial as  M ON M.idfMonitoringSession = MS.idfMonitoringSession AND M.intRowStatus = 0
	INNER JOIN
				(
					SELECT		farm.idfFarm, 
								farm.idfMonitoringSession, 
								farm.intRowStatus,
								m.idfMaterial
					FROM		tlbFarm farm 
					inner join	tlbHerd h ON h.idfFarm = farm.idfFarm and h.intRowStatus = 0
					inner join	tlbSpecies s ON s.idfHerd = h.idfHerd and s.intRowStatus = 0
					inner join	tlbMaterial m ON m.idfSpecies = s.idfSpecies
					WHERE		farm.idfMonitoringSession = @idfCase
					AND			m.idfMaterial = M.idfMaterial

				) 
				F ON F.idfMonitoringSession = MS.idfMonitoringSession
					AND F.idfMaterial = M.idfMaterial
					AND F.intRowStatus = 0
	INNER JOIN	dbo.tlbSpecies S ON S .idfSpecies = M.idfSpecies AND S.intRowStatus = 0
	LEFT JOIN	(
					SELECT		a.idfAnimal,
								a.intRowStatus,
								a.idfSpecies,
								m.idfMaterial
					FROM		tlbAnimal a 
					INNER JOIN 	tlbMaterial m ON m.idfAnimal = a.idfAnimal
					WHERE		m.idfMaterial = M.idfMaterial								
				) A ON A.idfSpecies  = S.idfSpecies 
					AND A.idfMaterial = M.idfMaterial
					AND A.intRowStatus = 0

	WHERE MS.idfMonitoringSession = @idfCase
	AND MS.intRowStatus = 0
	
	SELECT 

		A.idfAnimal AS idfKey,
		F.idfFarm	 AS idfFarm,
		F.strFarmCode AS strFarmCode,
		dbo.FN_GBL_ConcatFullName(Hu.strLastName, Hu.strFirstName, Hu.strSecondName) 
							AS strOwnerName,
		dbo.FN_GBL_GeoLocationString(@LangID,F.idfFarmAddress,NULL) 
							AS strFarmAddress,
		A.strAnimalCode	AS strAnimalID,
		spt.[name] AS strSpecies,
		A.strAge,
		A.strColor AS strColor,
		A.strName AS strName,
		A.strSex AS strSex,
		M.datFieldCollectionDate AS datCollectionDate,				
		M.strFieldBarcode AS strSampleID,
		samt.[name]	AS strSampleType,
		@intTotalSamples AS intTotalSamples,
		@intTotalAnimalSampled AS intTotalAnimalSampled,
		dbo.FN_VAS_SESSION_SAMPLE_DIAGNOSESNAMES_GET(@idfCase, @LangID, M.idfMaterial) AS strDiagnosis
		
	FROM dbo.tlbMonitoringSession MS
	
	INNER JOIN dbo.tlbMaterial AS M ON M.idfMonitoringSession = MS.idfMonitoringSession AND M.intRowStatus = 0
		LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) samt ON samt.idfsReference = M.idfsSampleType
		LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) D ON D.idfsReference = M.DiseaseID
	
	INNER JOIN	(	
					dbo.tlbSpecies S
					INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) AS spt ON spt.idfsReference = S.idfsSpeciesType
				) ON S .idfSpecies = M.idfSpecies AND S.intRowStatus = 0
        
	LEFT JOIN	(
					SELECT		a.idfAnimal,
								a.idfSpecies,
								a.strAnimalCode, 
								Age.[name] as strAge,
								A.strColor AS strColor,
								A.strName AS strName,
								G.[name] as strSex,
								a.intRowStatus,
								m.idfMaterial
					FROM		tlbAnimal a 
					INNER JOIN 	tlbMaterial m ON m.idfAnimal = a.idfAnimal
					LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000007) AS G ON G.idfsReference = A.idfsAnimalGender
					LEFT JOIN	dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000005) AS Age ON Age.idfsReference = A.idfsAnimalAge
					WHERE		m.idfMaterial = M.idfMaterial								
				) A ON A.idfSpecies  = S.idfSpecies 
					AND A.idfMaterial = M.idfMaterial
					AND A.intRowStatus = 0

	INNER JOIN
				(
					SELECT		farm.idfFarm, 
								farm.strFarmCode, 
								farm.idfFarmAddress, 
								farm.idfMonitoringSession, 
								farm.idfHuman,
								farm.intRowStatus,
								m.idfMaterial
					FROM		tlbFarm farm 
					inner join	tlbHerd h ON h.idfFarm = farm.idfFarm and h.intRowStatus = 0
					inner join	tlbSpecies s ON s.idfHerd = h.idfHerd and s.intRowStatus = 0
					inner join	tlbMaterial m ON m.idfSpecies = s.idfSpecies
					WHERE		farm.idfMonitoringSession = @idfCase
					AND			m.idfMaterial = M.idfMaterial

				) 
				F ON F.idfMonitoringSession = MS.idfMonitoringSession
					AND F.idfMaterial = M.idfMaterial
					AND F.intRowStatus = 0

	LEFT JOIN dbo.tlbHuman Hu ON F.idfHuman = Hu.idfHuman AND Hu.intRowStatus = 0
				
	WHERE MS.idfMonitoringSession = @idfCase
	AND MS.intRowStatus = 0
	
END	

