-- =============================================
-- Author:		Manickandan Govindarajan
-- Create date: 06/28/2022
-- Description:	Get List of Sites  
-- =============================================
CREATE PROCEDURE [dbo].[USP_GBL_Site_GETList]
	@languageId AS NVARCHAR(50),
	@UserId BIGINT=NULL,
	@ApplySiteFiltrationIndicator bit =0,
	@SortColumn NVARCHAR(30) = 'Name',
	@SortOrder NVARCHAR(4) = 'ASC',
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


		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY
			CASE WHEN @sortColumn = 'Name' AND @SortOrder = 'ASC' THEN s.strSiteName END ASC,
			CASE WHEN @sortColumn = 'Name' AND @SortOrder = 'DESC' THEN s.strSiteName END DESC
			)  AS ROWNUM,
					s.strSiteName siteName,
					s.strSiteID,
					s.idfsSite,
					COUNT(*) OVER () AS TotalRowCount
				from tstSite s
				where  s.intRowStatus=0
		)
		SELECT 	siteName, 
				strSiteID,	
		        idfsSite,
				TotalRowCount,
			TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
			CurrentPage = @Page
		FROM CTEResults WHERE RowNum > @firstRec AND RowNum < @lastRec



END TRY

	BEGIN CATCH
		
		THROW;
	END CATCH;

	
END

