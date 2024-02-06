-- =========================================================================================
-- NAME: USP_CONF_DISEASEHUMANGENDERMATRIX_GETLIST
-- DESCRIPTION: Returns a list of disease group Tto human gender relationships

-- AUTHOR: Ricky Moss

-- Revision History:
-- Name             Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		06/24/2019	Initial Release
-- Ricky Moss		06/30/2019	
-- Steven Verner	05/16/2021	Paging Enabled

-- exec USP_CONF_DISEASEHUMANGENDERMATRIX_GETLIST 'en'
-- exec USP_CONF_DISEASEHUMANGENDERMATRIX_GETLIST 'en'
-- =========================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_DISEASEHUMANGENDERMATRIX_GETLIST]
(
	 @LangId NVARCHAR(10)
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strDiseaseGroupName' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			DisgnosisGroupToGenderUID bigint,
			DisgnosisGroupID bigint,
			strDiseaseGroupName nvarchar(2000),
			GenderID nvarchar(4000),
			strGender nvarchar(2000)
		)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
		SELECT 
			 dgg.DisgnosisGroupToGenderUID
			,dgg.DisgnosisGroupID
			,dg.name as strDiseaseGroupName
			,CAST(g.idfsReference AS NVARCHAR(4000))  as GenderID
			,g.name as strGender  
		FROM DiagnosisGroupToGender dgg
		JOIN dbo.FN_GBL_Reference_GETList(@LangId, 19000043) g on dgg.GenderID = g.idfsReference
		JOIN dbo.FN_GBL_Reference_GETList(@LangId, 19000019) dg on dgg.DisgnosisGroupID = dg.idfsReference
		WHERE dgg.intRowStatus = 0
		;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'DisgnosisGroupToGenderUID' AND @SortOrder = 'asc' THEN DisgnosisGroupToGenderUID END ASC,
				CASE WHEN @sortColumn = 'DisgnosisGroupToGenderUID' AND @SortOrder = 'desc' THEN DisgnosisGroupToGenderUID END DESC,
				CASE WHEN @sortColumn = 'DisgnosisGroupID' AND @SortOrder = 'asc' THEN DisgnosisGroupID END ASC,
				CASE WHEN @sortColumn = 'DisgnosisGroupID' AND @SortOrder = 'desc' THEN DisgnosisGroupID END DESC,
				CASE WHEN @sortColumn = 'strDiseaseGroupName' AND @SortOrder = 'asc' THEN strDiseaseGroupName END ASC,
				CASE WHEN @sortColumn = 'strDiseaseGroupName' AND @SortOrder = 'desc' THEN strDiseaseGroupName END DESC,
				CASE WHEN @sortColumn = 'GenderID' AND @SortOrder = 'asc' THEN GenderID END ASC,
				CASE WHEN @sortColumn = 'GenderID' AND @SortOrder = 'desc' THEN GenderID END DESC,
				CASE WHEN @sortColumn = 'strGender' AND @SortOrder = 'asc' THEN strGender END ASC,
				CASE WHEN @sortColumn = 'strGender' AND @SortOrder = 'desc' THEN strGender END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				DisgnosisGroupToGenderUID,
				DisgnosisGroupID,
				strDiseaseGroupName,
				GenderID,
				strGender
			FROM @T
		)

			SELECT
				TotalRowCount, 
				DisgnosisGroupToGenderUID,
				DisgnosisGroupID,
				strDiseaseGroupName,
				GenderID,
				strGender,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
