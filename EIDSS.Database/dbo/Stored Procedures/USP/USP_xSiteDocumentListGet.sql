-- =============================================
-- Author:		Steven Verner
-- Create date: 06.10.2020
-- Description:	Retrieves the xSite Document Map
-- =============================================
CREATE PROCEDURE [dbo].[USP_xSiteDocumentListGet] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT EIDSSMenuId, xSiteGUID, LanguageCode, o.PageLink
	FROM tlbxSiteDocumentMap m
	JOIN LkupEIDSSAppObject o on o.AppObjectNameID = m.EIDSSMenuId
	ORDER BY LanguageCode, xSiteGUID
END
