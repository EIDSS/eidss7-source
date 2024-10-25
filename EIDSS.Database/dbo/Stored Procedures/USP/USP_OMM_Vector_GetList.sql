-- ================================================================================================
-- Name: USP_OMM_VECTOR_GetList
--
-- Description: Gets a list of vector surveillance sessions filtered by various criteria.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Doug Albanese    10/16/2019 Created new procedure for obtaining Vector Sessions
-- Stephen Long     05/04/2022 Added search term and updated for admin levels.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Vector_GetList]
(
    @LanguageID NVARCHAR(50),
    @OutbreakKey BIGINT,
    @SearchTerm NVARCHAR(MAX) = NULL,
    @SortColumn NVARCHAR(30) = 'SessionID',
    @SortOrder NVARCHAR(4) = 'DESC',
    @PageNumber INT = 1,
    @PageSize INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Results TABLE (ID BIGINT NOT NULL);

    BEGIN TRY
        INSERT INTO @Results
        SELECT vss.idfVectorSurveillanceSession
        FROM dbo.tlbVectorSurveillanceSession vss
        WHERE vss.intRowStatus = 0
              AND vss.idfOUtBreak = @OutbreakKey;

        -- ========================================================================================
        -- FINAL QUERY, PAGINATION AND COUNTS
        -- ========================================================================================
        WITH paging
        AS (SELECT ID,
                   c = COUNT(*) OVER ()
            FROM @Results res
                INNER JOIN dbo.tlbVectorSurveillanceSession vss
                    ON vss.idfVectorSurveillanceSession = res.ID
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000133) sessionStatusType
                    ON sessionStatusType.idfsReference = vss.idfsVectorSurveillanceStatus
                LEFT JOIN dbo.tlbGeoLocation geo
                    ON geo.idfGeoLocation = vss.idfLocation
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = geo.idfsLocation
                LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000003) adminLevel1
                    ON adminLevel1.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel1Ancestor(g.node.GetLevel()))
                LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(@LanguageID, 19000002) adminLevel2
                    ON adminLevel2.node = g.node.GetAncestor(dbo.FN_GIS_Location_GetLevel2Ancestor(g.node.GetLevel()))
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESNAMES_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseases
            ) diseases
                CROSS APPLY
            (
                SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPENAMES_GET(vss.idfVectorSurveillanceSession, @LanguageID) vectorTypes
            ) vectorTypes
            ORDER BY CASE
                         WHEN @SortColumn = 'SessionID'
                              AND @SortOrder = 'ASC' THEN
                             vss.strSessionID
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'SessionID'
                              AND @SortOrder = 'DESC' THEN
                             vss.strSessionID
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'SessionStatusTypeName'
                              AND @SortOrder = 'ASC' THEN
                             sessionStatusType.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'SessionStatusTypeName'
                              AND @SortOrder = 'DESC' THEN
                             sessionStatusType.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'StartDate'
                              AND @SortOrder = 'ASC' THEN
                             vss.datStartDate
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'StartDate'
                              AND @SortOrder = 'DESC' THEN
                             vss.datStartDate
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'CloseDate'
                              AND @SortOrder = 'ASC' THEN
                             vss.datCloseDate
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'CloseDate'
                              AND @SortOrder = 'DESC' THEN
                             vss.datCloseDate
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel1Name'
                              AND @SortOrder = 'ASC' THEN
                             adminLevel1.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel1Name'
                              AND @SortOrder = 'DESC' THEN
                             adminLevel1.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel2Name'
                              AND @SortOrder = 'ASC' THEN
                             adminLevel2.name
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'AdministrativeLevel2Name'
                              AND @SortOrder = 'DESC' THEN
                             adminLevel2.name
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'VectorType'
                              AND @SortOrder = 'ASC' THEN
                             vectorTypes.vectorTypes
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'VectorType'
                              AND @SortOrder = 'DESC' THEN
                             vectorTypes.vectorTypes
                     END DESC,
                     CASE
                         WHEN @SortColumn = 'Disease'
                              AND @SortOrder = 'ASC' THEN
                             diseases.diseases
                     END ASC,
                     CASE
                         WHEN @SortColumn = 'Disease'
                              AND @SortOrder = 'DESC' THEN
                             diseases.diseases
                     END DESC OFFSET @PageSize * (@PageNumber - 1) ROWS FETCH NEXT @PageSize ROWS ONLY
           )
        SELECT idfVectorSurveillanceSession AS SessionKey,
               strSessionID AS SessionID,
               vss.strFieldSessionID AS FieldSessionID,
               vss.idfOUtBreak AS OutbreakKey,
               o.strOutbreakID AS OutbreakID,
               o.datStartDate AS OutbreakStartDate,
               vectorTypeIDs.vectorTypeIDs AS VectorTypeIDs,
               vectorTypes.vectorTypes AS Vectors,
               diseaseIDs.diseaseIDs AS DiseaseIDs,
               diseases.diseases AS Diseases,
               statusType.name AS StatusTypeName,
               lh.AdminLevel2Name AS AdministrativeLevel1Name,
               lh.AdminLevel3Name AS AdministrativeLevel2Name,
               settlementType.name AS SettlementName,
               geo.dblLatitude AS Latitude,
               geo.dblLongitude AS Longitude,
               vss.datStartDate AS StartDate,
               vss.datCloseDate AS CloseDate,
               vss.idfsSite AS SiteID,
               c AS RecordCount,
               (
                   SELECT COUNT(*)
                   FROM dbo.tlbVectorSurveillanceSession
                   WHERE intRowStatus = 0
               ) AS TotalCount,
               CurrentPage = @PageNumber,
               TotalPages = (c / @PageSize) + IIF(c % @PageSize > 0, 1, 0)
        FROM @Results res
            INNER JOIN paging
                ON paging.ID = res.ID
            INNER JOIN dbo.tlbVectorSurveillanceSession vss
                ON vss.idfVectorSurveillanceSession = paging.ID
            LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000133) statusType
                ON statusType.idfsReference = vss.idfsVectorSurveillanceStatus
            LEFT JOIN dbo.tlbGeoLocation geo
                ON geo.idfGeoLocation = vss.idfLocation
            LEFT JOIN dbo.gisLocation g
                ON g.idfsLocation = geo.idfsLocation
            LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) lh
                ON lh.idfsLocation = geo.idfsLocation
            LEFT JOIN dbo.gisLocation settlement
                ON settlement.idfsLocation = geo.idfsLocation
                   AND settlement.idfsType IS NOT NULL
            LEFT JOIN dbo.FN_GBL_GIS_REFERENCE(@LanguageID, 19000004) settlementType 
                ON settlementType.idfsReference = settlement.idfsLocation
            LEFT JOIN dbo.tlbOutbreak o
                ON o.idfOutbreak = vss.idfOutbreak
                   AND o.intRowStatus = 0
            CROSS APPLY
        (
            SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESIDS_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseaseIDs
        ) diseaseIDs
            CROSS APPLY
        (
            SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPEIDS_GET(vss.idfVectorSurveillanceSession) vectorTypeIDs
        ) vectorTypeIDs
            CROSS APPLY
        (
            SELECT dbo.FN_VCTS_VSSESSION_DIAGNOSESNAMES_GET(vss.idfVectorSurveillanceSession, @LanguageID) diseases
        ) diseases
            CROSS APPLY
        (
            SELECT dbo.FN_VCTS_VSSESSION_VECTORTYPENAMES_GET(vss.idfVectorSurveillanceSession, @LanguageID) vectorTypes
        ) vectorTypes
        WHERE vss.strSessionID LIKE '%' + @SearchTerm + '%'
              OR statusType.name LIKE '%' + @SearchTerm + '%'
              OR vss.datStartDate LIKE '%' + @SearchTerm + '%'
              OR vss.datCloseDate LIKE '%' + @SearchTerm + '%'
              OR lh.AdminLevel2Name LIKE '%' + @SearchTerm + '%'
              OR lh.AdminLevel3Name LIKE '%' + @SearchTerm + '%'
              OR lh.AdminLevel4Name LIKE '%' + @SearchTerm + '%'
              OR lh.AdminLevel5Name LIKE '%' + @SearchTerm + '%'
              OR lh.AdminLevel6Name LIKE '%' + @SearchTerm + '%'
              OR lh.AdminLevel7Name LIKE '%' + @SearchTerm + '%'
              OR diseases.diseases LIKE '%' + @SearchTerm + '%'
              OR vectorTypes.vectorTypes LIKE '%' + @SearchTerm + '%'
              OR geo.dblLatitude LIKE '%' + @SearchTerm + '%'
              OR geo.dblLongitude LIKE '%' + @SearchTerm + '%'
              OR @SearchTerm IS NULL;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
