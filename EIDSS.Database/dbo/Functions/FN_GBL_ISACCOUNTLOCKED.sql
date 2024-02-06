
/*
--*************************************************************
-- Name 				: FN_GBL_ISACCOUNTLOCKED
-- Description			: Funtion to return if account is locked
--							Returns 0 if not locked
							Returns 1 If locked
-- Author               : Mandar Kulkarni
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
-- SELECT  dbo.FN_GBL_ISACCOUNTLOCKED(58397190000001) 
*/
--*************************************************************
CREATE   FUNCTION [dbo].[FN_GBL_ISACCOUNTLOCKED]
(
	@idfUserId BIGINT
)
RETURNS INT
AS
BEGIN

	DECLARE @blnAccountLocked INT

	IF EXISTS (SELECT @idfUserId FROM dbo.AspNetUsers u
				WHERE idfUserId = @idfUserId
				AND u.LockoutEnabled = 1 
				AND u.LockoutEnd IS NOT NULL
				)
		SET @blnAccountLocked = 1
	ELSE
		SET @blnAccountLocked = 2
	
	RETURN @blnAccountLocked

END








