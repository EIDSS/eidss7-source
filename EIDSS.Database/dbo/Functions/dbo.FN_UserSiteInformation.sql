
-- =============================================
-- Author:		Manickandan govindarajan
-- Create date: 11/15/2022
-- Description:	Get Userid, SiteId for a given UserName
-- =============================================
CREATE FUNCTION dbo.FN_UserSiteInformation
(
	@UserName AS nvarchar(255)
)
RETURNS 
 @rtetUserSiteInformation TABLE
(
	UserId  bigint,
	SiteId  bigint
)
AS
BEGIN
	insert @rtetUserSiteInformation (UserId,SiteId)
	select tu.idfUserID,tu.idfsSite from AspNetUsers u 
		inner join tstUserTable tu on u.idfUserID = tu.idfUserID
		where upper(u.UserName) = upper(@UserName)
	
	RETURN 
END
