
--*************************************************************
-- Name 				: FN_GBL_RemoveSpecialChars
-- Description			: The function removes and special characters
--						: that might impact sorting
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- 

/*
SELECT 
	strDefault

FROM dbo.trtBaseReference
WHERE idfsReferenceType = 19000094
AND intRowStatus = 0
ORDER BY dbo.FN_GBL_RemoveSpecialChars(strDefault)

*/
--*************************************************************
CREATE FUNCTION [dbo].[FN_GBL_RemoveSpecialChars]
(
	@s VARCHAR(256)
) 

RETURNS VARCHAR(256)
   WITH SCHEMABINDING
BEGIN
   IF @s IS NULL
      RETURN NULL
   DECLARE @s2 VARCHAR(256)
   SET @s2 = ''
   DECLARE @l INT
   SET @l = LEN(@s)
   DECLARE @p INT

   SET @p = 1

   WHILE @p <= @l BEGIN
      DECLARE @c INT
      SET @c = ASCII(SUBSTRING(@s, @p, 1))
      IF @c BETWEEN 48 AND 57 OR @c BETWEEN 65 AND 90 OR @c BETWEEN 97 AND 122
         SET @s2 = @s2 + CHAR(@c)
      SET @p = @p + 1
      END
   IF LEN(@s2) = 0
      RETURN NULL
   RETURN @s2
END

