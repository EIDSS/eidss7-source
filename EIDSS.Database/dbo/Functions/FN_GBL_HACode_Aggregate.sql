CREATE FUNCTION [dbo].[FN_GBL_HACode_Aggregate]
(
	@idfsLanguage	BIGINT,
	@HACode			BIGINT
)
RETURNS TABLE
AS

	RETURN(
		SELECT	STRING_AGG(cast(hcl.intHACode AS nvarchar(4)), N',') AS HACodeIds,
				STRING_AGG(COALESCE(snt.[strTextString], br.[strDefault], N''), N',') AS HACodeNames
		FROM		[dbo].[trtHACodeList] AS hcl
		INNER JOIN	[dbo].[trtBaseReference] AS br
			ON hcl.[idfsCodeName] = br.[idfsBaseReference]
		LEFT JOIN	[dbo].[trtStringNameTranslation] AS snt
			ON hcl.[idfsCodeName] = snt.[idfsBaseReference]
				AND snt.[idfsLanguage] = @idfsLanguage
		WHERE		(	(	(	hcl.[intHACode] <> 0
								AND hcl.intHACode <> 510
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
													and hcl_other.[intHACode] <> 510
										)
							)
					)
					AND hcl.intRowStatus = 0
					AND @HACode IS NOT NULL
		)



