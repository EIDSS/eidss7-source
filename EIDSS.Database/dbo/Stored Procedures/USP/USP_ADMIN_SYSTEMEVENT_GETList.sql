
-- ================================================================================================
-- Name: USP_ADMIN_SYSTEMEVENT_GETList		
--
-- Description: Gets a list of system events for a user as defined in SAUC60
--
-- Author: Mani Govindarajan
-- 
-- Revision History:
-- Name                        Date       Change Detail
-- --------------------------- ---------- --------------------------------------------------------
-- Mani Govindarajan                09/05/2022 Initial release
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEMEVENT_GETList]
(
    @LanguageId NVARCHAR(50),
    @UserId BIGINT = NULL,
    @FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@EventTypeId BIGINT =NULL,
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
                                                   WHEN @SortColumn = 'UserId'
                                                        AND @SortOrder = 'ASC' THEN
                                                       eventType.name
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = 'UserId'
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
                                                   WHEN @SortColumn = '@EventTypeId'
                                                        AND @SortOrder = 'ASC' THEN
                                                       e.idfsEventTypeID
                                               END ASC,
                                               CASE
                                                   WHEN @SortColumn = '@EventTypeId'
                                                        AND @SortOrder = 'DESC' THEN
                                                       e.idfsEventTypeID
                                               END DESC
                                              
                                     ) AS ROWNUM,
                   e.idfEventID AS EventId,
                   e.idfsEventTypeID AS EventTypeId,
				   e.strInformationString,
                   CASE
                       WHEN e.strInformationString IS NULL THEN
                           eventType.name
                       ELSE
                           e.strInformationString
                   END AS EventTypeName,
                   e.idfObjectID AS ObjectId,
                   e.datEventDatatime AS EventDate,
				   dbo.fnConcatFullName(strFamilyName, strFirstName, strSecondName)  AS strPersonName,
				   e.idfUserID,
				   p.idfPerson,
				   e.strNote as ViewUrl,
                   COUNT(*) OVER () AS TotalRowCount
            FROM dbo.tstEvent e
                INNER JOIN dbo.trtEventType et ON et.idfsEventTypeID = e.idfsEventTypeID 
				LEFT OUTER JOIN dbo.fnReferenceRepair(@LanguageId, 19000025) eventType On e.idfsEventTypeID = eventType.idfsReference
				LEFT OUTER JOIN dbo.LkupEIDSSMenuToEventType me on me.EventTypeID = e.idfsEventTypeID
				LEFT OUTER JOIN dbo.LkupEIDSSAppObject m on m.AppObjectNameID = me.EIDSSMenuID
			  LEFT OUTER JOIN	tstUserTable UT ON	UT.idfUserID = e.idfUserID
			  INNER JOIN	tlbPerson P ON		P.idfPerson = UT.idfPerson
			  WHERE 
						( 
							 CAST( e.datEventDatatime as DATE) >= cast(@FromDate as date)
							OR @FromDate is NULL
						)
					AND
						( 
							cast(e.datEventDatatime as date) <= cast(@ToDate as date)
							OR @ToDate is NULL
						)
					AND (e.idfsEventTypeID =@EventTypeId OR @EventTypeId IS NULL)
					AND (e.idfUserID =@UserId OR @UserId IS NULL)

           )
        SELECT EventId,
               EventTypeId,
			   strInformationString,
               EventTypeName,
               ObjectId,
               EventDate,
			   strPersonName,
			   idfUserID,
			   idfPerson,
			   ViewUrl,
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