--=============================================================================================== 
-- Name:  USP_CONF_UNIQUENUMBERINGSCHEMA_GETLIST
-- Description: Returns a list of unique numbering schema given a language
-- Author: Ricky Moss
--
-- History of Change
-- Name:					Date:			Description: 
-- Ricky Moss				8/26/2019		Initial Release
-- Doug Albanese			10/22/2020		Added unverisal searching
-- exec USP_CONF_UNIQUENUMBERINGSCHEMA_GETLIST 'en'
--Lamont Mitchell 3/36/22  Added new column intPreviousNumberValue to store previous values in uniquenumberingschema
-- Mani Govindarajan  10/04/2022 Added a few extra output columns
--=============================================================================================== 
CREATE PROCEDURE [dbo].[USP_CONF_UNIQUENUMBERINGSCHEMA_GETLIST]
(
	 @LangId			NVARCHAR(50)
	,@QuickSearch	NVARCHAR(200) = ''
	,@pageNo INT = 1
	,@pageSize INT = 10 
	,@sortColumn NVARCHAR(30) = 'strDefault' --"IntNextNumberValue"
	,@sortOrder NVARCHAR(4) = 'asc'
)
AS
BEGIN

	IF @sortColumn = 'IntNextNumberValue'
		BEGIN
			SET @sortColumn = 'intNumberValue'
		END

	DECLARE @firstRec INT
	DECLARE @lastRec INT
	DECLARE @t TABLE( 
			idfsNumberName bigint, 
			--strObjectName nvarchar(2000), 
			strDefault nvarchar(2000), 
			strName nvarchar(2000), 
			strPrefix nvarchar(50), 
			strSpecialChar nvarchar(2),
			intNumberValue nvarchar(50),
			intMinNumberLength int,
			strSuffix nvarchar(50),
			blnUsePrefix bit, 
			blnUseYear bit, 
			blnUseAlphaNumericValue bit, 
			blnUseSiteID bit,
			intPreviousNumberValue nvarchar(50),
			intNumberNextValue  nvarchar(50),
			PreviousNumber int,
			NextNumber int,
			blnUseHACSCodeSite bit
	)		
	BEGIN TRY

		DECLARE 
		@ErrorMessage NVARCHAR(400),
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' 

		IF @QuickSearch IS NULL	
			BEGIN
				SET @QuickSearch = ''
			END

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1)
		
		INSERT INTO @T
			SELECT 
				idfsNumberName, 
				--strObjectName, 
				r.strDefault,
				r.[name] as 'strName',
				strPrefix, 
				strSpecialChar,
				intNumberValue, 
				intMinNumberLength,
				strSuffix,
				blnUsePrefix, 
				blnUseYear, 
				blnUseAlphaNumericValue, 
				blnUseSiteID,
				intPreviousNumberValue,
				intNumberNextValue,
			    PreviousNumber,
			    NextNumber,
				blnUseHACSCodeSite
			FROM 
				fn_NextNumbers_SelectList(@LangId)
				JOIN dbo.FN_GBL_Reference_GETList(@langId,19000057) r on idfsNumberName = r.idfsReference
			WHERE
				--CAST(idfsNumberName AS NVARCHAR) like '%' + @QuickSearch + '%' OR
				strDefault like '%' + @QuickSearch + '%' OR
				r.[name] like '%' + @QuickSearch + '%' OR
				strPrefix like '%' + @QuickSearch + '%' OR
				CAST(intNumberValue AS NVARCHAR) like '%' + @QuickSearch + '%' OR
				CAST(intMinNumberLength AS NVARCHAR) like '%' + @QuickSearch + '%' OR
				strSuffix like '%' + @QuickSearch + '%' OR
				CAST(intPreviousNumberValue AS NVARCHAR) like '%' + @QuickSearch + '%' 
				

			;
		WITH CTEResults as
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'asc' THEN strDefault END ASC,
				CASE WHEN @sortColumn = 'strDefault' AND @SortOrder = 'desc' THEN strDefault END DESC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'asc' THEN strName END ASC,
				CASE WHEN @sortColumn = 'strName' AND @SortOrder = 'desc' THEN strName END DESC,
				CASE WHEN @sortColumn = 'strPrefix' AND @SortOrder = 'asc' THEN strPrefix END ASC,
				CASE WHEN @sortColumn = 'strPrefix' AND @SortOrder = 'desc' THEN strPrefix END DESC,
				CASE WHEN @sortColumn = 'intNumberValue' AND @SortOrder = 'asc' THEN intNumberValue END ASC,
				CASE WHEN @sortColumn = 'intNumberValue' AND @SortOrder = 'desc' THEN intNumberValue END DESC,
				CASE WHEN @sortColumn = 'intMinNumberLength' AND @SortOrder = 'asc' THEN intMinNumberLength END ASC,
				CASE WHEN @sortColumn = 'intMinNumberLength' AND @SortOrder = 'desc' THEN intMinNumberLength END DESC,
					CASE WHEN @sortColumn = 'intPreviousNumberValue' AND @SortOrder = 'asc' THEN intPreviousNumberValue END ASC,
				CASE WHEN @sortColumn = 'intPreviousNumberValue' AND @SortOrder = 'desc' THEN intPreviousNumberValue END DESC
		) AS ROWNUM,
		COUNT(*) OVER () AS 
				TotalRowCount, 
				--strObjectName,
				idfsNumberName,
				strDefault,
				strName,
				strPrefix,
				strSpecialChar,
				intNumberValue,
				intMinNumberLength,
				strSuffix,
				blnUsePrefix, 
				blnUseYear,
				blnUseAlphaNumericValue, 
				blnUseSiteID,
				intPreviousNumberValue,
				intNumberNextValue,
			    PreviousNumber,
			    NextNumber,
				blnUseHACSCodeSite
			FROM @T
		)

			SELECT
				TotalRowCount, 
				--strObjectName,
				idfsNumberName,
				strDefault,
				strName,
				strPrefix,
				strSpecialChar,
				intNumberValue,
				intPreviousNumberValue,
				intMinNumberLength,
				strSuffix,
				blnUsePrefix, 
				blnUseYear, 
				blnUseAlphaNumericValue,
				blnUseSiteID,  
				intNumberNextValue,
			    PreviousNumber,
			    NextNumber,
				blnUseHACSCodeSite,
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults
		WHERE RowNum > @firstRec AND RowNum < @lastRec 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
