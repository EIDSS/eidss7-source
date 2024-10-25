-- ================================================================================================
-- Name: USP_HUM_SAMPLES_GetList
--
-- Description: List Human Disease Report Samples by human disease report ID.
--          
-- Author: JWJ
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- JWJ				06/03/2018 created 
-- Lamont Mitchell	02/13/2020 Added join on tlbPerson to return strFieldCollectedByPerson
-- Mike Kornegay	10/19/2021 Removed @returnMsg and @returnCode
-- Stephen Long     08/02/2022 Removed site join; returing duplicate sample records, and 
--                             changed reference values to use the national name for translated 
--                             value.
-- Ann Xiong		05/12/2023 Fixed the issue of strFieldCollectedByPerson return null when p.strFirstName or p.strSecondName or p.strFamilyName is null
--
-- Testing code:
-- EXEC USP_HUM_SAMPLES_GetList 'en', @idfHumanCase=25   --10
-- ================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[USP_HUM_SAMPLES_GetList_With_Derivates] 
	@LangID						NVARCHAR(50) , 
	@idfHumanCase			BIGINT = NULL,
	@SearchDiagnosis 		BIGINT = NULL
AS
BEGIN
	BEGIN TRY  
		SELECT		
					Samples.idfHumanCase
					,Samples.idfMaterial 
					,Samples.strBarcode -- Lab sample ID
					,Samples.strFieldBarcode -- Local Sample ID
					,Samples.idfsSampleType
					,SampleType.name AS strSampleTypeName
					,Samples.datFieldCollectionDate
					,Samples.idfSendToOffice
					,OfficeSendTo.name AS strSendToOffice
					,Samples.idfFieldCollectedByOffice
					,CollectedByOffice.name AS strFieldCollectedByOffice
					,Samples.datFieldSentDate
					,Samples.strNote
					,Samples.datAccession			--verify this is date received
					,Samples.idfsAccessionCondition
					,acessionedCond.name AS strCondition
					,Location.idfsRegion AS idfsRegion
					,ISNULL(Region.[name], Region.strDefault) AS [strRegionName]
					,Location.idfsRayon AS idfsRayon
					,ISNULL(Rayon.[name], Rayon.strDefault) AS [strRayonName]
					,Samples.blnAccessioned
					,'' as RecordAction
					,Samples.idfsSampleKind
					,sampleKind.name AS SampleKindTypeName
					,Samples.idfsSampleStatus
					,sampleStatus.name AS SampleStatusTypeName
					,Samples.idfFieldCollectedByPerson  
					,ISNULL(p.strFirstName + ' ', '') + ISNULL(p.strSecondName, '') + ISNULL(p.strFamilyName + ' ', '') as 'strFieldCollectedByPerson'   --verify this is the employee
					,Samples.datSampleStatusDate   --verify this is the result date
					,Samples.rowGuid as sampleGuid
					,Samples.intRowStatus
					,Samples.idfsSite AS idfsSite
					,Samples.idfInDepartment as FunctionalAreaID
					,functionalArea.name as FunctionalAreaName
					,Samples.DiseaseID as DiseaseID
		FROM		dbo.tlbMaterial Samples 
		INNER JOIN	dbo.tlbHumanCase as hc ON Samples.idfHumanCase  = hc.idfHumanCase 
		LEFT JOIN	dbo.tlbGeoLocation as Location	ON Location.idfGeoLocation = hc.idfPointGeoLocation
		LEFT JOIN dbo.tlbDepartment d ON d.idfDepartment = Samples.idfInDepartment
			AND d.intRowStatus = 0
		LEFT JOIN	dbo.FN_GBL_REFERENCEREPAIR(@LangID,19000087) SampleType ON	SampleType.idfsReference = Samples.idfsSampleType
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID,19000003) Region ON Region.idfsReference = Location.idfsRegion
		LEFT JOIN	FN_GBL_GIS_Reference(@LangID,19000002) Rayon ON	Rayon.idfsReference = Location.idfsRayon
		LEFT JOIN	tlbMaterial ParentSample ON	ParentSample.idfMaterial = Samples.idfParentMaterial AND ParentSample.intRowStatus = 0
		LEFT JOIN	dbo.FN_GBL_INSTITUTION(@LangID) AS CollectedByOffice ON CollectedByOffice.idfOffice = Samples.idfFieldCollectedByOffice
		LEFT JOIN	dbo.FN_GBL_INSTITUTION(@LangID) AS OfficeSendTo ON OfficeSendTo.idfOffice = Samples.idfSendToOffice
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000158) AS sampleKind	ON sampleKind.idfsReference = Samples.idfsSampleKind 
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000015) AS sampleStatus ON sampleStatus.idfsReference = Samples.idfsSampleStatus 
		LEFT JOIN	FN_GBL_ReferenceRepair(@LangID, 19000110) AS acessionedCond ON acessionedCond.idfsReference = Samples.idfsAccessionCondition 
		LEFT JOIN   FN_GBL_Repair(@LangID, 19000164) functionalArea ON functionalArea.idfsReference = d.idfsDepartmentName
		Left JOIN	dbo.tlbPerson p on p.idfPerson = Samples.idfFieldCollectedByPerson
		WHERE		
		Samples.idfHumanCase = @idfHumanCase
		AND	Samples.intRowStatus = 0
	END TRY  

	BEGIN CATCH 
		THROW
	END CATCH
END
