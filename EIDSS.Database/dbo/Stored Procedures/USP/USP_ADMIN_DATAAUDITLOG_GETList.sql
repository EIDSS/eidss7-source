
-- =============================================
-- Author:		Manickandan Govindarajan
-- Create date: 06/20/2022
-- Description:	Gets the audit event list for the given parameters
-- Manickandan Govidarajan 11/22/2022 - Added additional out columns
-- Manickandan Govindarajan 11/3/2022 - Updated condition
-- Manickandan Govindarajan 01/24/2023  - Added logic to searcg @idfObjectId in related tables

-- =============================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DATAAUDITLOG_GETList]
	@languageId AS NVARCHAR(50),
	@startDate DateTime = NULL,
	@endDate DateTime = NULL,
	@idfUserId BIGINT = NULL,
	@idfSiteId BIGINT = NULL, 
	@idfActionId BIGINT = NULL, 
	@idfObjetType BIGINT = NULL, 
	@idfObjectId NVARCHAR(50) =NULL,
	@SortColumn NVARCHAR(30) = 'TransactionDate',
	@SortOrder NVARCHAR(4) = 'DESC',
	@Page INT = 1,
	@PageSize INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @firstRec INT;
	DECLARE @lastRec INT;

	BEGIN TRY
		SET @firstRec = (@Page-1)* @pagesize
		SET @lastRec = (@Page*@pageSize+1);

		if (@idfObjetType in (10017073, 10017006, 10017005, 10017062, 10017069,  10017077  ,10017074,10017075, 10017078 ,10017080 ,10017081 ,10017004, 10017088, 10017085, 10017059, 10017061,10017063) and @idfObjectId  is NOT NULL AND @idfObjectId ! = '')  
		BEGIN
			WITH CTEResults AS
			(
				SELECT ROW_NUMBER() OVER ( ORDER BY
				CASE WHEN @sortColumn = 'TransactionDate' AND @SortOrder = 'ASC' THEN ae.datEnteringDate END ASC,
				CASE WHEN @sortColumn = 'TransactionDate' AND @SortOrder = 'DESC' THEN ae.datEnteringDate END DESC,
				CASE WHEN @sortColumn = 'siteName' AND @SortOrder = 'ASC' THEN ae.idfsSite   END ASC,
				CASE WHEN @sortColumn = 'siteName' AND @SortOrder = 'DESC' THEN ae.idfsSite END DESC,
				CASE WHEN @sortColumn = 'UserName' AND @SortOrder = 'ASC' THEN ae.idfUserID   END ASC,
				CASE WHEN @sortColumn = 'UserName' AND @SortOrder = 'DESC' THEN ae.idfUserID END DESC,
				CASE WHEN @sortColumn = 'ActionName' AND @SortOrder = 'ASC' THEN ae.idfsDataAuditEventType   END ASC,
				CASE WHEN @sortColumn = 'ActionName' AND @SortOrder = 'DESC' THEN ae.idfsDataAuditEventType END DESC,
				CASE WHEN @sortColumn = 'ObjectType' AND @SortOrder = 'ASC' THEN ae.idfsDataAuditObjectType  END ASC,
				CASE WHEN @sortColumn = 'ObjectType' AND @SortOrder = 'DESC' THEN ae.idfsDataAuditObjectType END DESC,
				CASE WHEN @sortColumn = 'StrObject' AND @SortOrder = 'ASC' THEN ae.strMainObject  END ASC,
				CASE WHEN @sortColumn = 'StrObject' AND @SortOrder = 'DESC' THEN ae.strMainObject END DESC
				)  AS ROWNUM,
						ae.strSiteName siteName,
						ae.idfsSite siteId,
						ae.idfUserID userId,
						ae.strFirstName userFirstName,
						ae.strFamilyName userFamilyName,
						ae.datEnteringDate TransactionDate,
						ae.ActionName,
						ae.idfsDataAuditEventType actionTypeId,
						ae.ObjectType,
						ae.idfsDataAuditObjectType ObjectTypeId,
						ae.idfMainObjectTable ObjectTable,
						ae.idfMainObject ObjectId,
						ae.idfDataAuditEvent auditEventId,
						tt.strName tableName,
						ae.strMainObject,
						COUNT(*) OVER () AS TotalRowCount
					from dbo.fn_DataAudit_SelectList(@languageId) ae
					INNER join tauTable tt 
					on tt.idfTable = ae.idfMainObjectTable
					LEFT JOIN	tlbHumanCase
					ON			tlbHumanCase.idfHumanCase = ae.idfMainObject
					LEFT JOIN	tlbVetCase
					ON			tlbVetCase.idfVetCase = ae.idfMainObject
					LEFT JOIN	tlbOutbreak
					ON			tlbOutbreak.idfOutbreak = ae.idfMainObject
					LEFT JOIN	tlbCampaign
					ON			tlbCampaign.idfCampaign = ae.idfMainObject
					LEFT JOIN	tlbMonitoringSession
					ON			tlbMonitoringSession.idfMonitoringSession = ae.idfMainObject
					LEFT JOIN	tlbAggrCase
					ON			tlbAggrCase.idfAggrCase = ae.idfMainObject
					LEFT JOIN	tlbVectorSurveillanceSession
					ON			tlbVectorSurveillanceSession.idfVectorSurveillanceSession =ae.idfMainObject
					LEFT JOIN	tlbBasicSyndromicSurveillance
					ON			tlbBasicSyndromicSurveillance.idfBasicSyndromicSurveillance = ae.idfMainObject
					LEFT JOIN	tlbBasicSyndromicSurveillanceAggregateHeader
					ON			tlbBasicSyndromicSurveillanceAggregateHeader.idfAggregateHeader = ae.idfMainObject
					LEFT JOIN	tlbReportForm
					ON			tlbReportForm.idfReportForm = ae.idfMainObject
					where 0=0 and
						(ae.idfsSite = @idfSiteId OR @idfSiteId IS NULL) 
						AND (ae.idfUserID = @idfUserId OR @idfUserId IS NULL) 
						AND (ae.idfsDataAuditEventType = @idfActionId OR @idfActionId IS NULL) 
						AND (ae.idfsDataAuditObjectType = @idfObjetType OR @idfObjetType IS NULL) 
						AND
						((@startdate is null and @enddate is null)
							or
							(@startdate is null and @enddate is not null and cast(ae.datEnteringDate as date) <= cast(@enddate as date) )
							or
							(@startdate is not null and @enddate is null and cast(ae.datEnteringDate as date) >= cast(@startdate as date) )
							or
							(@startdate is not null and @enddate is not null and cast(ae.datEnteringDate as date) BETWEEN  cast(@startdate as date)  AND  cast(@enddate as date)))
						AND (CASE tt.strName	
										WHEN 'tlbVetCase' THEN tlbVetCase.strCaseID	-- Vet Disease Report
										WHEN 'tlbHumanCase'	THEN tlbHumanCase.strCaseID	 -- Humand Disease Report
										WHEN 'tlbOutbreak'	THEN tlbOutbreak.strOutbreakID	 -- OutBreak Session
										WHEN 'tlbCampaign'	THEN tlbCampaign.strCampaignID  -- Vet and Human Campaign
										WHEN 'tlbMonitoringSession'	THEN tlbMonitoringSession.strMonitoringSessionID  -- Vet and Human ASS
										WHEN 'tlbVectorSurveillanceSession'	THEN tlbVectorSurveillanceSession.strSessionID  -- Vector Surveillance Session
										WHEN 'tlbAggrCase'	THEN tlbAggrCase.strCaseID   -- Human and Vet Aggregate Case
										WHEN 'tlbBasicSyndromicSurveillance'	THEN tlbBasicSyndromicSurveillance.strFormID  -- 
										WHEN 'tlbBasicSyndromicSurveillanceAggregateHeader'	THEN tlbBasicSyndromicSurveillanceAggregateHeader.strFormID --ILI
										WHEN 'tlbReportForm'	THEN tlbReportForm.strReportFormID  -- Weekly Reporting Form

							END Like '%'+trim(@idfObjectId)+'%')

			)
			SELECT 	auditEventId, 
					siteName,	
					siteId,
					userId,
					userFirstName,
					userFamilyName,
					TransactionDate,
					ActionName,
					actionTypeId,
					ObjectType,
					ObjectTypeId,
					ObjectTable,
					ObjectId,
					tableName,
					strMainObject,
					TotalRowCount,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @Page
			FROM CTEResults WHERE RowNum > @firstRec AND RowNum < @lastRec
		END
		ELSE
		BEGIN
		WITH CTEResults AS
			(
				SELECT ROW_NUMBER() OVER ( ORDER BY
				CASE WHEN @sortColumn = 'TransactionDate' AND @SortOrder = 'ASC' THEN ae.datEnteringDate END ASC,
				CASE WHEN @sortColumn = 'TransactionDate' AND @SortOrder = 'DESC' THEN ae.datEnteringDate END DESC,
				CASE WHEN @sortColumn = 'siteName' AND @SortOrder = 'ASC' THEN ae.idfsSite   END ASC,
				CASE WHEN @sortColumn = 'siteName' AND @SortOrder = 'DESC' THEN ae.idfsSite END DESC,
				CASE WHEN @sortColumn = 'UserName' AND @SortOrder = 'ASC' THEN ae.idfUserID   END ASC,
				CASE WHEN @sortColumn = 'UserName' AND @SortOrder = 'DESC' THEN ae.idfUserID END DESC,
				CASE WHEN @sortColumn = 'ActionName' AND @SortOrder = 'ASC' THEN ae.idfsDataAuditEventType   END ASC,
				CASE WHEN @sortColumn = 'ActionName' AND @SortOrder = 'DESC' THEN ae.idfsDataAuditEventType END DESC,
				CASE WHEN @sortColumn = 'ObjectType' AND @SortOrder = 'ASC' THEN ae.idfsDataAuditObjectType  END ASC,
				CASE WHEN @sortColumn = 'ObjectType' AND @SortOrder = 'DESC' THEN ae.idfsDataAuditObjectType END DESC,
				CASE WHEN @sortColumn = 'StrObject' AND @SortOrder = 'ASC' THEN ae.strMainObject  END ASC,
				CASE WHEN @sortColumn = 'StrObject' AND @SortOrder = 'DESC' THEN ae.strMainObject END DESC
				)  AS ROWNUM,
						ae.strSiteName siteName,
						ae.idfsSite siteId,
						ae.idfUserID userId,
						ae.strFirstName userFirstName,
						ae.strFamilyName userFamilyName,
						ae.datEnteringDate TransactionDate,
						ae.ActionName,
						ae.idfsDataAuditEventType actionTypeId,
						ae.ObjectType,
						ae.idfsDataAuditObjectType ObjectTypeId,
						ae.idfMainObjectTable ObjectTable,
						ae.idfMainObject ObjectId,
						ae.idfDataAuditEvent auditEventId,
						tt.strName tableName,
						ae.strMainObject,
						COUNT(*) OVER () AS TotalRowCount
					from dbo.fn_DataAudit_SelectList(@languageId) ae
					INNER join tauTable tt 
					on tt.idfTable = ae.idfMainObjectTable
					where 0=0 and
						(ae.idfsSite = @idfSiteId OR @idfSiteId IS NULL) 
						AND (ae.idfUserID = @idfUserId OR @idfUserId IS NULL) 
						AND (ae.idfsDataAuditEventType = @idfActionId OR @idfActionId IS NULL) 
						AND (ae.idfsDataAuditObjectType = @idfObjetType OR @idfObjetType IS NULL) 
					--	AND (ae.idfMainObject = @idfObjectId OR @idfObjectId IS NULL)
						AND
						((@startdate is null and @enddate is null)
							or
							(@startdate is null and @enddate is not null and cast(ae.datEnteringDate as date) <= cast(@enddate as date) )
							or
							(@startdate is not null and @enddate is null and cast(ae.datEnteringDate as date) >= cast(@startdate as date) )
							or
							(@startdate is not null and @enddate is not null and cast(ae.datEnteringDate as date) BETWEEN  cast(@startdate as date)  AND  cast(@enddate as date)))
							)
			SELECT 	auditEventId, 
					siteName,	
					siteId,
					userId,
					userFirstName,
					userFamilyName,
					TransactionDate,
					ActionName,
					actionTypeId,
					ObjectType,
					ObjectTypeId,
					ObjectTable,
					ObjectId,
					tableName,
					strMainObject,
					TotalRowCount,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @Page
			FROM CTEResults WHERE RowNum > @firstRec AND RowNum < @lastRec
						
		END
		



END TRY

	BEGIN CATCH
		
		THROW;
	END CATCH;

	
END

