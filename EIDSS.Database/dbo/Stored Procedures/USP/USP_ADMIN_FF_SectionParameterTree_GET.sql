
-- ================================================================================================
-- Name: USP_ADMIN_FF_Parameters_GET
-- Description: Gets list of the Parameters.
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Doug Albanese	12/23/2019	Initial release for new API.
-- Doug Albanese	4/9/2020	Changes to include any form types that haven't been used
-- Doug Albanese	4/10/2020   Changes to fix NULL filtering
-- Doug Albanese	6/15/2020	Removed 'Print' statement that is displaying a lot of data for no reason
-- Doug Albanese	10/28/2020	Change the language detection to use idfsLanguage
-- Doug Albanese	04/27/2021	Refactored to work with EF.
-- Doug Albanese	07/26/2021	Update to correct section searching
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_SectionParameterTree_GET] (
	@LangID NVARCHAR(50)
	,@idfsSection BIGINT = NULL
	,@idfsFormType BIGINT = NULL
	,@parameterFilter NVARCHAR(200) = NULL
	,@sectionFilter NVARCHAR(200) = NULL
	)
AS
BEGIN
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @iNode INT = 3
	DECLARE @iNodes INT = 0
	DECLARE @iNodeTemp INT = 0
	DECLARE @iNodeTemp2 INT = 0
	DECLARE @levels INT = 0
	DECLARE @TestLevels INT = 1
	DECLARE @Sections NVARCHAR(MAX)
	DECLARE @SectionsFinal NVARCHAR(MAX)
	DECLARE @SelectStatement NVARCHAR(MAX)
	DECLARE @tempSelectStatement NVARCHAR(MAX)
	DECLARE @OrderBy NVARCHAR(MAX)
	DECLARE @whereFilter NVARCHAR(MAX) = ''
	DECLARE @intRowStatusFilter NVARCHAR(MAX) = ''
	DECLARE @tempintRowStatusFilter NVARCHAR(MAX) = ''
	DECLARE @whereFilterFinal NVARCHAR(MAX) = ''
	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @ReturnSections TABLE (Sections NVARCHAR(MAX))
	
	BEGIN TRY
		BEGIN
			IF @parameterFilter = ''
				BEGIN
					SET @parameterFilter = NULL
				END

			IF @sectionFilter = ''
				BEGIN
					SET @sectionFilter = NULL
				END

			DECLARE @Level TABLE (
				Levels INT
			)
			--Perform a test to determine how many levels deep the Sections go
			WHILE (@TestLevels = 1)
			BEGIN
				SET @SQL = 'SELECT COUNT(s1.idfsSection) AS Levels FROM ffSection s1 '
				SET @iNodeTemp = 2

				WHILE (@iNodeTemp < @iNode)
				BEGIN
					SET @SQL = CONCAT (
							@SQL
							,'INNER JOIN ffSection s'
							,@iNodeTemp
							,' ON s'
							,@iNodeTemp
							,'.idfsParentSection = s'
							,@iNodeTemp - 1
							,'.idfsSection '
							)
					SET @iNodeTemp = @iNodeTemp + 1
				END

				SET @SQL = @SQL + 'where s1.intRowStatus = 0 and s1.idfsParentSection IS NULL '

				--print @sql
				INSERT INTO @Level (Levels) EXECUTE( @SQL)

				SELECT @Levels = Levels from @Level
				
				IF (@Levels <> 0)
				BEGIN
					SET @iNode = @iNode + 1
				END
				ELSE
				BEGIN
					SET @TestLevels = 0
				END

			END
			
			--Reset and now build the actual SQL that will provide the data for the tree view
			SET @iNodes = @iNode - 2
			SET @Sections = 'DECLARE @FF TABLE (ft bigint, ftl nvarchar(max), '
			SET @SQL = 's1.idfsFormType, ftl.name, '
			SET @iNodeTemp = 1

			--Create the Select elements
			WHILE (@iNodeTemp <= @iNodes)
			BEGIN
				--Create the table columns, no logic to strip the "," at the end, because we are going to append some static fields after this routine
				SET @Sections = CONCAT (
						@Sections
						,'s'
						,@iNodeTemp
						,' BIGINT, '
						)
				SET @Sections = CONCAT (
						@Sections
						,'sl'
						,@iNodeTemp
						,' NVARCHAR(MAX), '
						)
				SET @SQL = CONCAT (
						@SQL
						,'s'
						,@iNodeTemp
						,'.idfsSection, sl'
						,@iNodeTemp
						,'.name AS Text'
						,@iNodeTemp
						,', '
						)
				SET @iNodeTemp = @iNodeTemp + 1
			END
			
			--Create 2 fields to store the parameter and name for each section
			SET @Sections = CONCAT (
					@Sections
					,'p BIGINT, pl NVARCHAR(MAX)) '
					)
			SET @iNodes = @iNode - 2
			SET @Sections = CONCAT (
					@Sections
					,'DECLARE @FFFinal TABLE (ft bigint, ftl nvarchar(max), '
					)
			SET @SQL = 's1.idfsFormType, ftl.name, '
			SET @iNodeTemp = 1

			--Create the Select elements
			WHILE (@iNodeTemp <= @iNodes)
			BEGIN
				--Create the table columns, no logic to strip the "," at the end, because we are going to append some static fields after this routine
				SET @Sections = CONCAT (
						@Sections
						,'s'
						,@iNodeTemp
						,' BIGINT, '
						)
				SET @Sections = CONCAT (
						@Sections
						,'sl'
						,@iNodeTemp
						,' NVARCHAR(MAX), '
						)
				SET @SQL = CONCAT (
						@SQL
						,'s'
						,@iNodeTemp
						,'.idfsSection, sl'
						,@iNodeTemp
						,'.name AS Text'
						,@iNodeTemp
						,', '
						)
				SET @iNodeTemp = @iNodeTemp + 1
			END

			--Create 2 fields to store the parameter and name for each section
			SET @Sections = CONCAT (
					@Sections
					,'p BIGINT, pl NVARCHAR(MAX)) '
					)
			SET @SQL = CONCAT (
					@SQL
					,'NULL, NULL '
					)
			SET @SQL = CONCAT (
					'INSERT INTO @FF SELECT DISTINCT '
					,@SQL
					)
			SET @SQL = CONCAT (
					@SQL
					,' FROM ffSection s1 '
					)
			SET @SQL = CONCAT (
					@SQL
					,'LEFT JOIN dbo.FN_GBL_Reference_GETList('''
					,@LangId
					,''', 19000034) ftl'
					,' ON ftl.idfsReference = s1.idfsFormType '
					)
			SET @SQL = CONCAT (
					@SQL
					,'LEFT JOIN dbo.FN_GBL_Reference_GETList('''
					,@LangId
					,''', 19000101) sl1'
					,' ON sl1.idfsReference = s1.idfsSection '
					)
			SET @iNodeTemp = 2
			
			--Create the Join Elements
			WHILE (@iNodeTemp <= @iNodes)
				BEGIN
					SET @SQL = CONCAT (
							@SQL
							,'LEFT JOIN ffSection s'
							,@iNodeTemp
							,' ON s'
							,@iNodeTemp
							,'.idfsParentSection = s'
							,@iNodeTemp - 1
							,'.idfsSection AND s'
							,@iNodeTemp
							,'.intRowStatus=0 '
						)
					SET @SQL = CONCAT (
							@SQL
							,'LEFT JOIN dbo.FN_GBL_Reference_GETList('''
							,@LangId
							,''', 19000101) sl'
							,@iNodeTemp
							,' ON sl'
							,@iNodeTemp
							,'.idfsReference = s'
							,@iNodeTemp
							,'.idfsSection '
						)

					IF (@sectionFilter IS NOT NULL)
						BEGIN
							SET @whereFilter = CONCAT (
									@whereFilter
									,'OR sl'
									,@iNodeTemp
									,'.name LIKE ''%'
									,@sectionFilter
									,'%'' '
									)
							SET @whereFilterFinal = CONCAT (
									@whereFilterFinal
									,'sl'
									,@iNodeTemp
									,' LIKE ''%'
									,@sectionFilter
									,'%'' OR '
									)
						END
					SET @iNodeTemp = @iNodeTemp + 1
				END

			IF @whereFilterFinal <> ''
				BEGIN
					SET @whereFilterFinal = CONCAT (
						'sl1 LIKE ''%',
						@sectionFilter,
						'%'' OR ',
						@whereFilterFinal
					)
				END

			IF @whereFilter <> ''
				BEGIN
					SET @SQL = CONCAT (
							@SQL
							,'where s1.intRowStatus = 0 and s1.idfsParentSection IS NULL AND (ftl.name like ''%'
							,@sectionFilter
							,'%'' OR sl1.name like ''%'
							,@sectionFilter
							,'%'' '
							,@whereFilter
							,') '
						)
				END
			ELSE
				BEGIN
					SET @SQL = CONCAT (
							@SQL
							,'where s1.intRowStatus = 0 and s1.idfsParentSection IS NULL '
							)
				END
			
			--Create holding spots for the upcoming SQL selects
			DECLARE @strNULLs NVARCHAR(MAX)
			DECLARE @iNULLs INT = @iNodes
			WHILE (@iNULLs > 0)
				BEGIN
					SET @strNULLs = CONCAT(@strNULLs,', null, null ')
					SET @iNULLs = @iNULLs - 1
				END

			--Now add two more holding spots for the non-dynamic fields
			SET @strNULLs = CONCAT(@strNULLs,', null, null ')

			IF (@idfsFormType IS NOT NULL)
				BEGIN
					SET @SQL = @SQL + 'and s1.idfsFormType = ' + CAST(@idfsFormType AS VARCHAR(50)) + ' '

					--Add Form Tyes that haven't been used yet
					SET @SQL = @SQL + 'INSERT INTO @FF '
					SET @SQL = @SQL + 'SELECT idfsReference AS ft,[name] AS ftl ' + @strNULLs
					SET @SQL = @SQL + 'FROM dbo.FN_GBL_ReferenceRepair(''' + @LangID + ''', 19000034) ft '
					SET @SQL = @SQL + 'WHERE idfsReference IN (' + CAST(@idfsFormType AS VARCHAR(50)) + ') AND '
					SET @SQL = @SQL + 'idfsReference NOT IN (SELECT DISTINCT idfsFormType FROM ffParameter) '
				END
			ELSE
				BEGIN
					--Add Form Tyes that haven't been used yet
					SET @SQL = @SQL + 'INSERT INTO @FF '
					SET @SQL = @SQL + 'SELECT idfsReference AS ft,[name] AS ftl ' + @strNULLs
					SET @SQL = @SQL + 'FROM dbo.FN_GBL_ReferenceRepair(''' + @LangID + ''', 19000034) ft '
					SET @SQL = @SQL + 'WHERE idfsReference IN (10034501,10034502,10034503,10034504,10034505,10034506,10034507,10034508,10034509,10034015,10034011,10034007) AND '
					SET @SQL = @SQL + 'idfsReference NOT IN (SELECT DISTINCT idfsFormType FROM ffParameter) '
				END

			--Create an insert to populate parameters that are associated for each section
			SET @iNodeTemp = 1
			SET @SelectStatement = 'INSERT INTO @FF SELECT DISTINCT ft, ftl, '

			WHILE (@iNodeTemp <= @iNodes)
			BEGIN
				SET @SelectStatement = CONCAT (
						@SelectStatement
						,'s'
						,@iNodeTemp
						,', sl'
						,@iNodeTemp
						,', '
						)
				
				SET @iNodeTemp = @iNodeTemp + 1
			END

			SET @iNodeTemp = 1

			WHILE (@iNodeTemp <= (@iNodes))
				BEGIN
					SET @iNodeTemp2 = @iNodeTemp + 1
					SET @tempSelectStatement = @SelectStatement

					WHILE (@iNodeTemp2 <= (@iNodes))
					BEGIN
						SET @tempSelectStatement = REPLACE(@tempSelectStatement, CONCAT (
									's'
									,@iNodeTemp2
									), 'null')
						SET @tempSelectStatement = REPLACE(@tempSelectStatement, CONCAT (
									'sl'
									,@iNodeTemp2
									), 'null')
				
						SET @iNodeTemp2 = @iNodeTemp2 + 1
					END

					SET @SQL = CONCAT (
							@SQL
							,@tempSelectStatement
							,'p.idfsParameter AS p, pn.name AS pn FROM @FF ff LEFT JOIN ffParameter p ON p.idfsSection = ff.s'
							,@iNodeTemp
							,' LEFT JOIN dbo.FN_GBL_Reference_GETList('''
							,@LangId
							,''', 19000066) pn ON pn.idfsReference = p.idfsParameter WHERE p.intRowStatus = 0 AND pn.name like ''%' + Coalesce(@parameterFilter, '') + '%'' '
							)
					SET @iNodeTemp = @iNodeTemp + 1
				END

			--Add a wrapper to deliver the data in a flat file format (per row), for cosumption and parsing on the code behind
			SET @iNodeTemp = 1

			DECLARE @SQLWrapper NVARCHAR(MAX)
			DECLARE @MergedSelect NVARCHAR(MAX)

			SET @SQLWrapper = 'SELECT (CAST(COALESCE(ft,'''') AS NVARCHAR(MAX))  + ''¦'' + COALESCE(ftl,'''') + ''!'' + '

			WHILE (@iNodeTemp <= @iNodes)
			BEGIN
				SET @SQLWrapper = CONCAT (
						@SQLWrapper
						,'CAST(COALESCE(s'
						,@iNodeTemp
						,','''') AS NVARCHAR(MAX)) + ''↕'' + COALESCE(sl'
						,@iNodeTemp
						,','''') + ''‼'' + '
						)
				SET @iNodeTemp = @iNodeTemp + 1
			END

			--Create the ORDER BY elements
			SET @iNodeTemp = 1
			SET @OrderBy = 'ftl, '

			WHILE (@iNodeTemp <= @iNodes)
			BEGIN
				--Create the table columns, no logic to strip the "," at the end, because we are going to append some static fields after this routine
				SET @OrderBy = CONCAT (
						@OrderBy
						,'sl'
						,@iNodeTemp
						,', '
						)
				SET @iNodeTemp = @iNodeTemp + 1
			END

			SET @OrderBy = CONCAT (
					@OrderBy
					,'pl '
					)
			SET @SQLWrapper = CONCAT (
					@SQLWrapper
					,'CAST(COALESCE(p,'''') AS NVARCHAR(MAX)) + ''↕'' + COALESCE(pl, '''') + ''‼'') As Section '
					)
			SET @SQL = CONCAT (
					@Sections
					,@SQL
					,@SQLWrapper
					,' FROM @FF '
					)

			IF @parameterFilter IS NOT NULL
			BEGIN
				SET @SQL = CONCAT (
						@SQL
						,'WHERE pl like ''%'
						,@parameterFilter
						,'%'' '
						)
			END

			IF @sectionFilter IS NOT NULL
				BEGIN
					SET @whereFilterFinal = CONCAT (
							@whereFilterFinal
							,'.'
							)
					SET @whereFilterFinal = REPLACE(@whereFilterFinal, ' OR .', ' ')

					IF @parameterFilter IS NULL
						BEGIN
							SET @whereFilterFinal = CONCAT (
									'WHERE '
									,@whereFilterFinal
									)
							SET @SQL = CONCAT (
								@SQL
								,@whereFilterFinal
								)
						END
					ELSE
						BEGIN
							SET @SQL = CONCAT (
								@SQL
								,'AND ('
								,@whereFilterFinal
								,') '
								)
						END
				END
				
			SET @SQL = CONCAT (
					@SQL
					,'ORDER BY '
					,@OrderBy
					)
			
			EXEC (@SQL)
			WITH RESULT SETS(([Section] NVARCHAR(max) NOT NULL))
		END
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT = 1
			ROLLBACK;

		SET @returnCode = ERROR_NUMBER();
		SET @returnMsg = 'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY()) + ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE()) + ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '') + ' ErrorLine: ' + CONVERT(VARCHAR, ISNULL(ERROR_LINE(), '')) + ' ErrorMessage: ' + ERROR_MESSAGE();;

		throw;
	END CATCH
END
