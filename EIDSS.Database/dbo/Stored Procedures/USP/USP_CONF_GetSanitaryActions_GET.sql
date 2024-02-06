/***********************************************************************************************************************
NAME						: [USP_CONF_GetSanitaryActions_GET]		


Description					: Retreives Entries For Sanitary Actions

Author						: Lamont Mitchell

Revision History:
		
Name						Date				Change Detail
Lamont Mitchell				04/03/19			Initial Created
Leo Tracchia				08/10/2021			modified to add sorting and omit deleted records		
Leo Tracchia				08/26/2021			modified to return national value
***********************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_GetSanitaryActions_GET]
	
@idfsBaseReference							BIGINT = NULL,
@intHACode									BIGINT = NULL,
@strLanguageID								VARCHAR(5) = NULL
AS BEGIN

SET NOCOUNT ON;

	BEGIN TRY

			Select t.idfsBaseReference,t.strDefault,s.strActionCode, sabr.[name]  as 'StrName'
			FROM trtBaseReference t
			LEFT JOIN trtSanitaryAction s ON s.idfsSanitaryAction = t.idfsBaseReference				
			INNER JOIN FN_GBL_Reference_GETList(@strLanguageID, 19000079) sabr ON s.idfsSanitaryAction = sabr.idfsReference and s.intRowStatus = 0				
			WHERE t.idfsReferenceType = @idfsBaseReference -- Disease
			AND @intHACode in  (SELECT value from String_Split([dbo].[FN_GBL_HACode_ToCSV]('en',t.intHaCode),','))
			AND t.intRowStatus = 0 			
			ORDER BY t.intOrder,sabr.[name] Asc

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END


