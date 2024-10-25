

--==============================================================================================================
-- NAME:					[USP_ADMIN_SYSTEMFUNCTION_GETLIST]
-- DESCRIPTION:				Returns a list of SystemFunction
-- AUTHOR:					Manickandan Govindarajan
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Manickandan Govindarajan			06/3/2021	Initial Release
-- Mark Wilson						04/28/2022	changed default order by to intOrder
/*

EXEC USP_ADMIN_SYSTEMFUNCTION_GETLIST 'en-US'

*/
-- ===============================================================================================================
CREATE   PROCEDURE [dbo].[USP_ADMIN_SYSTEMFUNCTION_GETLIST]
	@LanguageId NVARCHAR(50)
	,@SystemFunctionName NVARCHAR(255) =NULL
	,@PageNo INT = 1
	,@PageSize INT = 200
	,@SortColumn NVARCHAR(30) = 'intOrder'
	,@SortOrder NVARCHAR(4) = 'asc'
		
AS
BEGIN
	
	BEGIN TRY

		SET NOCOUNT ON;

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsBaseReference BIGINT, 
			idfsReferenceType BIGINT, 
			SystemFunction NVARCHAR(2000),
			intOrder INT
			)

		SET @firstRec = (@PageNo-1)* @Pagesize
		SET @lastRec = (@PageNo*@PageSize+1)
		INSERT INTO @T
			SELECT 
					br.idfsBaseReference,
					br.idfsReferenceType,
					ISNULL(s.strTextString, br.strDefault) AS SystemFunction,
					br.intOrder
			FROM dbo.trtBaseReference br
			JOIN dbo.trtReferenceType rt ON br.idfsReferenceType = rt.idfsReferenceType
			LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference 
				AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageId)
			WHERE rt.idfsReferenceType =19000094 
				AND rt.intRowStatus = 0 AND br.intRowStatus=0
				AND (
					(
						br.strDefault LIKE '%' + @SystemFunctionName + '%'
						OR s.strTextString LIKE '%' + @SystemFunctionName + '%'
					)
				OR @SystemFunctionName IS NULL
				)
				ORDER BY br.intOrder;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
					CASE WHEN @sortColumn = 'SystemFunction' AND @SortOrder = 'asc' THEN dbo.FN_GBL_RemoveSpecialChars(SystemFunction) END ASC,
					CASE WHEN @sortColumn = 'SystemFunction' AND @SortOrder = 'desc' THEN dbo.FN_GBL_RemoveSpecialChars(SystemFunction) END DESC,
					CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'asc' THEN intOrder END ASC,
					CASE WHEN @sortColumn = 'intOrder' AND @SortOrder = 'desc' THEN intOrder END DESC,
					dbo.FN_GBL_RemoveSpecialChars(SystemFunction) ASC

				) AS ROWNUM,		
			COUNT(*) OVER () AS 
					TotalRowCount,
					idfsBaseReference,
					idfsReferenceType, 
					SystemFunction
				FROM @T
	)
		SELECT
				TotalRowCount,
				idfsBaseReference, 
				idfsReferenceType, 
				SystemFunction, 		 
				TotalPages = (TotalRowCount/@PageSize)+IIF(TotalRowCount%@PageSize>0,1,0),
				CurrentPage = @PageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	

		

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
