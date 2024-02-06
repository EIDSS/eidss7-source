--=====================================================================================================
-- Name: USP_HAS_DetailedInformation_GetList
-- Author:		Doug Albanese
-- Description:	Returns a list of "Detailed Information" for sample type/disease association
--
--							
-- Revision History:
--	Name            Date		Change Detail
--	--------------- ----------	-----------------------------------------------
--	Doug Albanese	12/20/2021	Initial Release
--	Doug Albanese	12/21/2021	Refactored for filtering and paging
--	Doug Albanese	12/30/2021	Added 'comment' field.
--	Doug Albanese	01/12/2022	Added 'idfsSampleType', 'idfSendToOffice', 'HumanMasterID' fields.
--	Doug Albanese	01/25/2022	Added missing logic to determine first and last record of the page
--	Doug Albanese	01/28/2022	Added Disease Id
--	Doug Albanese	02/01/2022	Changed source for comments to tlbMaterial strNote
--	Doug Albanese	02/03/2022	Fixed the person id return problem.
--	Doug Albanese	05/26/2022	Corrected mismatched Id, was idfMonitoringSession...should have been idfMaterial
--	Doug Albanese	07/13/2022	Duplicate "Samples" were being generated, due to missing join fields for tlbMonitoringSessionToDiagnosis, against tlbMaterial.DiseaseID and
--								MonitoringSessionToSampleType, against tlbMonitoringSessionToDiagnosis.idfsSampleType
--	Doug Albanese	07/18/2022	Add "Distinct" to eliminate all other conditions that produced duplicates
--	Doug Albanese	07/26/2022	Changed the join on MonitoringSessionToSampleType, to a LEFT join.
-- Stephen Long     08/13/2022  Added person's name field.
-- Doug Albanese	 10/11/2022	 Added intRowStatus check
-- Stephen Long     10/18/2022  Changed join to use tlbMonitoringSessionToMaterial.
--
-- Test Code:
-- EXEC USP_HAS_DetailedInformation_GetList @LanguageId='en', @idfMonitoringSession = 404
-- 
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_HAS_DetailedInformation_GetList]
(
    @LanguageId NVARCHAR(50),
    @idfMonitoringSession BIGINT,
    @advancedSearch NVARCHAR(100) = NULL,
    @pageNo INT = 1,
    @pageSize INT = 10,
    @sortColumn NVARCHAR(30) = 'ResultDate',
    @sortOrder NVARCHAR(4) = 'DESC'
)
AS
BEGIN
    BEGIN TRY
        DECLARE @firstRec INT
        DECLARE @lastRec INT

        SET @firstRec = (@pageNo - 1) * @pagesize
        SET @lastRec = (@pageNo * @pageSize + 1)

        DECLARE @MonitoringSessionDiseases TABLE
        (
            ID BIGINT NOT NULL INDEX IX1 CLUSTERED,
            DiseaseIdentifiers VARCHAR(MAX) NOT NULL,
            DiseaseNames NVARCHAR(MAX) NOT NULL
        );

        DECLARE @Results TABLE
        (
            ID BIGINT,
            HumanMasterID BIGINT,
            PersonID BIGINT,
            EIDSSPersonID NVARCHAR(200),
            PersonName NVARCHAR(MAX),
            PersonAddress NVARCHAR(200),
            FieldSampleID NVARCHAR(200),
            DiseaseID NVARCHAR(MAX),
            Disease NVARCHAR(MAX),
            idfsSampleType BIGINT,
            SampleType NVARCHAR(200),
            CollectionDate DATETIME,
            idfSendToOffice BIGINT,
            SentToOrganization NVARCHAR(200),
            Comment NVARCHAR(MAX)
        );

        INSERT INTO @MonitoringSessionDiseases
        SELECT SampleID,
               STRING_AGG(DiseaseID, ',') AS DiseaseIdentifiers,
               STRING_AGG(DiseaseName, '|') AS DiseaseNames
        FROM dbo.FN_AS_SAMPLE_DISEASES_GET(@LanguageID, @idfMonitoringSession)
        GROUP BY SampleID;

        INSERT INTO @Results
        SELECT DISTINCT
            M.idfMaterial AS ID,
            H.idfHumanActual AS HumanMasterID,
            M.idfHuman AS PersonID,
            HAI.EIDSSPersonID AS EIDSSPersonID,
            dbo.FN_GBL_ConcatFullName(H.strLastName, H.strFirstName, H.strSecondName) AS PersonName,
            GL.strAddressString AS PersonAddress,
            strFieldBarcode AS FieldSampleID,
            CASE WHEN m.DiseaseID IS NOT NULL THEN
                CONVERT(NVARCHAR(MAX), m.DiseaseID) 
            ELSE
                msDiseases.DiseaseIdentifiers
            END AS DiseaseID,
            CASE WHEN m.DiseaseID IS NOT NULL THEN
                diseaseName.name 
            ELSE
                msDiseases.DiseaseNames 
            END AS Disease,
            M.idfsSampleType,
            S.name AS SampleType,
            M.datFieldCollectionDate CollectionDate,
            M.idfSendToOffice,
            OFFICE.name AS SentToOrganization,
            M.strNote AS Comment
        FROM dbo.tlbMaterial M
            LEFT JOIN @MonitoringSessionDiseases msDiseases -- For monitoring session samples added via human, veterinary or laboratory modules
                ON msDiseases.ID = m.idfMaterial
            LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) diseaseName -- For laboratory transferred samples
                ON diseaseName.idfsReference = m.DiseaseID
            INNER JOIN dbo.tlbHuman H
                ON H.idfHuman = M.idfHuman
            INNER JOIN dbo.tlbHumanActual HA
                ON HA.idfHumanActual = H.idfHumanActual
            INNER JOIN dbo.tlbGeoLocation GL
                ON GL.idfGeoLocation = H.idfCurrentResidenceAddress
            INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageId, 19000087) S
                ON S.idfsReference = M.idfsSampleType
            INNER JOIN dbo.tlbOffice O
                ON O.idfOffice = M.idfSendToOffice
            INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageId, 19000046) OFFICE
                ON OFFICE.idfsReference = O.idfsOfficeName
            INNER JOIN dbo.HumanActualAddlInfo HAI
                ON HAI.HumanActualAddlInfoUID = HA.idfHumanActual
        WHERE M.idfMonitoringSession = @idfMonitoringSession
              AND M.intRowStatus = 0;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'ID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       ID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'ID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       ID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       PersonID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       PersonID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonAddress'
                                                        AND @SortOrder = 'ASC' THEN
                                                       PersonAddress
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'PersonAddress'
                                                        AND @SortOrder = 'DESC' THEN
                                                       PersonAddress
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'FieldSampleID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       FieldSampleID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'FieldSampleID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       FieldSampleID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Disease'
                                                        AND @SortOrder = 'ASC' THEN
                                                       Disease
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Disease'
                                                        AND @SortOrder = 'DESC' THEN
                                                       Disease
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SampleType'
                                                        AND @SortOrder = 'ASC' THEN
                                                       SampleType
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SampleType'
                                                        AND @SortOrder = 'DESC' THEN
                                                       SampleType
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'CollectionDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       CollectionDate
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'CollectionDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       CollectionDate
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'SentToOrganization'
                                                        AND @SortOrder = 'ASC' THEN
                                                       SentToOrganization
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'SentToOrganization'
                                                        AND @SortOrder = 'DESC' THEN
                                                       SentToOrganization
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'Comment'
                                                        AND @SortOrder = 'ASC' THEN
                                                       Comment
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'Comment'
                                                        AND @SortOrder = 'DESC' THEN
                                                       Comment
                                               END DESC
                                     ) AS ROWNUM,
                   COUNT(*) OVER () AS TotalRowCount,
                   ID,
                   HumanMasterID,
                   PersonID,
                   EIDSSPersonID,
                   PersonName,
                   PersonAddress,
                   FieldSampleID,
                   DiseaseID,
                   Disease,
                   idfsSampleType,
                   SampleType,
                   CollectionDate,
                   idfSendToOffice,
                   SentToOrganization,
                   Comment
            FROM @Results
           )
        SELECT TotalRowCount,
               ID,
               HumanMasterID,
               PersonID,
               EIDSSPersonID,
               PersonName,
               PersonAddress,
               FieldSampleID,
               DiseaseID,
               Disease,
               idfsSampleType,
               SampleType,
               CollectionDate,
               idfSendToOffice,
               SentToOrganization,
               Comment,
               TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @firstRec
              AND RowNum < @lastRec;
    END TRY
    BEGIN CATCH

    END CATCH
END
