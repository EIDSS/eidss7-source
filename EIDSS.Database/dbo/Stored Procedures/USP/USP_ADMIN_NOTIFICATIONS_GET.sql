/*******************************************************
NAME						: [USP_ADMIN_NOTIFICATION_SET]		


Description					: Diplays Notifications

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					7-5-19							Initial Created
			Lamont Mitchell					06/08/2020						Added  FN_GBL_GIS_ReferenceRepair_GET to display Region and Rayon names TFS: 5671
			Mandar Kulkarni					02/14/2022						Added addional fields as per the requirement
*******************************************************/
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_NOTIFICATIONS_GET]
( 
	 @LanguageId NVARCHAR(50)
	,@SiteId BIGINT
    ,@UserId BIGINT
	,@SortColumn NVARCHAR(30) = 'AuditCreateDTM'
    ,@SortOrder NVARCHAR(4) = 'DESC'
    ,@Page INT = 1
    ,@PageSize INT = 10
   
 
)
AS

DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0 

DECLARE @firstRec INT, @lastRec INT,	
		@idfsLanguage BIGINT = (SELECT idfsBaseReference FROM dbo.trtBaseReference WHERE strBaseReferenceCode = @LanguageId)
	SET @firstRec = (@Page-1)* @PageSize
	SET @lastRec = (@Page*@PageSize+1);

Declare @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)
BEGIN
	BEGIN TRY  	

	WITH CTEResults AS
		(
		SELECT  ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'AuditCreateDTM' AND @SortOrder = 'asc' THEN ns.AuditCreateDTM END ASC,
			CASE WHEN @sortColumn = 'AuditCreateDTM' AND @SortOrder = 'desc' THEN ns.AuditCreateDTM END DESC,
			CASE WHEN @sortColumn = 'NotificationType' AND @SortOrder = 'asc' THEN n.idfsNotificationType  END DESC,
			CASE WHEN @sortColumn = 'NotificationType' AND @SortOrder = 'desc' THEN n.idfsNotificationType  END DESC,
			CASE WHEN @sortColumn = 'strSiteName' AND @SortOrder = 'asc' THEN n.idfsSite  END ASC,
			CASE WHEN @sortColumn = 'strSiteName' AND @SortOrder = 'desc' THEN n.idfsSite  END DESC,
			CASE WHEN @sortColumn = 'strRegion' AND @SortOrder = 'asc' THEN region.name  END ASC,
			CASE WHEN @sortColumn = 'strRegion' AND @SortOrder = 'desc' THEN region.name  END DESC,
			CASE WHEN @sortColumn = 'strRayon' AND @SortOrder = 'asc' THEN rayon.name  END ASC,
			CASE WHEN @sortColumn = 'strRayon' AND @SortOrder = 'desc' THEN rayon.name  END DESC
			--CASE WHEN @sortColumn = 'Disease' AND @SortOrder = 'asc' THEN disease  END ASC,
			--CASE WHEN @sortColumn = 'Disease' AND @SortOrder = 'desc' THEN disease  END DESC
			) AS ROWNUM,
			COUNT(*) OVER () AS TotalRowCount,
			n.strPayload,
			n.idfNotification,
			n.idfNotificationObject,
			n.idfsNotificationType,
			n.idfsNotificationObjectType,
			notificationType.name,
			CASE 
				WHEN n.idfsNotificationObjectType = 10060013 -- Vet Case
					THEN (
							SELECT diagnosis.name FROM dbo.tlbVetCase vc 
							INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageId, 19000019) diagnosis ON diagnosis.idfsReference= vc.idfsFinalDiagnosis
							WHERE vc.idfVetCase = n.idfNotificationObject
							AND vc.intRowStatus = 0
						)
				WHEN n.idfsNotificationObjectType = 10060006 -- Human Case
					THEN 
						(
							SELECT diagnosis.name FROM dbo.tlbHumanCase hc 
							INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageId, 19000019) diagnosis ON diagnosis.idfsReference= hc.idfsFinalDiagnosis
							WHERE hc.idfHumanCase = n.idfNotificationObject
							AND hc.intRowStatus = 0
						)
				WHEN n.idfsNotificationObjectType = 10060014 -- Outbreak
					THEN 
						(
							SELECT diagnosis.name FROM dbo.tlbOutbreak ob 
							INNER JOIN dbo.FN_GBL_Reference_GETList(@LanguageId, 19000019) diagnosis ON diagnosis.idfsReference= ob.idfsDiagnosisOrDiagnosisGroup
							WHERE ob.idfOutbreak= n.idfNotificationObject
							AND ob.intRowStatus = 0
						)
				WHEN n.idfsNotificationObjectType = 10060053 -- AS Campaign
					THEN 
						(
							SELECT
								DISTINCT
								STUFF((
										SELECT dbo.FN_GBL_ReferenceValue_GET(@idfsLanguage,tcd.idfsDiagnosis)+ ', 'FROM dbo.tlbCampaignToDiagnosis tcd
										WHERE tcd.idfCampaign = n.idfNotificationObject AND tcd.intRowStatus = 0
												FOR XML PATH('')), 1,0,SPACE(0)
									) AS disease
						)
				WHEN n.idfsNotificationObjectType = 10060054 -- AS Session
					THEN 
						(
							SELECT
								DISTINCT
								STUFF((
										SELECT dbo.FN_GBL_ReferenceValue_GET(@idfsLanguage,tmsd.idfsDiagnosis)+ ', '
										FROM dbo.tlbMonitoringSessionToDiagnosis tmsd
										WHERE tmsd.idfMonitoringSession = n.idfNotificationObject AND tmsd.intRowStatus = 0
												FOR XML PATH('')), 1,0,SPACE(0)
									) AS disease
						)
				ELSE ''
			END AS disease,
			ns.AuditCreateDTM ,
			n.idfsSite,
			n.idfsTargetSite,
			s.strSiteName,	
			GLS.idfsRegion,
			rayon.name as strRayon,
			GLS.idfsRayon,
			region.name as strRegion,
			ns.intProcessed 

		FROM dbo.tstNotification n
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageId,19000056) notificationType ON n.idfsNotificationType = notificationType.idfsReference
		LEFT JOIN dbo.tstNOTIFICATIONSTATUS ns ON n.IdfNotification = ns.idfNotification 
		LEFT JOIN dbo.tstSite S ON  N.idfsSite = s.idfsSite
		LEFT JOIN dbo.tlbOffice O ON S.idfOffice = O.idfOffice 
		LEFT JOIN dbo.tlbGeoLocationShared GLS ON GLS.idfGeoLocationShared = O.idfLocation
		LEFT JOIN  FN_GBL_GIS_Rayon_GET(@LanguageId,19000002) rayon  on rayon.idfsRayon = GLS.idfsRayon  --Rayon
		LEFT JOIN  FN_GBL_GIS_Region_GET(@LanguageId,19000003) region on region.idfsRegion = GLS.idfsRegion  --Region
		--WHERE ((@SiteId IS NOT NULL AND n.idfsTargetSite = @SiteId) OR (@SiteID IS NULL AND n.idfsTargetSite IS NULL))
		--AND  ((@UserId IS NOT NULL AND n.idfTargetUserID = @UserId) OR (@UserId IS NULL AND n.idfTargetUserID IS NULL))
		WHERE (
			(
				(
				(n.idfsTargetSite =@SiteId) OR (n.idfsTargetSite IS  NULL AND n.idfsSite = @SiteId))) 
				OR
				((n.idfTargetUserID =@UserId) OR (n.idfTargetUserID IS  NULL AND n.idfUserID = @UserId) )
			)
	
		AND	ns.intProcessed <> 2  
		)
		select 
		TotalRowCount,
		strPayload,
		idfNotification,
		idfsNotificationObjectType,
		name AS 'Notification Type',
		idfNotificationObject,
		disease,
		AuditCreateDTM,
		idfsSite,
		idfsTargetSite,
		strSiteName,
		idfsRegion,
		strRegion,
		strRayon,
		idfsRayon,
		intProcessed,
		TotalPages = (TotalRowCount/@PageSize)+IIF(TotalRowCount%@PageSize>0,1,0),
				CurrentPage = @Page 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec
	END TRY  

	BEGIN CATCH  

			Throw;
	END CATCH 
	
END





