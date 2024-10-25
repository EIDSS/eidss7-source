-- ================================================================================================
-- Name: USP_ADMIN_EVENT_SUBSCRIPTION_GETList	
--
-- Description: Gets a list of alert/event subscription types for user notifications.
--
-- Author: Stephen Long
--
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Stephen Long             07/01/2022 Initial release
-- Stephen Long             09/07/2022 Fix on the event type reference type from 155 to 25.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EVENT_SUBSCRIPTION_GETList] 
	@LanguageId VARCHAR(50) = NULL,
	@SiteAlertName NVARCHAR(255) = NULL,
	@UserId BIGINT, 
	@PageNo INT = 1,
	@PageSize INT = 10,
	@SortColumn NVARCHAR(30) = 'EventTypeName',
	@SortOrder NVARCHAR(4) = 'ASC'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FirstRec INT,
		@LastRec INT;

	SET @FirstRec = (@PageNo - 1) * @PageSize;
	SET @LastRec = (@PageNo * @PageSize + 1);

	BEGIN TRY
	WITH CTEResults AS
		(
		SELECT ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'EventTypeName' AND @SortOrder = 'ASC' THEN eventSubscriptionType.name END ASC,
			CASE WHEN @sortColumn = 'EventTypeName' AND @SortOrder = 'DESC' THEN eventSubscriptionType.name END DESC
			) AS RowId,
			e.EventNameId,
			et.idfsEventTypeID AS EventTypeId,
			eventSubscriptionType.name AS EventTypeName,
			e.ReceiveAlertFlag AS ReceiveAlertIndicator,
			e.AlertRecipient, 
			e.idfUserID AS UserId, 
			e.intRowStatus AS RowStatus,
			COUNT(*) OVER () AS TotalRowCount
		FROM dbo.trtEventType et
		LEFT JOIN dbo.EventSubscription e
			ON e.EventNameId = et.idfsEventTypeID
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LanguageId, 19000155) eventSubscriptionType
			ON et.idfsEventSubscription = eventSubscriptionType.idfsReference
				AND eventSubscriptionType.intRowStatus = 0
		WHERE e.idfUserID = @UserId
			AND et.intRowStatus = 0
			AND (
				eventSubscriptionType.name LIKE '%' + @SiteAlertName + '%'
				OR @SiteAlertName IS NULL
				)
		)
		SELECT
		    RowId, 
			EventNameId,
			EventTypeId,
			EventTypeName,
			ReceiveAlertIndicator,
			AlertRecipient, 
			UserId, 
			RowStatus,
			TotalPages = (TotalRowCount / @PageSize) + IIF(TotalRowCount % @PageSize > 0, 1, 0),
			CurrentPage = @PageNo, 
			TotalRowCount
		FROM CTEResults
		WHERE RowId > @FirstRec AND RowId < @LastRec;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
