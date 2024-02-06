
--=====================================================================================================
-- Name: USP_REF_REPORTDIAGNOSISGROUP_GETList
-- Description:	Returns a list of active Report Diagnosis Groups
--
-- Author:		Ricky Moss
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		10/03/2018 Initial Release
-- Ricky Moss		01/16/2019 Remove return code
-- Ricky Moss		04/13/2020 Added Search field
-- Test Code:
-- exec USP_REF_REPORTDIAGNOSISGROUP_GETList 'en'
-- 
--=====================================================================================================


CREATE PROCEDURE [dbo].[USP_REF_ReportDiagnosisGroup_GETList]
(
	 @langID  NVARCHAR(50) -- language ID 
  	,@strSearch NVARCHAR(100)
	,@advancedSearch NVARCHAR(100) = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strName' 
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN
BEGIN TRY

	DECLARE @firstRec INT
	DECLARE @lastRec INT
	DECLARE @t TABLE( 
		idfsReportDiagnosisGroup bigint, 
		idfsReferenceType bigint, 
		strDefault nvarchar(2000), 
		strName nvarchar(2000),
		strCode nvarchar(2000))
	
	SET @firstRec = (@pageNo-1)* @pagesize
	SET @lastRec = (@pageNo*@pageSize+1)

	IF(@advancedSearch IS NOT NULL)
		INSERT INTO @T
		SELECT
			rdg.[idfsReportDiagnosisGroup], 
			br.[idfsReferenceType],
			trim(br.[strDefault]),
			trim(br.[name]) as strName,
			rdg.[strCode]

		FROM dbo.[trtReportDiagnosisGroup] as rdg
		INNER JOIN fnReferenceRepair(@LangID, 19000130) br
		ON rdg.idfsReportDiagnosisGroup = br.idfsReference
		WHERE rdg.intRowStatus = 0 AND 
			(
			CAST(idfsReportDiagnosisGroup AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR 
			CAST(idfsReferenceType AS VARCHAR(20)) LIKE '%' + @advancedSearch + '%' OR 
			strDefault LIKE '%' + @advancedSearch + '%' OR 
			[name] LIKE '%' + @advancedSearch + '%' OR 
			strCode like '%' + @advancedSearch + '%')
		ORDER BY
			br.[name] asc;
	ELSE IF @strSearch IS NOT NULL
		INSERT INTO @T
		SELECT
			rdg.[idfsReportDiagnosisGroup], 
			br.[idfsReferenceType],
			trim(br.[strDefault]),
			trim(br.[name]) as strName,
			rdg.[strCode]
		FROM dbo.[trtReportDiagnosisGroup] as rdg
		INNER JOIN fnReferenceRepair(@LangID, 19000130) br
		ON rdg.idfsReportDiagnosisGroup = br.idfsReference
		WHERE rdg.intRowStatus = 0 AND (strDefault LIKE '%' + @strSearch + '%' OR [name] LIKE '%' + @strSearch + '%' OR strCode like '%' + @strSearch + '%')
		ORDER BY
			br.[name] asc;
	ELSE
		INSERT INTO @T
		SELECT
			rdg.[idfsReportDiagnosisGroup], 
			br.[idfsReferenceType],
			trim(br.[strDefault]),
			trim(br.[name]) as strName,
			rdg.[strCode]
		FROM dbo.[trtReportDiagnosisGroup] as rdg
		INNER JOIN fnReferenceRepair(@LangID, 19000130) br
		ON rdg.idfsReportDiagnosisGroup = br.idfsReference
		WHERE rdg.intRowStatus = 0
		ORDER BY
			br.[name] asc;
	WITH CTEResults AS
	(
		SELECT ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'idfsReportDiagnosisGroup' AND @SortOrder = 'asc' THEN idfsReportDiagnosisGroup END ASC,
			CASE WHEN @sortColumn = 'idfsReportDiagnosisGroup' AND @SortOrder = 'desc' THEN idfsReportDiagnosisGroup END DESC,
			CASE WHEN @sortColumn = 'idfsReferenceType' AND @SortOrder = 'asc' THEN idfsReferenceType END ASC,
			CASE WHEN @sortColumn = 'idfsReferenceType' AND @SortOrder = 'desc' THEN idfsReferenceType END DESC,
			CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
			CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
			CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
			CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
			CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'asc' THEN strCode END ASC,
			CASE WHEN @sortColumn = 'strCode' AND @SortOrder = 'desc' THEN strCode END DESC
	) AS ROWNUM,		
	COUNT(*) OVER () AS 
		TotalRowCount,
		idfsReportDiagnosisGroup,
		idfsReferenceType,
		strDefault,
		strName,
		strCode
		FROM @T
	)
		SELECT
		TotalRowCount,
		idfsReportDiagnosisGroup,
		idfsReferenceType,
		TRIM(strDefault) as 'strDefault',
		TRIM(strName) as 'strName',
		--strDefault,
		--strName,
		strCode,
		TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
		CurrentPage = @pageNo 
	FROM CTEResults
	WHERE RowNum > @firstRec AND RowNum < @lastRec 	

END TRY
BEGIN CATCH
	THROW;
END CATCH
END
