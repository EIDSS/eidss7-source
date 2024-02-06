-- ================================================================================================
-- Name: USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET
--
-- Description: Corrects blnIsDefault for a specific matrix type.  Update is needed to avoid the
-- following:
-- Multiple default matrices are possible because of replication
-- Default matrix can not be defined explicitly by some reason
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
-- Stephen Long    09/03/2020 Initial release for version 7.0.
--
-- Testing Code:
-- EXEC USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET 71260000000
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_AGGREGATE_MATRIX_DEFAULT_SET] @MatrixID AS BIGINT = NULL
AS
DECLARE @DefaultVersionID AS BIGINT;

SELECT TOP 1 @DefaultVersionID = idfVersion
FROM dbo.tlbAggrMatrixVersionHeader
WHERE idfsMatrixType = @MatrixID
	AND intRowStatus = 0
	AND blnIsActive = 1
ORDER BY CAST(ISNULL(blnIsDefault, 0) AS INT) + CAST(ISNULL(blnIsActive, 0) AS INT) DESC,
	datStartDate DESC;

-- Check that the default version exists.
IF NOT @DefaultVersionID IS NULL
BEGIN
	-- Make matrix version default explicitly.
	-- This statement should do nothing if the default version is defined explicitly.
	UPDATE dbo.tlbAggrMatrixVersionHeader
	SET blnIsDefault = 1
	WHERE idfVersion = @DefaultVersionID
		AND ISNULL(blnIsDefault, 0) <> 1;

	-- Clear the blnIsDefault for all versions except the default.
	UPDATE dbo.tlbAggrMatrixVersionHeader
	SET blnIsDefault = 0
	WHERE idfVersion <> @DefaultVersionID
		AND idfsMatrixType = @MatrixID
		AND intRowStatus = 0
		AND blnIsActive = 1
		AND ISNULL(blnIsDefault, 0) <> 0;
END
