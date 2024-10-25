
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Name 				: USP_GBL_BaseReferenceToCP_SET
-- Description			: Insert/Update Base Reference To Customization Pkg 
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson    10-Nov-2017   Convert EIDSS 6 to EIDSS 7 standards and 
--                              converted table name to USP_GBL_BaseReferenceToCP_SET
--                              call
-- Mark Wilson    04-Oct-2021   Added @User 
--
-- Testing code:

/*
--Example of a call of procedure:
DECLARE @idfsReference bigint
DECLARE @idfCustomizationPackage bigint
DECLARE @User NVARCHAR(100)


EXECUTE USP_GBL_BaseReferenceToCP_SET
   @idfsReference,
   @idfCustomizationPackage,
   @User

*/

CREATE PROCEDURE [dbo].[USP_GBL_BaseReferenceToCP_SET] 
(
	@idfsReference BIGINT,
	@idfCustomizationPackage BIGINT,
	@User NVARCHAR(100) = ''
)

AS
BEGIN
	IF NOT EXISTS (SELECT * FROM dbo.trtBaseReferenceToCP WHERE idfsBaseReference = @idfsReference AND idfCustomizationPackage = @idfCustomizationPackage)
		INSERT INTO trtBaseReferenceToCP
		(
			idfsBaseReference,
			idfCustomizationPackage,
			SourceSystemNameID,
			SourceSystemKeyValue,
			AuditCreateUser,
			AuditCreateDTM,
			AuditUpdateUser,
			AuditUpdateDTM
		)
		VALUES (
			@idfsReference,
			@idfCustomizationPackage,
			10519001, 
			N'[{"idfsBaseReference":' + CAST(@idfsReference AS NVARCHAR(300)) + '}]',
			@User,
			GETDATE(), 
			@User,
			GETDATE()
		)

END

