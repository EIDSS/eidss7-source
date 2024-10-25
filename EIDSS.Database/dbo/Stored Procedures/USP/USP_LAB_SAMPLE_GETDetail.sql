-- ================================================================================================
-- Name: USP_LAB_SAMPLE_GETDetail
--
-- Description:	Get sample detail for the edit a sample use case LUC11.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     09/05/2018 Initial release.
-- Stephen Long     01/25/2019 Added previous sample status type.
-- Stephen Long     01/30/2019 Added sample disease reference join, and removed the vector 
--                             surveillance session joins as they are not needed.
-- Stephen Long     03/01/2019 Added return code and return message.
-- Stephen Long     07/01/2019 Corrected reference type on monitoring session category.
-- Stephen Long     01/22/2020 Cleaned up stored procedure.
-- Stephen Long     03/11/2020 Corrected joins with intRowStatus = 0.
-- Stephen Long     05/14/2020 Added favorite indicator to the model.
-- Stephen Long     07/06/2020 Added lab module source indicato to the model.
-- Stephen Long     09/22/2020 Added accession by person name to the model.
-- Stephen Long     10/27/2020 Added test assigned count and removed test count.  Corrected joins 
--                             on collected by and sent to organization name.
-- Stephen Long     09/25/2021 Removed return code and message in the catch portion to work with 
--                             POCO.
-- Stephen Long     02/07/2022 Removed unneeded joins and corrected conversion error on species 
--                             type.
-- Stephen Long     03/10/2022 Changed note to comment and transfer count to transferred count.
-- Mike Kornegay	06/14/2022 Added new additional SessionCategoryID for Vet Avian / Vet Livestock 
--                             breakout.
-- Stephen Long     06/21/2022 Added cast to nvarchar(max) on active surveillance session samples.
-- Stephen Long     10/18/2022 Changed patient/species/vector info from field vector ID to 
--                             vector ID.
-- Stephen Long     10/21/2022 Changed from semi-colon to pipe and replaced with commas on the 
--                             disease name.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_SAMPLE_GETDetail]
		@LanguageID = N'en-US',
		@SampleID = 1,
		@TestID = NULL

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_GETDetail]
(
    @LanguageID NVARCHAR(50),
    @SampleID BIGINT = NULL,
    @UserID BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
            @ReturnCode INT = 0;
    DECLARE @Favorites XML;

    BEGIN TRY
        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        SELECT m.idfMaterial AS SampleID,
               m.strBarcode AS EIDSSLaboratorySampleID,
               CASE
                   WHEN f.SampleID IS NULL THEN
                       0
                   ELSE
                       1
               END AS FavoriteIndicator,
               m.idfRootMaterial AS RootSampleID,
               m.idfParentMaterial AS ParentSampleID,
               parentLabSample.strBarcode AS ParentLaboratorySampleEIDSSID,
               m.idfsSampleType AS SampleTypeID,
               sampleType.name AS SampleTypeName,
               m.idfHuman AS HumanID,
               m.strCalculatedHumanName AS PatientOrFarmOwnerName,
               m.idfSpecies AS SpeciesID,
               m.idfAnimal AS AnimalID,
               a.strAnimalCode AS EIDSSAnimalID,
               m.idfVector AS VectorID,
               (CASE
                    WHEN
                    (
                        NOT ISNULL(m.idfMonitoringSession, '') = ''
                        AND ms.SessionCategoryID = 10502001 --Human Active Surveillance Session
                    ) THEN
                        m.strCalculatedHumanName
                    WHEN
                    (
                        NOT ISNULL(m.idfMonitoringSession, '') = ''
                        AND ms.SessionCategoryID IN ( 10502002, 10502009 ) --Veterinary Active Surveillance Session (Avian and Livestock)
                    ) THEN
                        speciesType.name
                    WHEN (NOT ISNULL(m.idfHumanCase, '') = '') THEN
                        m.strCalculatedHumanName
                    WHEN (NOT ISNULL(m.idfVetCase, '') = '') THEN
                        speciesType.name
                    WHEN (NOT ISNULL(m.idfVectorSurveillanceSession, '') = '') THEN
                        v.strVectorID + ' - ' + vectorType.name
                    ELSE
                        ''
                END
               ) AS PatientSpeciesVectorInformation,
               m.idfMonitoringSession AS MonitoringSessionID,
               m.idfVectorSurveillanceSession AS VectorSessionID,
               m.idfHumanCase AS HumanDiseaseReportID,
               m.idfVetCase AS VeterinaryDiseaseReportID,
               vc.idfsCaseType AS VeterinaryReportTypeID,
               m.strCalculatedCaseID AS EIDSSReportOrSessionID,
               (CASE
                    WHEN
                    (
                        NOT ISNULL(m.idfMonitoringSession, '') = ''
                        AND ms.SessionCategoryID = 10502001 --Human Active Surveillance Session
                    ) THEN
                        'Human'
                    WHEN
                    (
                        NOT ISNULL(m.idfMonitoringSession, '') = ''
                        AND ms.SessionCategoryID IN ( 10502002, 10502009 ) --Veterinary Active Surveillance Session (Avian and Livestock)
                    ) THEN
                        'Veterinary'
                    WHEN (NOT ISNULL(m.idfHumanCase, '') = '') THEN
                        'Human'
                    WHEN (NOT ISNULL(m.idfVetCase, '') = '') THEN
                        'Veterinary'
                    WHEN (NOT ISNULL(m.idfVectorSurveillanceSession, '') = '') THEN
                        'Vector'
                    ELSE
                        ''
                END
               ) AS ReportSessionTypeName,
               IIF(
                  (
                      SELECT COUNT(t2.idfTesting)
                      FROM dbo.tlbTesting t2
                      WHERE (
                                t2.idfsTestStatus = 10001001 --Final
                                OR t2.idfsTestStatus = 10001006 --Amended
                            )
                            AND t2.idfMaterial = m.idfMaterial
                  ) IS NULL,
                  0,
                  1) AS TestCompletedIndicator,
               CASE
                   WHEN (NOT ISNULL(m.idfMonitoringSession, '') = '') THEN
                       CAST(msDiseases.DiseaseID AS NVARCHAR(MAX))
                   WHEN (NOT ISNULL(m.idfVectorSurveillanceSession, '') = '') THEN
                       CAST(vsDiseases.DiseaseID AS NVARCHAR(MAX))
                   ELSE
                       CAST(m.DiseaseID AS NVARCHAR(MAX))
               END AS DiseaseID,
               CASE
                   WHEN (NOT ISNULL(m.idfMonitoringSession, '') = '') THEN
                       REPLACE(STRING_AGG(msDiseases.DiseaseName, '|'), '|', ', ') 
                   WHEN (NOT ISNULL(m.idfVectorSurveillanceSession, '') = '') THEN
                       REPLACE(STRING_AGG(vsDiseases.DiseaseName, '|'), '|', ', ') 
                   ELSE
                       diseaseName.name
               END AS DiseaseName,
               m.idfInDepartment AS FunctionalAreaID,
               functionalArea.name AS FunctionalAreaName,
               m.idfSubdivision AS FreezerSubdivisionID,
               m.StorageBoxPlace,
               m.datFieldCollectionDate AS CollectionDate,
               m.idfFieldCollectedByPerson AS CollectedByPersonID,
               ISNULL(collectedByPerson.strFamilyName, N'') + ISNULL(' ' + collectedByPerson.strFirstName, '')
               + ISNULL(' ' + collectedByPerson.strSecondName, '') AS CollectedByPersonName,
               m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
               collectedByOrganization.AbbreviatedName AS CollectedByOrganizationName,
               m.datFieldSentDate AS SentDate,
               m.idfSendToOffice AS SentToOrganizationID,
               sentToOrganization.AbbreviatedName AS SentToOrganizationName,
               m.idfsSite AS SiteID,
               m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
               CASE
                   WHEN m.strBarcode IS NULL THEN
                       m.strFieldBarcode
                   ELSE
                       m.strBarcode
               END AS EIDSSLaboratoryOrLocalFieldSampleID,
               m.datEnteringDate AS EnteredDate,
               m.datOutOfRepositoryDate AS OutOfRepositoryDate,
               m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
               m.blnReadOnly AS ReadOnlyIndicator,
               m.blnAccessioned AS AccessionIndicator,
               m.datAccession AS AccessionDate,
               m.idfsAccessionCondition AS AccessionConditionTypeID,
               (CASE
                    WHEN m.blnAccessioned = 0 THEN
                        'Un-accessioned'
                    WHEN m.idfsSampleStatus IS NULL THEN
                        accessionConditionType.name
                    WHEN m.idfsSampleStatus = 10015007 --In Repository
               THEN
                        accessionConditionType.name
                    ELSE
                        sampleStatusType.name
                END
               ) AS AccessionConditionOrSampleStatusTypeName,
               m.idfAccesionByPerson AS AccessionByPersonID,
               ISNULL(accessionByPerson.strFamilyName, N'') + ISNULL(' ' + accessionByPerson.strFirstName, N'')
               + ISNULL(' ' + accessionByPerson.strSecondName, N'') AS AccessionByPersonName,
               m.idfsSampleStatus AS SampleStatusTypeID,
               m.strCondition AS AccessionComment,
               m.idfsDestructionMethod AS DestructionMethodTypeID,
               destructionMethodType.name AS DestructionMethodTypeName,
               m.datDestructionDate AS DestructionDate,
               m.idfDestroyedByPerson AS DestroyedByPersonID,
               ISNULL(
               (
                   SELECT COUNT(NULLIF(t4.idfTesting, 0))
                   FROM dbo.tlbTesting t4
                   WHERE t4.idfsTestStatus IN (   10001003,
                                                           --In Progress
                                                  10001004 --Preliminary
                                              )
                         AND t4.idfMaterial = m.idfMaterial
                         AND t4.intRowStatus = 0
                         AND t4.blnNonLaboratoryTest = 0
               ),
               0
                     ) AS TestAssignedCount,
               COUNT(tom.idfMaterial) AS TransferredCount,
               m.strNote AS Comment,
               m.idfsCurrentSite AS CurrentSiteID,
               m.idfsBirdStatus AS BirdStatusTypeID,
               m.idfMainTest AS MainTestID,
               m.idfsSampleKind AS SampleKindTypeID,
               m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
               m.LabModuleSourceIndicator,
               m.intRowStatus AS RowStatus
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000087) sampleType
                ON sampleType.idfsReference = m.idfsSampleType
            LEFT JOIN
            (
                SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
            ) f
                ON m.idfMaterial = f.SampleID
            LEFT JOIN dbo.tlbTesting t
                ON t.idfMaterial = m.idfMaterial
                   AND t.intRowStatus = 0
            LEFT JOIN dbo.tlbMaterial parentLabSample
                ON parentLabSample.idfMaterial = m.idfParentMaterial
                   AND parentLabSample.intRowStatus = 0
            LEFT JOIN dbo.tlbAnimal a
                ON a.idfAnimal = m.idfAnimal
                   AND a.intRowStatus = 0
            LEFT JOIN dbo.tlbVetCase vc
                ON vc.idfVetCase = m.idfVetCase
                   AND vc.intRowStatus = 0
            LEFT JOIN dbo.tlbMonitoringSession ms
                ON ms.idfMonitoringSession = m.idfMonitoringSession
                   AND ms.intRowStatus = 0
            LEFT JOIN dbo.FN_LAB_MONITORING_SESSION_DISEASES_GET(@LanguageID) msDiseases
                ON msDiseases.MonitoringSessionID = m.idfMonitoringSession
            LEFT JOIN dbo.FN_LAB_VECTOR_SESSION_DISEASES_GET(@LanguageID) vsDiseases
                ON vsDiseases.VectorSurveillanceSessionID = m.idfVectorSurveillanceSession
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName
                ON diseaseName.idfsReference = m.DiseaseID
            LEFT JOIN dbo.tlbVector AS v
                ON v.idfVector = m.idfVector
                   AND v.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOutMaterial tom
                ON tom.idfMaterial = m.idfMaterial
                   AND tom.intRowStatus = 0
            LEFT JOIN dbo.tlbTransferOUT tro
                ON tro.idfTransferOut = tom.idfTransferOut
                   AND tro.intRowStatus = 0
            LEFT JOIN dbo.tlbFreezerSubdivision fs
                ON fs.idfSubdivision = m.idfSubdivision
                   AND fs.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson collectedByPerson
                ON collectedByPerson.idfPerson = m.idfFieldCollectedByPerson
                   AND collectedByPerson.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) collectedByOrganization
                ON collectedByOrganization.idfOffice = m.idfFieldCollectedByOffice
            LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) sentToOrganization
                ON sentToOrganization.idfOffice = m.idfSendToOffice
            LEFT JOIN dbo.tlbDepartment d
                ON d.idfDepartment = m.idfInDepartment
                   AND d.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson destroyedByPerson
                ON destroyedByPerson.idfPerson = m.idfDestroyedByPerson
                   AND destroyedByPerson.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson accessionByPerson
                ON accessionByPerson.idfPerson = m.idfAccesionByPerson
                   AND accessionByPerson.intRowStatus = 0
            LEFT JOIN dbo.tlbPerson markedForDispositionByPerson
                ON markedForDispositionByPerson.idfPerson = m.idfMarkedForDispositionByPerson
                   AND markedForDispositionByPerson.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000164) functionalArea
                ON functionalArea.idfsReference = d.idfsDepartmentName
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000015) sampleStatusType
                ON sampleStatusType.idfsReference = m.idfsSampleStatus
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000110) accessionConditionType
                ON accessionConditionType.idfsReference = m.idfsAccessionCondition
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000157) destructionMethodType
                ON destructionMethodType.idfsReference = m.idfsDestructionMethod
            LEFT JOIN dbo.tlbSpecies AS species
                ON species.idfSpecies = m.idfSpecies
                   AND species.intRowStatus = 0
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000086) speciesType
                ON speciesType.idfsReference = species.idfsSpeciesType
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000140) vectorType
                ON vectorType.idfsReference = v.idfsVectorType
        WHERE m.idfMaterial = @SampleID
              AND m.intRowStatus = 0
        GROUP BY m.idfMaterial,
                 m.idfRootMaterial,
                 m.idfParentMaterial,
                 f.SampleID,
                 m.idfsSampleType,
                 sampleType.name,
                 parentLabSample.strBarcode,
                 m.idfMonitoringSession,
                 m.strFieldBarcode,
                 m.strCalculatedCaseID,
                 m.strCalculatedHumanName,
                 m.idfVectorSurveillanceSession,
                 m.idfHuman,
                 m.idfSpecies,
                 m.idfAnimal,
                 m.idfVector,
                 m.idfInDepartment,
                 functionalArea.name,
                 m.strBarcode,
                 m.idfHumanCase,
                 m.idfVetCase,
                 m.datFieldCollectionDate,
                 m.idfFieldCollectedByOffice,
                 collectedByOrganization.AbbreviatedName,
                 m.idfFieldCollectedByPerson,
                 collectedByPerson.strFamilyName,
                 collectedByPerson.strFirstName,
                 collectedByPerson.strSecondName,
                 m.datFieldSentDate,
                 m.idfSendToOffice,
                 sentToOrganization.AbbreviatedName,
                 m.datEnteringDate,
                 m.datDestructionDate,
                 m.datOutOfRepositoryDate,
                 m.idfMarkedForDispositionByPerson,
                 m.datAccession,
                 m.idfsAccessionCondition,
                 accessionConditionType.name,
                 m.idfsSampleStatus,
                 sampleStatusType.name,
                 m.strCondition,
                 m.idfsDestructionMethod,
                 destructionMethodType.name,
                 m.idfDestroyedByPerson,
                 m.idfAccesionByPerson,
                 accessionByPerson.strFamilyName,
                 accessionByPerson.strFirstName,
                 accessionByPerson.strSecondName,
                 m.idfSubdivision,
                 m.StorageBoxPlace,
                 a.strAnimalCode,
                 m.blnAccessioned,
                 m.blnReadOnly,
                 ms.idfMonitoringSession,
                 ms.SessionCategoryID,
                 m.strNote,
                 m.idfsSite,
                 m.idfsCurrentSite,
                 m.idfsBirdStatus,
                 m.idfMainTest,
                 m.idfsSampleKind,
                 m.PreviousSampleStatusID,
                 m.DiseaseID,
                 m.intRowStatus,
                 vc.idfsCaseType,
                 msDiseases.DiseaseID,
                 msDiseases.DiseaseName,
                 vsDiseases.DiseaseID,
                 vsDiseases.DiseaseName,
                 diseaseName.idfsReference,
                 diseaseName.name,
                 speciesType.name,
                 v.strVectorID,
                 vectorType.name,
                 m.LabModuleSourceIndicator;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
