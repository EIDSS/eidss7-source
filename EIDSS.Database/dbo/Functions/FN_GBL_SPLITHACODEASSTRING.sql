
--*************************************************************
-- Name 				: FN_GBL_SPLITHACODEASSTRING
-- Description			: The function splits the inTHACode passed in as a parameter returns a string
--          
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
-- SELECT [dbo].[FN_GBL_SPLITHACODEASSTRING] (130,510)
--*************************************************************
CREATE FUNCTION [dbo].[FN_GBL_SPLITHACODEASSTRING]
	(
	 @HACode		BIGINT
	,@HACodeMax		BIGINT = 510
	)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE	@returnString VARCHAR(200) = STUFF(ISNULL(
	CAST(	(
				SELECT	N',' + cast(intHACode AS nvarchar(4))
				FROM 	trtHACodeList 
				WHERE	intRowStatus = 0
				AND		intHACode & @HACodeMax > 0
				AND 	intHACode & ISNULL(@HACode, @HACodeMax) > 0
				AND		intHACode <> @HACodeMax
				FOR XML PATH('')
			)
			AS VARCHAR(200)
		), N','), 1, 1, N'')
	RETURN @returnString
END
