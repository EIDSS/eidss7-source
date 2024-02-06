

--*************************************************************************************************
-- Name: [USP_GBL_LKUP_DISEASE_GETList_Paged]
--
-- Description: List of filtered and Paged diseases
--          
-- Revision History:
-- Name				Date       Change Detail
-- ---------------	---------- --------------------------------------------------------------------
--Lamont Mitchell	10-10-2021	initial
-- @intHACode Code List
-- 0	None
-- 2	Human
-- 4	Exophyte
-- 8	Plant
-- 16	Soil
-- 32	Livestock
-- 64	Avian
-- 128	Vector
-- 256	Syndromic
-- 510	All	
--
-- Testing code:
/*
	exec [dbo].[USP_GBL_LKUP_DISEASE_GETList_Paged] 

	 @LanguageID	 ='en-US'
	,@ReferenceTypeName =19000019
	,@intHACode	=2
	,@advancedSearch = 'SA'
	,@pageNo  = 1
	,@pageSize  = 10 
	,@sortColumn  = 'strName'
	,@sortOrder  = 'asc'

*/
-- ************************************************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_LKUP_DISEASE_GETList_Paged] 
(
	@LanguageID	NVARCHAR(50),
	@intHACode	BIGINT = NULL,
	@advancedSearch NVARCHAR(100) = NULL,
	@pageNo INT = 1,
	@pageSize INT = 10 ,
	@sortColumn NVARCHAR(30) = 'strName',
	@sortOrder NVARCHAR(4) = 'asc'
)
AS
	DECLARE @HACodeMax BIGINT = 510;
	DECLARE @ReturnMsg VARCHAR(MAX) = 'Success';
	DECLARE @ReturnCode BIGINT = 0;
	DECLARE @HAList TABLE(
		intHACode INT
	)

	IF @intHACode IS NOT NULL
		BEGIN
			INSERT INTO @HAList	(intHACode)
			SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax)
		END

	DECLARE @firstRec INT
	DECLARE @lastRec INT

	DECLARE @t TABLE( 
		idfsBaseReference		BIGINT, 
		--idfsReferenceType		BIGINT, 
		--strBaseReferenceCode	NVARCHAR(200),
		--strDefault				NVARCHAR(2000), 
		strName					NVARCHAR(2000)--,
		--intHACode				INT,
		--strHACode				NVARCHAR(4000),
		--strHACodeNames			NVARCHAR(4000),
		--intOrder				INT
	)

	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)

	BEGIN TRY
		IF( @advancedSearch IS NOT NULL )
			BEGIN
				INSERT INTO @T
				SELECT * FROM
				(
					SELECT 
						br.idfsBaseReference,
						--br.idfsReferenceType,
						--br.strBaseReferenceCode,
						--br.strDefault,
						ISNULL(s.strTextString, br.strDefault) AS strName--,
						--br.intHACode,
						--br.intOrder
						--br.intRowStatus,
						--br.blnSystem,
						--rt.intDefaultHACode,
						--CASE WHEN ISNULL(@intHACode,0) = 0 THEN NULL ELSE dbo.FN_GBL_SPLITHACODEASSTRING(br.intHACode, 510) END AS strHACode 

				FROM dbo.trtDiagnosis d
				INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease ON disease.idfsReference = d.idfsDiagnosis
				JOIN dbo.trtBaseReference br on br.idfsBaseReference = disease.idfsReference
				LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageID)
					WHERE ((EXISTS 
							(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
							INTERSECT 
							SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
							OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
					AND	br.intRowStatus = 0	
				
				) AS S
				WHERE 
					(
					  strName LIKE '%' + @advancedSearch + '%'
					)
			END
		ELSE
			BEGIN
				INSERT INTO @T
				SELECT 
					br.idfsBaseReference,
					ISNULL(s.strTextString, br.strDefault) AS strName
				
				FROM dbo.trtDiagnosis d
				INNER JOIN dbo.FN_GBL_Repair(@LanguageID, 19000019) disease ON disease.idfsReference = d.idfsDiagnosis
				JOIN dbo.trtBaseReference br on br.idfsBaseReference = disease.idfsReference
				LEFT JOIN dbo.trtStringNameTranslation AS s ON br.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageID)
		
				WHERE ((EXISTS 
						(SELECT intHACode FROM dbo.FN_GBL_SplitHACode(@intHACode, @HACodeMax) 
						INTERSECT 
						SELECT intHACode FROM dbo.FN_GBL_SplitHACode(br.intHACode, @HACodeMax)) 
						OR @intHACode IS NULL OR @intHACode = 0 OR br.intHACode = @intHACode))
				AND	br.intRowStatus = 0	
			END;

		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				IIF( @sortColumn = 'intOrder',strName,NULL) ASC
		) AS ROWNUM,		
		COUNT(*) OVER () AS 
				TotalRowCount,
				idfsBaseReference, 
				strName
				--intOrder
			FROM @T
		)

		SELECT
			TotalRowCount,
			idfsBaseReference, 
			strName,
			--intOrder,
			TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
			CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 	

	END TRY  

	BEGIN CATCH 

		THROW;

	END CATCH;
