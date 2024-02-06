--=================================================================================================
-- Name: USP_GBL_LKUP_REFERENCETYPE_FILTERED_PAGED_GETLIST
--
-- Description: Returns a list of base reference types WITH PAGING AND FILTERING
--
-- Author: Ricky Moss
--
-- Revision History:
-- Name				Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ricky Moss		06/20/2019	Initial Release
-- Stephen Long     12/26/2019	Replaced 'en' with @LangID on reference call.
-- Doug Albanese	9/4/2020	Added field to obtain language translation
-- Lamont Mitchell	7/16/2021	Added Paging and Filtering, copied from USP_GBL_LKUP_REFERENCETYPE_GETLIST
-- Michael Brown	03/16/2022	Bug #3127 Changed @sortColumn to 'name'. Added OR br.name... to WHERE clause
-- Steven Verner	10/21/2022	Removed duplicate base reference types where there currently is an editor for those types
--								Like Age Group, Case Classification,etc.
--								This change fixes bugs 3865,4757,4756,4755,4750...
-- Mike Kornegay	12/13/2022	Added reference type 19000538 (AS Species Type) to the list of excluded (system) types.
-- Mike Kornegay	12/23/2022	Removed reference type 19000538 (AS Species Type)
--
--=================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_REFERENCETYPE_FILTERED_PAGED_GETLIST] (
@LangId NVARCHAR(50),
@advancedSearch NVARCHAR(100) = NULL,
@pageNo INT = 1,
@pageSize INT = 10, 
@sortColumn NVARCHAR(30) = 'name', 
@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
	BEGIN TRY

		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE( 
			idfsBaseReference bigint,
			idfsReferenceType bigint, 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			intHACode int,
			intOrder int
			)
		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		IF( @advancedSearch IS NOT NULL)
		BEGIN
			INSERT INTO @T
			SELECT 
				br.idfsReference,
				trtReferenceType.idfsReferenceType,
				strDefault,
				br.name AS strName,
				intHACode,
				intOrder
			FROM dbo.FN_GBL_ReferenceRepairSplit(@LangId, '19000076,19000536') br
			INNER JOIN dbo.trtReferenceType
				ON trtReferenceType.idfsReferenceType = br.idfsReferenceType
			WHERE (intStandard & 4) <> 0
				AND br.idfsReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
											 19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
											 19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
											 19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,19000147,
											 19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
											 19000140)

				AND trtReferenceType.intRowStatus = 0
				and (br.strDefault like '%' + @advancedSearch +'%' OR br.name like '%' + @advancedSearch +'%')
			ORDER BY strReferenceTypeName;
		
			WITH CTEResults AS
			(
				SELECT ROW_NUMBER() OVER ( ORDER BY 
					CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
					CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
					CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
					CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
					CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'asc' THEN intHACode END ASC,
					CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'desc' THEN intHACode END DESC,
					CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
					CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC
			) AS ROWNUM,
			COUNT(*) OVER () AS 
					TotalRowCount,
					idfsBaseReference,
					idfsReferenceType,
					strDefault,
					strName,
					intHACode,
					intOrder
				FROM @T
			)
			SELECT
					TotalRowCount, 
					idfsBaseReference 'BaseReferenceId',
					idfsReferenceType 'ReferenceId',
					strDefault 'Default',
					strName 'Name',	
					intOrder,
					intHACode,
					TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
					CurrentPage = @pageNo 
			FROM CTEResults
			WHERE RowNum > @firstRec AND RowNum < @lastRec 
		END
		ELSE
		BEGIN
		INSERT INTO @T
		SELECT 
			br.idfsReference,
			trtReferenceType.idfsReferenceType,
			strDefault,
			br.name AS strName,
			intHACode,
			intOrder
		FROM dbo.FN_GBL_ReferenceRepair(@LangId, 19000076) br
		INNER JOIN dbo.trtReferenceType
			ON trtReferenceType.idfsReferenceType = br.idfsReferenceType
		WHERE (intStandard & 4) <> 0
			AND br.idfsReference NOT IN (19000146,19000011,19000019,19000537,19000529,19000530,19000531,19000532,19000533,19000534,19000535,19000125,19000123,19000122,
										 19000143,19000050,19000126,19000121,19000075,19000124,19000012,19000164,19000019,19000503,19000530,19000510,19000506,19000505,
										 19000509,19000511,19000508,19000507,19000022,19000131,19000070,19000066,19000071,19000069,19000029,19000032,19000101,19000525,
										 19000033,19000532,19000534,19000533,19000152,19000056,19000060,19000109,19000062,19000045,19000046,19000516,19000074,19000147,
										 19000130,19000535,19000531,19000087,19000079,19000529,19000119,19000524,19000084,19000519,19000166,19000086,19000090,19000141,
										 19000140)
			AND trtReferenceType.intRowStatus = 0
		ORDER BY strReferenceTypeName;




		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'asc' THEN strdefault END ASC,
				CASE WHEN @sortColumn = 'strdefault' AND @SortOrder = 'desc' THEN strdefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'asc' THEN intHACode END ASC,
				CASE WHEN @sortColumn = 'intHACode' AND @SortOrder = 'desc' THEN intHACode END DESC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'asc' THEN intOrder END ASC,
				CASE WHEN @sortColumn = 'intorder' AND @SortOrder = 'desc' THEN intOrder END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				idfsBaseReference,
				idfsReferenceType,
				strDefault,
				strName,
				intHACode,
				intOrder
			FROM @T
		)
		SELECT
				TotalRowCount,
				idfsBaseReference 'BaseReferenceId',
				idfsReferenceType 'ReferenceId',
				strDefault 'Default',
				strName 'Name',	
				intOrder,
				intHACode,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 

		END
	
	
	END TRY

	BEGIN CATCH
		THROW
	END CATCH;
END
