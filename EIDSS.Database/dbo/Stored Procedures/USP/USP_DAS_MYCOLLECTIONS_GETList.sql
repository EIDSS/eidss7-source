/****** Object:  StoredProcedure [dbo].[USP_DAS_MYCOLLECTIONS_GETList]    Script Date: 5/6/2019 6:44:21 PM ******/

-- ================================================================================================
-- Name: USP_DAS_MYCOLLECTIONS_GETList
--
-- Description: Returns a list of vectors surveillance sessions collected by a user.
--          
-- Author: Ricky Moss
--
-- Revision History:
-- Name			    Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss       11/28/2018 Initial Release
-- Ricky Moss       05/06/2019 Added Pagination
-- Stephen Long     01/24/2020 Cleaned up stored procedure.
-- Leo Tracchia		02/18/2022 Added pagination logic for radzen components
-- Testing code:
-- EXEC USP_DAS_MYCOLLECTIONS_GETList 'en', 55429560000000, 1, 10, 10
-- EXEC USP_DAS_MYCOLLECTIONS_GETList 'en', 55423020000000, 1, 10, 10
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_MYCOLLECTIONS_GETList] (
	@LanguageID NVARCHAR(50),
	@PersonID BIGINT,
	--@PaginationSet INT = 1,
	--@PageSize INT = 10,
	--@MaxPagesPerFetch INT = 10,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'DateEntered',
	@sortOrder NVARCHAR(4) = 'desc'  
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	DECLARE @firstRec INT
    DECLARE @lastRec INT

	DECLARE @tempVector TABLE( 
		VectorSurveillanceSessionID bigint,
		SessionID  nvarchar(2000),
		DateEntered datetime,
		Vectors nvarchar(2000),
		DiseaseName nvarchar(2000), 
		DateStarted datetime,
		Region nvarchar(2000),
		Rayon nvarchar(2000)		
	)

     SET @firstRec = (@pageNo-1)* @pagesize
     SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY

		INSERT INTO @tempVector

		SELECT DISTINCT vss.idfVectorSurveillanceSession as 'VectorSurveillanceSessionID',
			strSessionID as 'SessionID',
			datCollectionDateTime AS 'DateEntered',
			strVectors as 'Vectors',
			strDiagnoses as 'DiseaseName',
			datStartDate as 'DateStarted',
			strRegion as 'Region',
			strRayon as 'Rayon'
		FROM dbo.FN_VCTS_VSSESSION_GetList(@LanguageID) vss
		JOIN dbo.tlbVector v
			ON vss.idfVectorSurveillanceSession = v.idfVectorSurveillanceSession
		WHERE vss.idfsVectorSurveillanceStatus = 10310001 --In Process
			AND v.idfCollectedByPerson = @PersonID;
		--ORDER BY strSessionID OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS

		--FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;

		--SELECT @ReturnCode,
		--	@ReturnMessage;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'VectorSurveillanceSessionID' AND @SortOrder = 'asc' THEN VectorSurveillanceSessionID END ASC,
				CASE WHEN @sortColumn = 'VectorSurveillanceSessionID' AND @SortOrder = 'desc' THEN VectorSurveillanceSessionID END DESC,

				CASE WHEN @sortColumn = 'SessionID' AND @SortOrder = 'asc' THEN SessionID END ASC,
				CASE WHEN @sortColumn = 'SessionID' AND @SortOrder = 'desc' THEN SessionID END DESC,

				CASE WHEN @sortColumn = 'DateEntered' AND @SortOrder = 'asc' THEN DateEntered END ASC,
				CASE WHEN @sortColumn = 'DateEntered' AND @SortOrder = 'desc' THEN DateEntered END DESC,

				CASE WHEN @sortColumn = 'Vectors' AND @SortOrder = 'asc' THEN Vectors END ASC,
				CASE WHEN @sortColumn = 'Vectors' AND @SortOrder = 'desc' THEN Vectors END DESC,

				CASE WHEN @sortColumn = 'DiseaseName' AND @SortOrder = 'asc' THEN DiseaseName END ASC,
				CASE WHEN @sortColumn = 'DiseaseName' AND @SortOrder = 'desc' THEN DiseaseName END DESC,

				CASE WHEN @sortColumn = 'DateStarted' AND @SortOrder = 'asc' THEN DateStarted END ASC,
				CASE WHEN @sortColumn = 'DateStarted' AND @SortOrder = 'desc' THEN DateStarted END DESC,

				CASE WHEN @sortColumn = 'Region' AND @SortOrder = 'asc' THEN Region END ASC,
				CASE WHEN @sortColumn = 'Region' AND @SortOrder = 'asc' THEN Region END ASC,

				CASE WHEN @sortColumn = 'Rayon' AND @SortOrder = 'desc' THEN Rayon END DESC,
				CASE WHEN @sortColumn = 'Rayon' AND @SortOrder = 'asc' THEN Rayon END ASC
			
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount,
				VectorSurveillanceSessionID,
				SessionID,
				DateEntered,
				Vectors,
				DiseaseName,
				DateStarted,
				Region,
				Rayon						
			FROM @tempVector
		)	
			SELECT
			TotalRowCount,
			VectorSurveillanceSessionID,
			SessionID,
			DateEntered,
			Vectors,
			DiseaseName,
			DateStarted,
			Region,
			Rayon					
			,TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0)
			,CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

		OPTION (RECOMPILE);
	END TRY

	BEGIN CATCH
		--SET @ReturnCode = ERROR_NUMBER();
		--SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,
		--	@ReturnMessage;

		THROW;
	END CATCH;
END
