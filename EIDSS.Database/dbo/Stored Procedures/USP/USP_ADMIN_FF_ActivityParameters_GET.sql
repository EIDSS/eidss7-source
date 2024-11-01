﻿-- ================================================================================================
-- Name: USP_ADMIN_FF_ActivityParameters_GET
-- Description:	Retrieves the list of Activity Parameters 
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru	11/28/2018	Initial release for new API.
-- Stephen Long		08/20/2019	Removed commit and rollback transaction statements.
-- Stephen Long		10/02/2019	Added parameter type to table variable.
-- Doug Albanese	07/29/2021	Added idfActivityParameters to the return list
-- Doug Albanese	08/12/2021	Had to reverse some of the changes that Mandar put in, because EF doesn't accept SQL_VARIANT datatypes
-- Mark Wilson		09/30/2021  removed the check for NULL LangID and also removed unused variables.  Added test code.
-- Doug Albanese	10/04/2022	Correction to a translation join to denote which type the data is from the SQL Variant field
-- Doug Albanese	02/24/2023	Create a patch to convert the intNumRow column to a normal sequence of numbers so that the Matrix Flex Form Control can displaying them in the right place.
-- Test code
/*

DECLARE @observationList NVARCHAR(MAX) = '34400000806;1639880000004;1685240000004;1690060000004'
EXEC dbo.USP_ADMIN_FF_ActivityParameters_GET
	@observationList = @observationList, 
	@LangID = 'en-US'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ActivityParameters_GET] 
(
	@observationList NVARCHAR(MAX),
	@LangID NVARCHAR(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@idfsLanguage BIGINT,
		@rowCount INT,
		@currentRow INT,
		@currentObservation BIGINT,
		@idfVersion BIGINT,
		@innerCurrentRow INT,
		@NumRow INT,
		@idfRow BIGINT,
		@CurrentIdfRow BIGINT,
		@type BIGINT,
		@innerRowCount INT,
		@idfsSection BIGINT,
		@idfsCurrentSection BIGINT,
		@OldType BIGINT = 0

	DECLARE @ResultTable TABLE (
		[idfActivityParameters] BIGINT,
		[idfObservation] BIGINT,
		[idfsFormTemplate] BIGINT,
		[idfsParameter] BIGINT,
		[idfsSection] BIGINT,
		[idfRow] BIGINT,
		[intNumRow] INT,
		[Type] BIGINT,
		[varValue] NVARCHAR(4000),
		[strNameValue] NVARCHAR(200),
		[numRow] INT,
		[ParameterType] BIGINT 
		)
	DECLARE @observationsTable TABLE (
		[idfObservation] BIGINT,
		[idfVersion] BIGINT,
		[intRowNumber] INT
		)
	DECLARE @MatrixInfo AS TABLE (
		[idfVersion] BIGINT,
		[idfsAggrCaseType] BIGINT,
		[idfAggregateCaseSection] BIGINT
		)
	DECLARE @matrixTable AS TABLE (
		idfVersion BIGINT,
		idfRow BIGINT,
		idfsParameter BIGINT,
		strDefaultParameterName NVARCHAR(400),
		idfsParameterValue NVARCHAR(MAX),
		NumRow INT,
		[strNameValue] NVARCHAR(200),
		[idfsSection] BIGINT,
		[langid] NVARCHAR(20)
		)
	  DECLARE @DistinctNumRows TABLE (
		[OldNumRow] INT,
		[NewNumRow] INT
		)
	BEGIN TRY
		SET @idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LangID);

		INSERT INTO @observationsTable (
			[idfObservation],
			[intRowNumber]
			)
		SELECT CAST([Value] AS BIGINT),
			ROW_NUMBER() OVER (
				ORDER BY [Value]
				)
		FROM [dbo].[FN_GBL_SYS_SplitList](@observationList, NULL, NULL)
		
		INSERT INTO @ResultTable 
		(
			idfActivityParameters,
			idfObservation,
			idfsFormTemplate,
			idfsParameter,
			idfsSection,
			idfRow,
			varValue,
			[Type],
			numRow, 
			[ParameterType]
		)
		SELECT 
			AP.idfActivityParameters,
			AP.idfObservation,
			O.idfsFormTemplate,
			AP.idfsParameter,
			P.idfsSection,
			AP.idfRow,
			CAST(AP.varValue AS NVARCHAR(MAX)),
			dbo.FN_ADMIN_FF_TypeActivityParameters_GET(AP.idfsParameter),
			ROW_NUMBER() OVER (
				PARTITION BY AP.idfObservation ORDER BY AP.idfRow
				), 
			P.idfsParameterType
		FROM dbo.tlbActivityParameters AP
		LEFT JOIN dbo.ffParameter P	ON P.idfsParameter = AP.idfsParameter AND P.intRowStatus = 0
		INNER JOIN dbo.tlbObservation O ON AP.idfObservation = O.idfObservation
		
		WHERE AP.idfObservation IN (SELECT idfObservation FROM @observationsTable)
		AND AP.intRowStatus = 0
		AND O.intRowStatus = 0
		ORDER BY 
			AP.idfObservation,
			P.idfsSection,
			AP.idfRow

		SELECT @rowCount = MAX([intRowNumber])
		FROM @observationsTable

		
		SET @currentRow = 1;

		WHILE (@currentRow <= @rowCount)
		BEGIN
			SELECT @currentObservation = [idfObservation]
			FROM @observationsTable
			WHERE intRowNumber = @currentRow;

			DELETE
			FROM @MatrixInfo

			INSERT INTO @MatrixInfo
			EXEC dbo.USP_ADMIN_FF_AggregateObservationMatrixVersion_GET 
				@currentObservation

			SELECT TOP 1 @idfVersion = [idfVersion]
			FROM @MatrixInfo

			IF (@idfVersion IS NULL)
			BEGIN
				SELECT TOP 1 @idfVersion = [idfVersion]
				FROM dbo.tlbAggrMatrixVersionHeader
				WHERE idfsMatrixType IN (
						SELECT TOP 1 [idfAggregateCaseSection]
						FROM @MatrixInfo
						)
					AND [blnIsActive] = 1
				ORDER BY CAST(ISNULL(blnIsDefault, 0) AS INT) + CAST(ISNULL(blnIsActive, 0) AS INT) DESC,
					datStartDate DESC
			END;

			UPDATE @observationsTable
			SET [idfVersion] = @idfVersion
			WHERE intRowNumber = @currentRow;

			SELECT @innerRowCount = NULL

			SELECT @innerRowCount = MAX([numRow])
			FROM @ResultTable
			WHERE [Type] = 1
				AND [idfObservation] = @currentObservation

			IF (@innerRowCount > 0)
			BEGIN
				SELECT @NumRow = - 1,
					@CurrentIdfRow = 0,
					@innerCurrentRow = 1;

				DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR
				SELECT [idfRow],
					[idfsSection]
				FROM @ResultTable
				WHERE [Type] = 1
					AND [idfObservation] = @currentObservation

				OPEN curs

				FETCH NEXT
				FROM curs
				INTO @idfRow,
					@idfsSection

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF (@idfsCurrentSection IS NULL)
						SET @idfsCurrentSection = @idfsSection;

					IF (@idfsCurrentSection <> @idfsSection)
					BEGIN
						SET @idfsCurrentSection = @idfsSection;
						SET @NumRow = - 1;
					END

					IF (@CurrentIdfRow <> @idfRow)
					BEGIN
						SET @CurrentIdfRow = @idfRow;
						SET @NumRow = @NumRow + 1;

						UPDATE @ResultTable
						SET [intNumRow] = @NumRow
						WHERE [idfRow] = @idfRow
							AND [idfObservation] = @currentObservation
					END

					FETCH NEXT
					FROM curs
					INTO @idfRow,
						@idfsSection
				END

				CLOSE curs

				DEALLOCATE curs
			END
			
			SELECT @innerRowCount = NULL

			SELECT @innerRowCount = MAX([numRow])
			FROM @ResultTable
			WHERE [Type] > 1
				AND [idfObservation] = @currentObservation

			IF (@innerRowCount > 0)
			BEGIN
				SELECT @NumRow = NULL,
					@idfRow = NULL,
					@innerCurrentRow = 1;

				DECLARE curs CURSOR LOCAL FORWARD_ONLY STATIC
				FOR
				SELECT [idfRow],
					[Type]
				FROM @ResultTable
				WHERE [Type] > 1
					AND [idfObservation] = @currentObservation

				OPEN curs

				FETCH NEXT
				FROM curs
				INTO @idfRow,
					@type

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @OldType <> ISNULL(@type, - 1)
					BEGIN
						DELETE
						FROM @matrixTable

						INSERT INTO @matrixTable
						EXEC dbo.USP_ADMIN_FF_PredefinedStub_GET 
							@type,
							@idfVersion,
							@idfsLanguage

						SET @OldType = ISNULL(@type, 0)
					END

					SET @NumRow = NULL

					SELECT @NumRow = [NumRow]
					FROM @matrixTable
					WHERE [idfRow] = @idfRow

					UPDATE @ResultTable
					SET [intNumRow] = @NumRow
					WHERE [idfRow] = @idfRow
						AND [idfObservation] = @currentObservation;

					FETCH NEXT
					FROM curs
					INTO @idfRow,
						@type
				END

				CLOSE curs

				DEALLOCATE curs
			END

			SET @currentRow = @currentRow + 1;
		END
		
		UPDATE @ResultTable
		SET [intNumRow] = 0
		WHERE [Type] = 0
		
		UPDATE RT
		SET RT.[strNameValue] = ISNULL(SNT.[strTextString], BR.[strDefault])
		FROM @ResultTable AS RT
		INNER JOIN dbo.ffParameter P ON RT.idfsParameter = P.idfsParameter AND P.idfsEditor = 10067002 AND P.[intRowStatus] = 0
		INNER JOIN dbo.trtBaseReference BR ON BR.idfsBaseReference = CASE 
																		WHEN (SQL_VARIANT_PROPERTY(RT.varValue, 'BaseType') = 'bigint')
																			OR (
																				SQL_VARIANT_PROPERTY(RT.varValue, 'BaseType') = 'nvarchar'
																				AND ISNUMERIC(CAST(RT.varValue AS NVARCHAR)) = 1
																				)
																			THEN CAST(RT.varValue AS BIGINT)
																		ELSE - 1
																		END
		 LEFT JOIN dbo.trtStringNameTranslation SNT ON SNT.idfsBaseReference = CASE 
																		WHEN (SQL_VARIANT_PROPERTY(RT.varValue, 'BaseType') = 'bigint')
																			OR (
																				SQL_VARIANT_PROPERTY(RT.varValue, 'BaseType') = 'nvarchar'
																				AND ISNUMERIC(CAST(RT.varValue AS NVARCHAR)) = 1
																				)
																			THEN CAST(RT.varValue AS BIGINT)
																		ELSE - 1
																		END AND SNT.idfsLanguage = @idfsLanguage AND SNT.[intRowStatus] = 0

/***********************************************************************/
/* Patch to renumber Row Numbers for use with Flex Form matrix control */
/***********************************************************************/
		 INSERT INTO @DistinctNumRows
		 SELECT DISTINCT intNumRow, null as NewNumRow
		 FROM @ResultTable
	
		 UPDATE
			 @ResultTable
		 SET
			 intNumRow = dnr. NewNumRow
		 FROM
			 @ResultTable rt
		 INNER JOIN
			 (SELECT 
				  OldNumRow, 
				  (ROW_NUMBER() OVER (ORDER BY OldNumRow)  - 1 ) AS NewNumRow
			   FROM   @DistinctNumRows
			) dnr
		 ON 
			 rt.intNumRow = dnr.OldNumRow;
/***********************************************************************/

		
		SELECT 
			[idfActivityParameters],
			[idfObservation],
			[idfsFormTemplate],
			[idfsParameter],
			[idfsSection],
			[idfRow],
			[intNumRow],
			[Type],
			[varValue],
			[strNameValue],
			[numRow],
			0 AS [FakeField], 
			[ParameterType] 
		FROM @ResultTable
		ORDER BY [idfObservation],
			[idfsParameter],
			[idfRow]
			
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END
