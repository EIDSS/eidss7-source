
-- =============================================
-- Author:		Manickandan govindarajan
-- Create date: 11/15/2022
-- Description:	Get Userid, SiteId for a given UserName
-- =============================================
CREATE FUNCTION [dbo].[FN_UserSiteInformation]
(
	@UserName AS nvarchar(255)
)
RETURNS 
 @rtetUserSiteInformation TABLE
(
	UserId		bigint,
	SiteId		bigint,
	PersonId	bigint
)
AS
BEGIN
	insert	@rtetUserSiteInformation (UserId, SiteId, PersonId)
	select		tu.idfUserID, tu.idfsSite, tu.idfPerson
	from		dbo.AspNetUsers u 
	inner join	dbo.tstUserTable tu
	on			u.idfUserID = tu.idfUserID
	where		u.UserName = @UserName collate Cyrillic_General_CI_AS
				and tu.intRowStatus = 0
	
	RETURN 
END
