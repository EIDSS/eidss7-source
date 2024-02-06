
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTypes_FILTER
-- Description: EIDSS7 SCUC20_Usecase Filters the columns DefaultName and NationalName that contains the searchString. 
--         
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Mike Kornegay	5/23/2021	Added paging and removed incorrect commit trans.
-- Mike Kornegay	6/10/2021	Added sort by system type.
-- Mike Kornegay	7/29/2021	Corrected problem with inactive records showing
-- Mike Kornegay	8/5/2021	Added ReferenceTypeName to stored proc and out of code
--								and added default sort by ReferenceTypeName and NationalValue
-- Mike Kornegay	8/10/2021	Changed ReferenceTypeName to ParameterTypeName and 
--								added BaseReferenceListName to be the Base Reference Name the reference
--								type is linked to.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTypes_FILTER]
(
	@LangID NVARCHAR(50) = NULL
	,@searchString VARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = '' 
	,@sortOrder NVARCHAR(4) = ''
)	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX)       
	
	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @fixedValueTypeString NVARCHAR(200)
		DECLARE @referenceTypeString NVARCHAR(200)

		DECLARE @t TABLE(
			idfsParameterType bigint,
			defaultName nvarchar(2000),
			nationalName nvarchar(2000),
			idfsReferenceType bigint,
			BaseReferenceListName nvarchar(2000),
			[System] nvarchar(1),
			[ParameterTypeName] nvarchar(200),
			LangId nvarchar(10)
		)

		SET @firstRec = (@pageNo-1) * @pageSize
		SET @lastRec = (@pageNo*@pageSize+1)

		--get the fixed value type translated string
		SET @fixedValueTypeString = (SELECT ISNULL(t.strResourceString, r.strResourceName) FROM [dbo].[trtResource] r
												left join [dbo].[trtResourceTranslation] t 
												on t.idfsResource = r.idfsResource
												and t.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)
												where r.idfsResource = 546)
		--get the reference type translated string
		SET @referenceTypeString = (SELECT ISNULL(t.strResourceString, r.strResourceName) FROM [dbo].[trtResource] r
												left join [dbo].[trtResourceTranslation] t 
												on t.idfsResource = r.idfsResource
												and t.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@langId)
												where r.idfsResource = 547)

		IF (@searchString IS NOT NULL)
			SET @searchString = '%' + @searchString + '%'

		INSERT INTO @t
		SELECT 
			idfsParameterType	
			,RT.strDefault AS [DefaultName]
			,ISNULL(RT.name, RT.strDefault) AS [NationalName]
			,PT.idfsReferenceType
			,ISNULL(CR.strTextString, BR.strDefault) AS [BaseReferenceListName]
			,CASE ISNULL(PT.idfsReferenceType, -1) WHEN -1 
												   THEN '2'
												   WHEN 19000069
												   THEN '0'
												   ELSE '1'
			 END AS [System]
			,CASE ISNULL(PT.idfsReferenceType, -1)	WHEN -1 
													THEN @fixedValueTypeString
													WHEN 19000069
													THEN @fixedValueTypeString
													ELSE @referenceTypeString
			 END AS [ParameterTypeName]
			,@LangID AS [LangID]
		FROM dbo.ffParameterType AS PT
		LEFT JOIN dbo.trtBaseReference AS BR WITH(INDEX=IX_trtBaseReference_RR)
			ON BR.idfsBaseReference = PT.idfsReferenceType
		LEFT JOIN dbo.trtStringNameTranslation AS CR WITH(INDEX=IX_trtStringNameTranslation_BL) 
			ON BR.idfsBaseReference = CR.idfsBaseReference 
			AND CR.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID)
		LEFT JOIN FN_GBL_Reference_List_GET(@LangID, 19000071 /*'rftParameterType'*/) AS RT
			ON RT.idfsReference = PT.idfsParameterType
		WHERE (RT.strDefault LIKE ISNULL(@searchString, RT.strDefault)
			  OR ISNULL(RT.name, RT.strDefault) LIKE ISNULL(@searchString, ISNULL(RT.name, RT.strDefault)))
			  AND PT.intRowStatus = 0;
		WITH CTEResults AS
		(
				SELECT ROW_NUMBER() OVER (
				
					ORDER BY
						CASE WHEN @sortOrder = 'asc' THEN 
							CASE 
								WHEN @sortColumn = 'DefaultName' THEN [DefaultName]
								WHEN @sortColumn = 'NationalName' THEN [NationalName]
								WHEN @sortColumn = 'ParameterTypeName' THEN [ParameterTypeName]
							END
						END ASC,
						CASE WHEN @sortOrder = 'desc' THEN 
							CASE 
								WHEN @sortColumn = 'DefaultName' THEN [DefaultName]
								WHEN @sortColumn = 'NationalName' THEN [NationalName]
								WHEN @sortColumn = 'ParameterTypeName' THEN [ParameterTypeName]
							END
						END DESC,
						--default sort
						[ParameterTypeName] DESC, [NationalName] ASC
							
	
		) AS ROWNUM,
		COUNT(*) OVER () AS 
			TotalRowCount,
			idfsParameterType,
			DefaultName,
			NationalName,
			idfsReferenceType,
			[BaseReferenceListName],
			[System],
			[ParameterTypeName],
			LangID
		FROM @t
	)
		SELECT 
			TotalRowCount,
			idfsParameterType,
			DefaultName,
			NationalName,
			idfsReferenceType,
			[BaseReferenceListName],
			[System],
			[ParameterTypeName],
			LangID,
			TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
			CurrentPage = @pageNo
		FROM CTEResults
		WHERE ROWNUM > @firstRec AND ROWNUM < @lastRec
			
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH
END
