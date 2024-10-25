--=================================================================================================
-- Author: Phil Shaffer
--
-- Description:	Takes an HACode and breaks it down into a CSV with the names of the bitmasks that 
-- make it up.
--
-- 1) If @HACode = NULL returns NULL
-- 2) If @HACode = 0 returns corresponding entry from [trtHACodeList] table (i.e "None")
-- 3) A string of [intHACode] values that matched a bitwise AND with @HACode (e.g. 34 => "Human, 
-- Livestock").
-- 4) Names of [intHACode] values returned in the string are in ascending order of the [intHACode] 
-- values.
-- 5) This implementation will only execute on SQL Server 2017 or greater due to use of function 
-- "STRING_AGG".
-- 6) If passed an invalid @HACode that doesn't match any of the bitmasks, return the value of none 
-- (i.e. "None").
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Philip Shaffer	2018/09/27 Created for EIDSS 7.0.
-- Ricky Moss		2018/09/30 Removed 510 and 0 from returned value
-- Stephen Long     2020/05/19 Added space between comma.
-- Doug Albanese	03/21/2023 Swapped out function with FN_GBL_LanguageCode_GET to get correct translation code.
--
-- Test Code:
-- declare @LangID nvarchar(50) = N'en';
-- declare @HACode int = -1; -- any bitwise OR'd values from table [trtHACodeList]. Value -1 will 
-- match all. Value NULL will return NULL.
-- select dbo.FN_GBL_HACodeNames_ToCSV(@LangID, @HACode);
--=================================================================================================
CREATE FUNCTION [dbo].[FN_GBL_HACodeNames_ToCSV] (
	@LangID NVARCHAR(50),
	@HACode BIGINT
	)
RETURNS NVARCHAR(4000)
AS
BEGIN
	DECLARE @CSV NVARCHAR(4000) = N'',
			@HACodeMax BIGINT = 510,
			@LanguageCode BIGINT = dbo.FN_GBL_LanguageCode_GET(@LangID);

	-- if passed a null, we return a null result
	IF (@HACode IS NULL)
		RETURN NULL;

	SET @CSV = 
	STUFF(
		CAST(	(	SELECT N',' + COALESCE(snt.[strTextString], br.[strDefault], N'')
					FROM [dbo].[trtHACodeList] AS hcl
					INNER JOIN [dbo].[trtBaseReference] AS br
						ON hcl.[idfsCodeName] = br.[idfsBaseReference]
					LEFT OUTER JOIN [dbo].[trtStringNameTranslation] AS snt
						ON hcl.[idfsCodeName] = snt.[idfsBaseReference]
							AND snt.[idfsLanguage] = @LanguageCode
					WHERE	(	(	(	hcl.[intHACode] <> 0
										AND hcl.intHACode <> @HACodeMax
									)
									AND ((@HACode & hcl.[intHACode]) = hcl.[intHACode])
								)
								OR	(	hcl.[intHACode] = 0
										and not exists
												(	select	1 
													from	[dbo].[trtHACodeList] AS hcl_other 
													where	((hcl_other.[intHACode] & @HACode) = hcl_other.[intHACode])
															and hcl_other.intRowStatus = 0
															and hcl_other.[intHACode] <> 0 
															and hcl_other.[intHACode] <> @HACodeMax
												)
									)
							)
							AND hcl.intRowStatus = 0
							AND @HACode IS NOT NULL
					ORDER BY hcl.[intHACode] ASC
					FOR XML PATH('')
								)
								AS NVARCHAR(4000)
			), 1, 1, N'')
	
	RETURN @CSV;
END
