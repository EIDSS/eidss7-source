-- ================================================================================================
-- Name: USP_ADMIN_FF_AggregateMatrixVersion_GETList
--
-- Description: Gets the list of activte and inactive matrix versions. The most recently 
-- activated version is sorted to the top.
-- Selects lookup list of aggregate matrix versions for specific aggregate matrix type.
--
-- Usable matix types are:
-- Veterinary Aggregate Disease Report = 71090000000
-- Diagnostic Action = 71460000000
-- Prophylactic Action = 71300000000
-- Human Aggregate Disease Report = 71190000000
-- Sanitary Action = 71260000000
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru   01/02/2019 Initial release for new API.
-- Stephen Long    09/03/2020 Cleaned up documenation and formatting.  Replaced version 6.1 call 
--                            to version 7.0.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_AggregateMatrixVersion_GETList] (
	@LangID AS NVARCHAR(50),
	@idfMatrix BIGINT
	)
AS
BEGIN
	BEGIN TRY
		IF @idfMatrix IS NULL -- Correct matrix defaults during loading lookup cache.
		BEGIN
			EXEC dbo.USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET 71090000000;

			EXEC dbo.USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET 71190000000;

			EXEC dbo.USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET 71460000000;

			EXEC dbo.USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET 71300000000;

			EXEC dbo.USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET 71260000000;
		END

		SELECT idfVersion,
			idfsMatrixType AS idfsAggrCaseSection,
			MatrixName,
			datStartDate,
			blnIsActive,
			blnIsDefault,
			CAST(ISNULL(blnIsDefault, 0) AS INT) + CAST(ISNULL(blnIsActive, 0) AS INT) AS intState,
			intRowStatus
		FROM dbo.tlbAggrMatrixVersionHeader
		WHERE (
				@idfMatrix IS NULL
				OR idfsMatrixType = @idfMatrix
				)
		ORDER BY intState DESC,
			datStartDate DESC;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
