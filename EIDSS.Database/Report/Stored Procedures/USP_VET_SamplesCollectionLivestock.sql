


--*************************************************************
-- Name 				: Report.USP_VET_SamplesCollectionLivestock
-- Description			: Penside Tests for Vet report.
--          
-- Author               : Mark Wilson

-- Revision History
--		Name       Date			Change Detail
-- Srini Goli	   08/25/2022	Updated to Sent date
--
--Example of a call of procedure:
/*
select * FROM dbo.tlbVetCase
exec Report.USP_VET_SamplesCollectionLivestock 5055 , 'en-US' 
  
*/

CREATE  PROCEDURE [Report].[USP_VET_SamplesCollectionLivestock] 
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS 

	SELECT		 
		M.idfMaterial,
		SampleType.[name] AS strSampeType,
		M.strFieldBarcode AS strFieldSampleID,
		A.strAnimalCode AS strAnimalID,
		SpeciesType.[name] AS strSpecies,
		M.datFieldCollectionDate	AS datCollected,
		M.datFieldSentDate,
		Condition.[name] AS strCondition,
		M.strCondition AS strComment,
		dbo.FN_GBL_ConcatFullName(P.strFamilyName, P.strFirstName, P.strSecondName) AS strCollectedByPerson,
		OfficeCollectedBy.[name] AS strCollectedByOffice,
		OfficeSendTo.[name] AS strSendToOffice,
		VC.strSampleNotes,
		M.idfsBirdStatus AS BirdStatusTypeID,
		birdStatusType.name AS BirdStatusTypeName
	FROM dbo.tlbVetCase AS VC
	INNER JOIN dbo.tlbFarm F ON F.idfFarm = VC.idfFarm AND F.intRowStatus = 0
	INNER JOIN dbo.tlbHerd H ON H.idfFarm = F.idfFarm AND H.intRowStatus = 0
	INNER JOIN dbo.tlbSpecies S ON S.idfHerd = H.idfHerd AND S.intRowStatus = 0
	INNER JOIN dbo.tlbAnimal A ON A.idfSpecies = S.idfSpecies AND A.intRowStatus = 0
	INNER JOIN dbo.tlbMaterial AS M ON M.idfAnimal = A.idfAnimal AND M.idfVetCase = VC.idfVetCase AND M.intRowStatus = 0
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) AS SpeciesType ON SpeciesType.idfsReference = S.idfsSpeciesType
	INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) AS SampleType ON SampleType.idfsReference = M.idfsSampleType
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000110) Condition ON Condition.idfsReference = M.idfsAccessionCondition
	LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000006) birdStatusType ON birdStatusType.idfsReference = M.idfsBirdStatus
	LEFT JOIN dbo.tlbPerson AS P ON P.idfPerson = M.idfFieldCollectedByPerson
	LEFT JOIN dbo.FN_GBL_Institution(@LangID) AS OfficeCollectedBy ON OfficeCollectedBy.idfOffice = M.idfFieldCollectedByOffice
	LEFT JOIN dbo.FN_GBL_Institution(@LangID) AS OfficeSendTo ON OfficeSendTo.idfOffice = M.idfSendToOffice
	
	WHERE VC.idfVetCase =@ObjID
	AND VC.intRowStatus = 0

