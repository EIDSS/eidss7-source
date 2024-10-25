-- ================================================================================================
-- Name: USP_ADMIN_EVENT_GETList		
--
-- Description: Gets a list of event notifications for a user as defined in SAUC55 and SAUC56.
--
-- Author: Stephen Long
-- 
-- Revision History:
-- Name                        Date       Change Detail
-- --------------------------- ---------- --------------------------------------------------------
-- Stephen Long                07/06/2022 Initial release
-- Stephen Long                07/28/2022 Added sort fields.
-- Stephen Long                08/18/2022 Fixed reference type for the event type.
-- Stephen Long                08/29/2022 Added trtEventType join and correct reference type name.
-- Stephen Long                03/20/2023 Added parenthesis to group processed indicator.
-- Stephen Long                03/22/2023 Added nolock
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EVENT_GETList]
(
    @LanguageId NVARCHAR(50),
    @UserId BIGINT,
    @DaysFromReadDate INT,
    @PageNo INT = 1,
    @PageSize INT = 10,
    @SortColumn NVARCHAR(100) = 'EventDate',
    @SortOrder VARCHAR(4) = 'DESC'
)
AS
BEGIN
    DECLARE @FirstRec INT = (@PageNo - 1) * @PageSize,
            @LastRec INT = (@PageNo * @PageSize + 1);

    BEGIN TRY
        WITH CTEResults
        AS (SELECT ROW_NUMBER() OVER (ORDER BY CASE
                                                   WHEN @SortColumn = 'EventTypeName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       eventType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EventTypeName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       eventType.name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EventDate'
                                                        AND @SortOrder = 'ASC' THEN
                                                       e.datEventDatatime
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EventDate'
                                                        AND @SortOrder = 'DESC' THEN
                                                       e.datEventDatatime
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSSiteID'
                                                        AND @SortOrder = 'ASC' THEN
                                                       s.strSiteID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'EIDSSSiteID'
                                                        AND @SortOrder = 'DESC' THEN
                                                       s.strSiteID
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel2Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel2Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel2Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel3Name'
                                                        AND @SortOrder = 'ASC' THEN
                                                       lh.AdminLevel3Name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'AdministrativeLevel3Name'
                                                        AND @SortOrder = 'DESC' THEN
                                                       lh.AdminLevel3Name
                                               END DESC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'ASC' THEN
                                                       disease.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'DiseaseName'
                                                        AND @SortOrder = 'DESC' THEN
                                                       disease.name
                                               END DESC
                                     ) AS ROWNUM,
                   e.idfEventID AS EventId,
                   e.idfsEventTypeID AS EventTypeId,
                   CASE
                       WHEN e.strInformationString IS NULL THEN
                           eventType.name
                       ELSE
                           e.strInformationString
                   END AS EventTypeName,
                   notificationType.name AS NotificationTypeName,
                   e.idfObjectID AS ObjectId,
                   disease.name AS DiseaseName,
                   e.idfsSite AS SiteId,
                   s.strSiteID AS EIDSSSiteID,
                   lh.AdminLevel2Name AS AdministrativeLevel2Name,
                   lh.AdminLevel3Name AS AdministrativeLevel3Name,
                   e.intProcessed AS ProcessedIndicator,
                   e.datEventDatatime AS EventDate,
                   COUNT(*) OVER () AS TotalRowCount
            FROM dbo.tstEvent e WITH (NOLOCK)
                INNER JOIN dbo.trtEventType et
                    ON et.idfsEventTypeID = e.idfsEventTypeID
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000155) notificationType
                    ON notificationType.idfsReference = et.idfsEventSubscription
                INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000025) eventType
                    ON eventType.idfsReference = e.idfsEventTypeID
                LEFT JOIN dbo.tstSite s
                    ON s.idfsSite = e.idfsSite
                LEFT JOIN dbo.gisLocation g
                    ON g.idfsLocation = e.idfsLocation
                LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageId) lh
                    ON lh.idfsLocation = g.idfsLocation
                LEFT JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease
                    ON disease.idfsReference = e.idfsDiagnosis
            WHERE e.idfUserID = @UserId
                  AND (
                          (e.intProcessed = 0)
                          OR (
                                 e.intProcessed = 1
                                 AND GETDATE() <= DATEADD(DAY, @DaysFromReadDate, e.datEventDatatime)
                             )
                      )
           )
        SELECT EventId,
               EventTypeId,
               EventTypeName,
               ObjectId,
               DiseaseName,
               SiteId,
               EIDSSSiteID,
               AdministrativeLevel2Name,
               AdministrativeLevel3Name,
               ProcessedIndicator,
               EventDate,
               TotalRowCount,
               TotalPages = (TotalRowCount / @PageSize) + IIF(TotalRowCount % @PageSize > 0, 1, 0),
               CurrentPage = @pageNo
        FROM CTEResults
        WHERE RowNum > @FirstRec
              AND RowNum < @LastRec;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH

END