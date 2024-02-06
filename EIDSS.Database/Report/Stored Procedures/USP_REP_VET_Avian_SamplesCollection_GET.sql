-- ================================================================================================
-- Name: report.USP_REP_VET_Avian_SamplesCollection_GET
--
-- Description:	Select Avian samples list for avian investigation report
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson     06/28/2022  Initial release.

/* Sample Code

exec report.USP_REP_VET_Avian_SamplesCollection_GET 1849460000822 , 'en-US' 
 

*/ 

CREATE PROCEDURE [Report].[USP_REP_VET_Avian_SamplesCollection_GET]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS 

	SELECT		
		SampleType.[name]			AS strSampleType,
		m.strFieldBarcode	AS strFieldSampleId,
		SR.[name]				AS strSpeciesName,
		BirdStatus.[name]			AS strBirdStatus,
		m.datFieldCollectionDate		AS datCollected,
		m.datAccession,
		Condition.[name]			AS strCondition,
		m.strCondition		AS strComment,
		dbo.FN_GBL_ConcatFullName(P.strFamilyName, P.strFirstName, P.strSecondName)	AS strCollectedByPerson,
		OfficeCollectedBy.[name]			AS strCollectedByOffice,
		OfficeSendTo.[name]					AS strSendToOffice,
		VC.strSampleNotes
							
	FROM dbo.tlbVetCase	AS VC
	INNER JOIN dbo.tlbFarm F ON VC.idfFarm = F.idfFarm AND F.intRowStatus = 0
	INNER JOIN dbo.tlbHerd H ON H.idfFarm = F.idfFarm AND H.intRowStatus = 0
	        
	INNER JOIN (	
					dbo.tlbSpecies S
					INNER JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000086) AS SR ON SR.idfsReference = S.idfsSpeciesType
			   ) ON S.idfHerd = H.idfHerd AND S.intRowStatus = 0

	INNER JOIN dbo.tlbMaterial AS m ON m.idfVetCase = VC.idfVetCase AND m.idfSpecies = S.idfSpecies	AND m.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000110) Condition ON Condition.idfsReference = m.idfsAccessionCondition
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) SampleType ON SampleType.idfsReference = m.idfsSampleType
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000006) BirdStatus ON BirdStatus.idfsReference = m.idfsBirdStatus
	LEFT JOIN dbo.tlbPerson AS P ON P.idfPerson = m.idfFieldCollectedByPerson
	LEFT JOIN	dbo.FN_GBL_Institution(@LangID) AS OfficeCollectedBy ON OfficeCollectedBy.idfOffice = m.idfFieldCollectedByOffice
	LEFT JOIN	dbo.fnInstitution(@LangID) AS OfficeSendTo ON OfficeSendTo.idfOffice = m.idfSendToOffice

	WHERE VC.idfVetCase =@ObjID
	AND VC.intRowStatus = 0
			

