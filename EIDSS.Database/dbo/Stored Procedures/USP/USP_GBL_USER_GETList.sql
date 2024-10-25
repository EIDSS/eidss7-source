-- =============================================
-- Author:		Manickandan Govindarajan
-- Create date: 06/27/2022
-- Description:	Get List of Users  
-- =============================================
CREATE PROCEDURE [dbo].[USP_GBL_USER_GETList]
	@languageId AS NVARCHAR(50),
	@siteId BIGINT=NULL,
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
			CASE WHEN @sortColumn = 'Name' AND @SortOrder = 'ASC' THEN p.strFirstName END ASC,
			CASE WHEN @sortColumn = 'Name' AND @SortOrder = 'DESC' THEN p.strFirstName END DESC
			)  AS ROWNUM,
					p.idfPerson,
					p.strFirstName,
					p.strFamilyName,
					p.strSecondName,
					u.idfUserID,
					p.idfInstitution,
					u.idfsSite,
					COUNT(*) OVER () AS TotalRowCount
				from tstUserTable u
				INNER JOIN tlbPerson p ON u.idfPerson  = p.idfPerson
				where 
					 u.intRowStatus =0 and p.intRowStatus=0
					 --and (u.idfsSite = @siteId OR @siteId = NULL)

		)
		SELECT 	idfPerson, 
				idfUserID,	
		        strFirstName,
			    strSecondName,
				strFamilyName,
				idfInstitution,
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

