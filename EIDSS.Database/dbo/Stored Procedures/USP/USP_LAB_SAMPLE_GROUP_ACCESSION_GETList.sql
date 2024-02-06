-- ================================================================================================
-- Name: USP_LAB_SAMPLE_GROUP_ACCESSION_GETList
--
-- Description:	Get sample group accession list for the laboratory module use case LUC01.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     12/15/2021 Initial relase.
-- Stephen Long     03/10/2022 Changed note to comment and transfer count to transferred count.
-- Stephen Long     05/24/2022 Removed read permission check and added group by on final results.
-- Stephen Long     07/28/2022 Added show in accession in form where criteria and removed unneeded
--                             joins.
-- Stephen Long     08/18/2022 Added/removed criteria to get only unaccessioned samples.
-- Stephen Long     09/29/2022 Bug fix on item 4778 and 4997.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_GROUP_ACCESSION_GETList]
(
    @LanguageID NVARCHAR(50),
    @EIDSSLocalOrFieldSampleIDList NVARCHAR(MAX) = NULL,
    @SentToOrganizationID BIGINT = NULL,
    @UserID BIGINT,
    @UserEmployeeID BIGINT,
    @UserSiteID BIGINT,
    @UserOrganizationID BIGINT = NULL,
    @UserSiteGroupID BIGINT = NULL,
    @Page INT = 1,
    @PageSize INT = 10,
    @SortColumn VARCHAR(200) = 'EIDSSReportOrSessionID',
    @SortOrder VARCHAR(4) = 'DESC'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Results TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        AccessionedIndicator BIT NOT NULL,
        AccessionConditionTypeID BIGINT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );
    DECLARE @FinalResults TABLE
    (
        ID BIGINT NOT NULL PRIMARY KEY,
        AccessionedIndicator BIT NOT NULL,
        AccessionConditionTypeID BIGINT NULL,
        ReadPermissionIndicator BIT NOT NULL,
        AccessToPersonalDataPermissionIndicator BIT NOT NULL,
        AccessToGenderAndAgeDataPermissionIndicator BIT NOT NULL,
        WritePermissionIndicator BIT NOT NULL,
        DeletePermissionIndicator BIT NOT NULL
    );
    DECLARE @RecordCount AS INT = 0,
            @UnaccessionedCount AS INT = 0
    DECLARE @Favorites XML,
            @FirstRecord INT = (@Page - 1) * @PageSize,
            @LastRecord INT = (@Page * @PageSize + 1),
            @LanguageCode BIGINT;
    DECLARE @SampleListTable TABLE (ID NVARCHAR(200) NOT NULL);


    BEGIN TRY
        SET @Favorites =
        (
            SELECT PreferenceDetail
            FROM dbo.UserPreference Laboratory
            WHERE idfUserID = @UserID
                  AND ModuleConstantID = 10508006
                  AND intRowStatus = 0
        );

        IF @EIDSSLocalOrFieldSampleIDList IS NOT NULL
            INSERT INTO @SampleListTable
            SELECT CAST([Value] AS NVARCHAR(200))
            FROM dbo.FN_GBL_SYS_SplitList(@EIDSSLocalOrFieldSampleIDList, NULL, ',');

        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               1,
               1,
               1,
               1,
               1
        FROM dbo.tlbMaterial m
        WHERE m.intRowStatus = 0
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND (
                      m.idfSendToOffice = @UserOrganizationID
                      OR @UserOrganizationID IS NULL
                  )
              AND m.idfsSampleType <> 10320001; --Unknown

        -- =======================================================================================
        -- CONFIGURABLE SITE FILTRATION RULES
        -- 
        -- Apply configurable site filtration rules for use case SAUC34. Some of these rules may 
        -- overlap the default rules.
        -- =======================================================================================
        --
        -- Apply at the user's site group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tflSiteToSiteGroup userSiteGroup
                ON userSiteGroup.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = userSiteGroup.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's employee group level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        -- 
        -- Apply at the user's ID level, granted by a site group.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tflSiteToSiteGroup grantingSGS
                ON grantingSGS.idfsSite = m.idfsSite
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteGroupID = grantingSGS.idfSiteGroup;

        --
        -- Apply at the user's site group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tflSiteToSiteGroup sgs
                ON sgs.idfsSite = @UserSiteID
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteGroupID = sgs.idfSiteGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND sgs.idfsSite = m.idfsSite;

        -- 
        -- Apply at the user's site level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorSiteID = @UserSiteID
                   AND ara.ActorEmployeeGroupID IS NULL
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's employee group level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tlbEmployeeGroupMember egm
                ON egm.idfEmployee = @UserEmployeeID
                   AND egm.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorEmployeeGroupID = egm.idfEmployeeGroup
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteID = m.idfsSite;

        -- 
        -- Apply at the user's ID level, granted by a site.
        --
        INSERT INTO @Results
        SELECT m.idfMaterial,
               m.blnAccessioned,
               m.idfsAccessionCondition,
               a.ReadPermissionIndicator,
               a.AccessToPersonalDataPermissionIndicator,
               a.AccessToGenderAndAgeDataPermissionIndicator,
               a.WritePermissionIndicator,
               a.DeletePermissionIndicator
        FROM dbo.tlbMaterial m
            INNER JOIN dbo.tstUserTable u
                ON u.idfPerson = @UserEmployeeID
                   AND u.intRowStatus = 0
            INNER JOIN dbo.AccessRuleActor ara
                ON ara.ActorUserID = u.idfUserID
                   AND ara.intRowStatus = 0
            INNER JOIN dbo.AccessRule a
                ON a.AccessRuleID = ara.AccessRuleID
                   AND a.intRowStatus = 0
                   AND a.DefaultRuleIndicator = 0
        WHERE m.intRowStatus = 0
              AND m.idfsSampleType <> 10320001 --Unknown
              AND m.strFieldBarcode IN (
                                           SELECT ID FROM @SampleListTable
                                       )
              AND a.GrantingActorSiteID = m.idfsSite;

        INSERT INTO @FinalResults
        SELECT ID,
               AccessionedIndicator,
               AccessionConditionTypeID,
               CASE
                   WHEN EXISTS
                        (
                            SELECT ReadPermissionIndicator FROM @Results WHERE ID = ID
                        ) THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN EXISTS
                        (
                            SELECT AccessToPersonalDataPermissionIndicator FROM @Results WHERE ID = ID
                        ) THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN EXISTS
                        (
                            SELECT AccessToGenderAndAgeDataPermissionIndicator
                            FROM @Results
                            WHERE ID = ID
                        ) THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN EXISTS
                        (
                            SELECT WritePermissionIndicator FROM @Results WHERE ID = ID
                        ) THEN
                       1
                   ELSE
                       0
               END,
               CASE
                   WHEN EXISTS
                        (
                            SELECT DeletePermissionIndicator FROM @Results WHERE ID = ID
                        ) THEN
                       1
                   ELSE
                       0
               END
        FROM @Results
        GROUP BY ID,
                 AccessionedIndicator,
                 AccessionConditionTypeID;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        SET @UnaccessionedCount =
        (
            SELECT COUNT(ID)
            FROM @FinalResults
            WHERE AccessionedIndicator = 0
                  AND AccessionConditionTypeID IS NULL
        );

        SELECT SampleID,
               EIDSSLaboratorySampleID,
               FavoriteIndicator,
               RootSampleID,
               ParentSampleID,
               SampleTypeID,
               SampleTypeName,
               HumanID,
               PatientOrFarmOwnerName,
               SpeciesID,
               AnimalID,
               EIDSSAnimalID,
               VectorID,
               MonitoringSessionID,
               VectorSessionID,
               HumanDiseaseReportID,
               VeterinaryDiseaseReportID,
               EIDSSReportOrSessionID,
               TestCompletedIndicator,
               DiseaseID,
               DiseaseName,
               FunctionalAreaID,
               FunctionalAreaName,
               FreezerSubdivisionID,
               StorageBoxPlace,
               CollectionDate,
               CollectedByPersonID,
               CollectedByOrganizationID,
               SentDate,
               SentToOrganizationID,
               SentToOrganizationName,
               SiteID,
               EIDSSLocalOrFieldSampleID,
               EnteredDate,
               OutOfRepositoryDate,
               MarkedForDispositionByPersonID,
               ReadOnlyIndicator,
               AccessionIndicator,
               AccessionDate,
               AccessionConditionTypeID,
               AccessionConditionOrSampleStatusTypeName,
               AccessionByPersonID,
               SampleStatusTypeID,
               SampleStatusDate,
               AccessionComment,
               DestructionMethodTypeID,
               DestructionDate,
               DestroyedByPersonID,
               TestAssignedCount,
               TransferredCount,
               Comment,
               CurrentSiteID,
               BirdStatusTypeID,
               MainTestID,
               SampleKindTypeID,
               PreviousSampleStatusTypeID,
               LabModuleSourceIndicator,
               RowStatus,
               ReadPermissionIndicator,
               AccessToPersonalDataPermissionIndicator,
               AccessToGenderAndAgeDataPermissionIndicator,
               WritePermissionIndicator,
               DeletePermissionIndicator,
               RowAction,
               RowSelectionIndicator,
               TotalRowCount,
               UnaccessionedSampleCount
        FROM
        (
            SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'EIDSSReportOrSessionID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       m.strCalculatedCaseID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSReportOrSessionID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       m.strCalculatedCaseID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       m.strFieldBarcode
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSLocalOrFieldSampleID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       m.strFieldBarcode
                                               END DESC
                                     ) AS RowNum,
                   m.idfMaterial AS SampleID,
                   m.strBarcode AS EIDSSLaboratorySampleID,
                   CASE
                       WHEN f.SampleID IS NULL THEN
                           0
                       ELSE
                           1
                   END AS FavoriteIndicator,
                   m.idfRootMaterial AS RootSampleID,
                   m.idfParentMaterial AS ParentSampleID,
                   m.idfsSampleType AS SampleTypeID,
                   sampleType.name AS SampleTypeName,
                   m.idfHuman AS HumanID,
                   CASE
                       WHEN res.AccessToPersonalDataPermissionIndicator = 0 THEN
                           '**********'
                       ELSE
                           m.strCalculatedHumanName
                   END AS PatientOrFarmOwnerName,
                   m.idfSpecies AS SpeciesID,
                   m.idfAnimal AS AnimalID,
                   a.strAnimalCode AS EIDSSAnimalID,
                   m.idfVector AS VectorID,
                   m.idfMonitoringSession AS MonitoringSessionID,
                   m.idfVectorSurveillanceSession AS VectorSessionID,
                   m.idfHumanCase AS HumanDiseaseReportID,
                   m.idfVetCase AS VeterinaryDiseaseReportID,
                   m.strCalculatedCaseID AS EIDSSReportOrSessionID,
                   m.TestCompletedIndicator,
                   '' AS DiseaseID,
                   '' AS DiseaseName,
                   m.idfInDepartment AS FunctionalAreaID,
                   functionalArea.name AS FunctionalAreaName,
                   m.idfSubdivision AS FreezerSubdivisionID,
                   m.StorageBoxPlace,
                   m.datFieldCollectionDate AS CollectionDate,
                   m.idfFieldCollectedByPerson AS CollectedByPersonID,
                   m.idfFieldCollectedByOffice AS CollectedByOrganizationID,
                   m.datFieldSentDate AS SentDate,
                   m.idfSendToOffice AS SentToOrganizationID,
                   sentToOrganization.AbbreviatedName AS SentToOrganizationName,
                   m.idfsSite AS SiteID,
                   m.strFieldBarcode AS EIDSSLocalOrFieldSampleID,
                   m.datEnteringDate AS EnteredDate,
                   m.datOutOfRepositoryDate AS OutOfRepositoryDate,
                   m.idfMarkedForDispositionByPerson AS MarkedForDispositionByPersonID,
                   m.blnReadOnly AS ReadOnlyIndicator,
                   m.blnAccessioned AS AccessionIndicator,
                   accessionConditionType.name AS AccessionConditionTypeName,
                   m.datAccession AS AccessionDate,
                   m.idfsAccessionCondition AS AccessionConditionTypeID,
                   (CASE
                        WHEN m.blnAccessioned = 0
                             AND m.idfsAccessionCondition IS NULL THEN
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
                   sampleStatusType.name AS SampleStatusTypeName,
                   m.idfAccesionByPerson AS AccessionByPersonID,
                   m.idfsSampleStatus AS SampleStatusTypeID,
                   m.datSampleStatusDate AS SampleStatusDate,
                   m.strCondition AS AccessionComment,
                   m.idfsDestructionMethod AS DestructionMethodTypeID,
                   m.datDestructionDate AS DestructionDate,
                   m.idfDestroyedByPerson AS DestroyedByPersonID,
                   CASE
                       WHEN m.TestUnassignedIndicator = 1 THEN
                           0
                       ELSE
                           1
                   END AS TestAssignedCount,
                   m.TransferIndicator AS TransferredCount,
                   m.strNote AS Comment,
                   m.idfsCurrentSite AS CurrentSiteID,
                   m.idfsBirdStatus AS BirdStatusTypeID,
                   m.idfMainTest AS MainTestID,
                   m.idfsSampleKind AS SampleKindTypeID,
                   m.PreviousSampleStatusID AS PreviousSampleStatusTypeID,
                   m.LabModuleSourceIndicator,
                   m.intRowStatus AS RowStatus,
                   res.ReadPermissionIndicator,
                   res.AccessToPersonalDataPermissionIndicator,
                   res.AccessToGenderAndAgeDataPermissionIndicator,
                   res.WritePermissionIndicator,
                   res.DeletePermissionIndicator,
                   0 AS RowAction,
                   0 AS RowSelectionIndicator,
                   @Page AS CurrentPage,
                   COUNT(*) OVER () AS TotalRowCount,
                   @UnaccessionedCount AS UnaccessionedSampleCount
            FROM @FinalResults res
                INNER JOIN dbo.tlbMaterial m
                    ON m.idfMaterial = res.ID
                INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000087) sampleType
                    ON sampleType.idfsReference = m.idfsSampleType
                LEFT JOIN
                (
                    SELECT SampleID = UserPref.value('@SampleID', 'bigint')
                    FROM @Favorites.nodes('/Favorites/Favorite') AS Tbl(UserPref)
                ) f
                    ON m.idfMaterial = f.SampleID
                LEFT JOIN dbo.tlbAnimal a
                    ON a.idfAnimal = m.idfAnimal
                       AND a.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) sentToOrganization
                    ON sentToOrganization.idfOffice = m.idfSendToOffice
                LEFT JOIN dbo.tlbDepartment d
                    ON d.idfDepartment = m.idfInDepartment
                       AND d.intRowStatus = 0
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000164) functionalArea
                    ON functionalArea.idfsReference = d.idfsDepartmentName
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000015) sampleStatusType
                    ON sampleStatusType.idfsReference = m.idfsSampleStatus
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000110) accessionConditionType
                    ON accessionConditionType.idfsReference = m.idfsAccessionCondition
        ) AS x
        WHERE RowNum > @FirstRecord
              AND RowNum < @LastRecord
        ORDER BY RowNum;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
