
--=============================================================================================== 
-- Name:  USP_CONF_UNIQUENUMBERINGSCHEMA_GETDETAIL
-- Description: Returns a unique numbering schema given an identifier and language
-- Author: Ricky Moss
--
-- History of Change
-- Name:					Date:			Description: 
-- Ricky Moss				8/26/2019		Initial Release
-- Ricky Moss				9/12/2019		Added blnUsePrefix, blnUseYear, blnUseAlphaNumericValue, blnUseSite
--
-- exec USP_CONF_UNIQUENUMBERINGSCHEMA_GETDETAIL 10057002, 'en'
--=============================================================================================== 
CREATE PROCEDURE [dbo].[USP_CONF_UNIQUENUMBERINGSCHEMA_GETDETAIL]
(
	@idfsNumberName BIGINT,
	@langId NVARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		SELECT 
			n.idfsNumberName, 
			r.strDefault, 
			r.[name] AS strName, 
			n.strPrefix, 
			n.intNumberValue, 
			n.strSuffix, 
			n.blnUsePrefix, 
			n.blnUseYear, 
			n.blnUseAlphaNumericValue, 
			n.blnUseSiteID  

		FROM dbo.tstNextNumbers n
		JOIN dbo.FN_GBL_Reference_GETList(@langId,19000057) r ON n.idfsNumberName = r.idfsReference
		WHERE n.idfsNumberName = @idfsNumberName
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
