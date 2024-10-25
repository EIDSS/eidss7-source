-- ================================================================================================
-- Name: USP_VCTS_SAMPLE_GetList
--
-- Description: Get Vector Surveillance Sample GetList
--          
-- Author: Harold Pryor
--
-- Revision History:
--	Name			Date		Change Detail
--	--------------- ----------	--------------------------------------------------------------------
--	Harold Pryor    05/16/2018	Updated to return strCondition
--	Harold Pryor    05/20/2018	Updated to return strFieldCollectedByOffice
--	Stephen Long    04/16/2020	Added entered date and root sample ID to the model.
--	Doug Albanese	12/15/2020	Use case update to return disease id.
--  Mike Kornegay	05/05/2022	Updated to produce same view model as vet module
--  Mike Kornegay	05/16/2022	Changed Disease to TestDiseaseName to match samples models
--								and added SiteID and CurrentSiteID
--	Mike Kornegay	05/19/2022	Added TotalRowCount for populating grids
--  Mike Kornegay	06/20/2022  Added AccessionConditionTypeName
--
-- Testing code:
--EXECUTE USP_VCTS_SAMPLE_GetList 28,'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_VCTS_SAMPLE_GetList] (
	@idfVector BIGINT,
	@LangID NVARCHAR(50),
	@idfMaterial BIGINT = NULL
	)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'Success';
	DECLARE @returnCode BIGINT = 0;

	BEGIN TRY
		SELECT Samples.idfVector AS VectorID,
			Vector.idfsVectorType AS VectorTypeID,
			Vector.idfsVectorSubType AS VectorSubTypeID,
			Samples.idfMaterial AS SampleID,
			Samples.idfRootMaterial AS RootSampleID, 
			Samples.strBarcode AS EIDSSLaboratorySampleID,
			Samples.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
			Samples.idfsSampleType AS SampleTypeID,
			SampleType.name AS SampleTypeName,
			Samples.datFieldCollectionDate AS FieldCollectionDate,
			Samples.idfSendToOffice AS SentToOrganizationID,
			OfficeSendTo.[name] AS SentToOrganizationName,
			Samples.idfFieldCollectedByOffice AS CollectedByOrganizationID,
			CollectedByOffice.name AS CollectedByOrganizationName,
			Samples.datFieldSentDate AS SentDate,
			Samples.datEnteringDate AS EnteredDate,
			Samples.strNote AS Comments,
			Samples.datAccession AS AccessionDate,
			Samples.idfsAccessionCondition  AS AccessionConditionTypeID,
			accessionConditionType.[name] AS AccessionConditionTypeName,
			Samples.strCondition AS AccessionComment,
			ISNULL(Samples.idfHumanCase, Samples.idfVetCase) AS CaseID,
			Samples.idfVectorSurveillanceSession AS VectorSessionKey,
			ISNULL(VectorType.[name], VectorType.strDefault) AS VectorTypeName,
			ISNULL(VectorSubType.[name], VectorSubType.strDefault) AS VectorSubTypeName,
			Vector.intQuantity AS Quantity,
			Vector.datCollectionDateTime AS CollectionDate,
			Vector.strVectorID AS SessionID,
			Samples.idfsSite AS SiteID,
			Samples.idfsCurrentSite AS CurrentSiteID,
			Samples.blnAccessioned AS AccessionedIndicator,
			'' AS RecordAction,
			SampleDisease.idfsReference AS DiseaseID,
			ISNULL(SampleDisease.[name], SampleDisease.strDefault) AS TestDiseaseName,
			TotalRowCount = COUNT(*) OVER(PARTITION BY 1)
		FROM dbo.tlbMaterial Samples
		INNER JOIN dbo.tlbVector Vector
			ON Samples.idfVector = Vector.idfVector
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000140) VectorType
			ON Vector.idfsVectorType = VectorType.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000141) VectorSubType
			ON Vector.idfsVectorSubType = VectorSubType.idfsReference
		LEFT JOIN dbo.tlbGeoLocation Location
			ON Location.idfGeoLocation = Vector.idfLocation
		LEFT JOIN dbo.FN_GBL_REFERENCEREPAIR(@LangID, 19000087) SampleType
			ON SampleType.idfsReference = Samples.idfsSampleType
		LEFT JOIN   fn_gbl_locationHierarchy_Flattened(@LangID)   HL ON HL.idfsLocation = Location.idfsLocation
		LEFT JOIN tlbMaterial ParentSample
			ON ParentSample.idfMaterial = Samples.idfParentMaterial
				AND ParentSample.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_INSTITUTION(@LangID) AS CollectedByOffice
			ON CollectedByOffice.idfOffice = Samples.idfFieldCollectedByOffice
		LEFT JOIN dbo.FN_GBL_INSTITUTION(@LangID) AS OfficeSendTo
			ON OfficeSendTo.idfOffice = Samples.idfSendToOffice
		LEFT JOIN dbo.FN_GBL_REFERENCEREPAIR(@LangID, 19000019) SampleDisease
			ON SampleDisease.idfsReference = Samples.DiseaseID
		LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000110) accessionConditionType
            ON accessionConditionType.idfsReference = Samples.idfsAccessionCondition
		WHERE Samples.blnShowInCaseOrSession = 1
			AND Samples.idfVector = @idfVector
			AND Samples.intRowStatus = 0
			AND (Samples.idfMaterial = @idfMaterial OR @idfMaterial is NULL)
			AND NOT (
				ISNULL(Samples.idfsSampleKind, 0) = 12675420000000 /*derivative*/
				AND (
					ISNULL(Samples.idfsSampleStatus, 0) = 10015002
					OR ISNULL(Samples.idfsSampleStatus, 0) = 10015008
					) /*deleted in lab module*/
				);
	END TRY

	BEGIN CATCH
			Throw;
	END CATCH;
END
