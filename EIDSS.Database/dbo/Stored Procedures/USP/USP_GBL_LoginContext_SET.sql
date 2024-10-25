
-- =============================================
-- Author:		Steven Verner
-- History:
-- Create date: 12/21/2021
-- 02/28/2022	Ensured that eventid is nulled out when called.  This SP is called during the logon process.

-- Description:	Sets the user's login context by adding a row into the tstLocalConnectionContext table.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GBL_LoginContext_SET]
	 @UserID as bigint 
	,@userSite bigint 
	,@blnDiagnosisDenied  bit
	,@blnSiteDenied  bit
AS
	DECLARE @idfsDataAuditEvent BIGINT
	DECLARE @SupressSELECT TABLE
    (
		retrunCode INT,
		returnMessage VARCHAR(200)
    )

	IF Exists(SELECT * FROM tstLocalConnectionContext WHERE idfUserID = @UserID)
		UPDATE tstLocalConnectionContext      
		SET  
		  idfsSite=@userSite,      
		  datLastUsed=GETUTCDATE(),
		  blnDiagnosisDenied =  @blnDiagnosisDenied,
		  blnSiteDenied = @blnSiteDenied,
		  idfDataAuditEvent = NULL,
		  idfEventID = NULL
		WHERE idfUserID = @UserID
	ELSE
		INSERT INTO tstLocalConnectionContext(
			strConnectionContext,
			idfUserID,
			idfsSite,
			datLastUsed,
			blnDiagnosisDenied,
			blnSiteDenied
			)
		VALUES(
			NEWID(),
			@UserID,
			@userSite,
			GETUTCDATE(),
			@blnDiagnosisDenied,
			@blnSiteDenied
			)


RETURN 0

