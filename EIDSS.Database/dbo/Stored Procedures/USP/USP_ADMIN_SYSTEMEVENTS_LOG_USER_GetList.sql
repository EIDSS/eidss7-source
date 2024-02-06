




-- ================================================================================================
-- NAME						: [USP_ADMIN_SYSTEMEVENTS_LOG_USER_GetList]		
--
-- Description				: Get User list for System Events Log
--
-- Author						: Mani
--
--Revision History

-- Testing code:
--
/*

EXECUTE [dbo].[USP_ADMIN_SYSTEMEVENTS_LOG_USER_GetList] 'en'
	
--*/

-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEMEVENTS_LOG_USER_GetList]
(
	@LanguageID AS NVARCHAR(50)
)
AS

		
BEGIN

	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;

	BEGIN TRY  
	
		SELECT ut.idfUserID as Id,
			ISNULL(abbr.strTextString, br.strDefault) +', ' +  ISNULL(p.strFamilyName, ' ')   +', '+ ISNULL(p.strFirstName, ' ') as UserName
		FROM dbo.AspNetUsers u
		JOIN dbo.tstUserTable ut
			ON ut.idfUserID = u.idfUserID
		join dbo.tlbPerson p
		on p.idfPerson = ut.idfPerson
		Join dbo.tstSite s
			on ut.idfsSite= s.idfsSite
		join  tlbOffice o
			on s.idfOffice = o.idfOffice
		LEFT JOIN dbo.trtBaseReference AS br
		on br.idfsBaseReference = o.idfsOfficeAbbreviation 
		LEFT JOIN dbo.trtStringNameTranslation AS  abbr
			ON abbr.idfsBaseReference = br.idfsBaseReference
				AND abbr.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
				where ut.intRowStatus =0 and p.intRowStatus=0
		order by br.strDefault,  p.strFamilyName,p.strFirstName

		SELECT @ReturnCode,@ReturnMessage;

	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;
END
