-- ====================================================================================================
-- Name: FN_REF_LABTESTTODISEASE_GET
-- Description:	Returns a comma separated string of lab test name associated with a disease
--							
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Ricky Moss		01/30/2019  Initial Release
-- Ricky Moss		02/08/2019	Included active clause
-- Ann Xiong		11/07/2022	Replaced comma in lab test name with semicolon to properly disply Lab Tests in the Disease Editor when in Edit mode
-- Mark Wilson		11/16/2022	Modified to select DISTINCT lab test name
--
-- Test Code:
-- SELECT dbo.FN_REF_LABTESTNAMETODISEASE_GET('en',55540680000288) 
-- ===================================================================================================

CREATE FUNCTION [dbo].[FN_REF_LABTESTNAMETODISEASE_GET]
(
	@LangID NVARCHAR(50),
	@idfsDiagnosis BIGINT
)
RETURNS NVARCHAR(4000)
AS
BEGIN
DECLARE @CSV NVARCHAR(4000) = '';

	IF @idfsDiagnosis IS NULL RETURN NULL;
	
	IF @idfsDiagnosis <> 0
	BEGIN
        WITH Results AS        
	    ( 
           SELECT DISTINCT REPLACE(tbr.name, ',', ';') AS strTestName
           FROM trtTestForDisease td
           JOIN dbo.FN_GBL_Reference_List_GET(@LangID, 19000097) tbr ON td.idfsTestName = tbr.idfsReference
           WHERE td.idfsDiagnosis = @idfsDiagnosis AND td.intRowStatus = 0
        )

        SELECT
         @CSV = STRING_AGG(strTestName, ', ')
        FROM results;
	END

	-- Return the result of the function
	RETURN @CSV;

END
