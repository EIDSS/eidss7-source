-- ================================================================================================
-- Name: USP_CONF_AggregateSetting_GetList_WithName		
--
-- Description: Retreives Entries from [tstAggrSetting] based on Customization Package
-- 
-- Author: Lamont Mitchell
-- 
-- Revision History:
-- Name                     Date       Change Detail
-- ------------------------ ---------- -----------------------------------------------------------
-- Lamont Mitchell          11/27/2018 Initial Created
-- Lamont Mitchell          01/10/2019 Added check for IntrowStatus = 0 in Where Clause
-- Steven Verner            05/16/2021 Paging enabled
-- Stephen Long             08/23/2021 Added to TFS.  Changed base reference calls to use 
--                                     reference get list to get correct language translations, 
--                                     and added language ID parameter.
-- Ann Xiong				01/19/2022 Added idfsSite parameter
-- Ann Xiong				01/31/2022 Updated to return Parent Site or top level site aggregate settings if passed in site does not have any aggregate settings
-- Mike Kornegay			02/10/2023 Add final branch so that if sites for the customization are null, it will still get the aggregate settings.
--
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_CONF_AggregateSetting_GetList_WithName] (
	@LanguageID NVARCHAR(50)
	,@idfCustomizationPackage BIGINT
	,@idfsSite BIGINT = NULL
	,@pageNo INT = 1
	,@pageSize INT = 10
	,@sortColumn NVARCHAR(30) = 'idfsAggrCaseType'
	,@sortOrder NVARCHAR(4) = 'asc'
	)
AS
BEGIN
	DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode BIGINT = 0;
	DECLARE @idfsReferenceType BIGINT;

	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @firstRec INT
		DECLARE @lastRec INT
		DECLARE @t TABLE (
			idfsAggrCaseType BIGINT
			,idfCustomizationPackage BIGINT
			,idfsSite BIGINT
			,idfsStatisticAreaType BIGINT
			,idfsStatisticPeriodType BIGINT
			,StrCaseType NVARCHAR(4000)
			,StrAreaType NVARCHAR(4000)
			,StrPeriodType NVARCHAR(4000)
			);

		SET @firstRec = (@pageNo - 1) * @pagesize;
		SET @lastRec = (@pageNo * @pageSize + 1);

         IF EXISTS
         (
                SELECT 	idfsAggrCaseType,
                       	idfCustomizationPackage,
			     		idfsSite,
                       	idfsStatisticAreaType,
                       	idfsStatisticPeriodType
                FROM 	dbo.tstAggrSetting
                WHERE 	idfCustomizationPackage = @idfCustomizationPackage
			    	AND idfsSite = @idfsSite
                    AND intRowStatus = 0
            )
            BEGIN
				INSERT INTO @T
				SELECT	AGR.[idfsAggrCaseType]
						,AGR.[idfCustomizationPackage]
						,AGR.[idfsSite]
						,AGR.[idfsStatisticAreaType]
						,AGR.[idfsStatisticPeriodType]
						,AGRC.[name] AS StrCaseType
						,ART.[name] AS StrAreaType
						,PRT.[name] AS StrPeriodType
				FROM	dbo.tstAggrSetting AS AGR
						LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000102) AGRC ON AGRC.idfsReference = AGR.idfsAggrCaseType
						LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000089) ART ON ART.idfsReference = AGR.idfsStatisticAreaType
						LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000091) PRT ON PRT.idfsReference = AGR.idfsStatisticPeriodType
						INNER JOIN dbo.tstSite s ON s.idfsSite = @idfsSite
				WHERE	AGR.[idfCustomizationPackage] = @idfCustomizationPackage
						AND AGR.[idfsSite] = @idfsSite
						AND AGR.intRowStatus = 0;
            END
            ELSE
            BEGIN
				IF EXISTS
				(
					SELECT 	a.idfsAggrCaseType,
                       		a.idfCustomizationPackage,
			     			a.idfsSite,
                       		a.idfsStatisticAreaType,
                       		a.idfsStatisticPeriodType
					FROM 	dbo.tstAggrSetting a
							INNER JOIN dbo.tstSite s ON s.idfsSite = @idfsSite
					WHERE 	a.idfCustomizationPackage = @idfCustomizationPackage
			    			AND a.idfsSite = s.idfsParentSite
                      		AND a.intRowStatus = 0
				)
				BEGIN
					INSERT INTO @T
					SELECT	AGR.[idfsAggrCaseType]
							,AGR.[idfCustomizationPackage]
							,AGR.[idfsSite]
							,AGR.[idfsStatisticAreaType]
							,AGR.[idfsStatisticPeriodType]
							,AGRC.[name] AS StrCaseType
							,ART.[name] AS StrAreaType
							,PRT.[name] AS StrPeriodType
					FROM	dbo.tstAggrSetting AS AGR
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000102) AGRC ON AGRC.idfsReference = AGR.idfsAggrCaseType
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000089) ART ON ART.idfsReference = AGR.idfsStatisticAreaType
							LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000091) PRT ON PRT.idfsReference = AGR.idfsStatisticPeriodType
							INNER JOIN dbo.tstSite s ON s.idfsSite = @idfsSite
					WHERE	AGR.[idfCustomizationPackage] = @idfCustomizationPackage
							AND AGR.[idfsSite] = s.idfsParentSite
							AND AGR.intRowStatus = 0;
				END
				ELSE
				BEGIN
					DECLARE @idfsSiteTop BIGINT;

					SELECT TOP 1	
							@idfsSiteTop = idfsSite
					FROM 	dbo.tstAggrSetting
					WHERE 	idfCustomizationPackage = @idfCustomizationPackage
                      		AND intRowStatus = 0;

					IF (@idfsSiteTop IS NOT NULL)
						BEGIN
							INSERT INTO @T
							SELECT	AGR.[idfsAggrCaseType]
									,AGR.[idfCustomizationPackage]
									,AGR.[idfsSite]
									,AGR.[idfsStatisticAreaType]
									,AGR.[idfsStatisticPeriodType]
									,AGRC.[name] AS StrCaseType
									,ART.[name] AS StrAreaType
									,PRT.[name] AS StrPeriodType
							FROM	dbo.tstAggrSetting AS AGR
									LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000102) AGRC ON AGRC.idfsReference = AGR.idfsAggrCaseType
									LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000089) ART ON ART.idfsReference = AGR.idfsStatisticAreaType
									LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000091) PRT ON PRT.idfsReference = AGR.idfsStatisticPeriodType
									--INNER JOIN dbo.tstSite s ON s.idfsSite = @idfsSite
							WHERE	AGR.[idfCustomizationPackage] = @idfCustomizationPackage
									AND AGR.[idfsSite] = @idfsSiteTop
									AND AGR.intRowStatus = 0;
						END
					ELSE
						BEGIN
							INSERT INTO @T
							SELECT	AGR.[idfsAggrCaseType]
									,AGR.[idfCustomizationPackage]
									,AGR.[idfsSite]
									,AGR.[idfsStatisticAreaType]
									,AGR.[idfsStatisticPeriodType]
									,AGRC.[name] AS StrCaseType
									,ART.[name] AS StrAreaType
									,PRT.[name] AS StrPeriodType
							FROM	dbo.tstAggrSetting AS AGR
									LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000102) AGRC ON AGRC.idfsReference = AGR.idfsAggrCaseType
									LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000089) ART ON ART.idfsReference = AGR.idfsStatisticAreaType
									LEFT JOIN dbo.FN_GBL_Reference_GETList(@LanguageID, 19000091) PRT ON PRT.idfsReference = AGR.idfsStatisticPeriodType
									--INNER JOIN dbo.tstSite s ON s.idfsSite = @idfsSite
							WHERE	AGR.[idfCustomizationPackage] = @idfCustomizationPackage
									AND AGR.[idfsSite] IS NULL
									AND AGR.intRowStatus = 0;
						END
				END
            END
			;
		WITH CTEResults
		AS (
			SELECT ROW_NUMBER() OVER (
					ORDER BY CASE 
							WHEN @sortColumn = 'idfsAggrCaseType'
								AND @SortOrder = 'asc'
								THEN idfsAggrCaseType
							END ASC
						,CASE 
							WHEN @sortColumn = 'idfsAggrCaseType'
								AND @SortOrder = 'desc'
								THEN idfsAggrCaseType
							END DESC
						,CASE 
							WHEN @sortColumn = 'idfCustomizationPackage'
								AND @SortOrder = 'asc'
								THEN idfCustomizationPackage
							END ASC
						,CASE 
							WHEN @sortColumn = 'idfCustomizationPackage'
								AND @SortOrder = 'desc'
								THEN idfCustomizationPackage
							END DESC
						,CASE 
							WHEN @sortColumn = 'idfsSite'
								AND @SortOrder = 'asc'
								THEN idfsSite
							END ASC
						,CASE 
							WHEN @sortColumn = 'idfsSite'
								AND @SortOrder = 'desc'
								THEN idfsSite
							END DESC
						,CASE 
							WHEN @sortColumn = 'idfsStatisticAreaType'
								AND @SortOrder = 'asc'
								THEN idfsStatisticAreaType
							END ASC
						,CASE 
							WHEN @sortColumn = 'idfsStatisticAreaType'
								AND @SortOrder = 'desc'
								THEN idfsStatisticAreaType
							END DESC
						,CASE 
							WHEN @sortColumn = 'idfsStatisticPeriodType'
								AND @SortOrder = 'asc'
								THEN idfsStatisticPeriodType
							END ASC
						,CASE 
							WHEN @sortColumn = 'idfsStatisticPeriodType'
								AND @SortOrder = 'desc'
								THEN idfsStatisticPeriodType
							END DESC
						,CASE 
							WHEN @sortColumn = 'StrCaseType'
								AND @SortOrder = 'asc'
								THEN StrCaseType
							END ASC
						,CASE 
							WHEN @sortColumn = 'StrCaseType'
								AND @SortOrder = 'desc'
								THEN StrCaseType
							END DESC
						,CASE 
							WHEN @sortColumn = 'StrAreaType'
								AND @SortOrder = 'asc'
								THEN StrAreaType
							END ASC
						,CASE 
							WHEN @sortColumn = 'StrAreaType'
								AND @SortOrder = 'desc'
								THEN StrAreaType
							END DESC
						,CASE 
							WHEN @sortColumn = 'StrPeriodType'
								AND @SortOrder = 'asc'
								THEN StrPeriodType
							END ASC
						,CASE 
							WHEN @sortColumn = 'StrPeriodType'
								AND @SortOrder = 'desc'
								THEN StrPeriodType
							END DESC
					) AS ROWNUM
				,COUNT(*) OVER () AS TotalRowCount
				,idfsAggrCaseType
				,idfCustomizationPackage
				,idfsStatisticAreaType
				,idfsStatisticPeriodType
				,StrCaseType
				,StrAreaType
				,StrPeriodType
			FROM @T
			)
		SELECT TotalRowCount
			,idfsAggrCaseType
			,idfCustomizationPackage
			,idfsStatisticAreaType
			,idfsStatisticPeriodType
			,StrCaseType
			,StrAreaType
			,StrPeriodType
			,TotalPages = (TotalRowCount / @pageSize) + IIF(TotalRowCount % @pageSize > 0, 1, 0)
			,CurrentPage = @pageNo
		FROM CTEResults
		WHERE RowNum > @firstRec
			AND RowNum < @lastRec;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
