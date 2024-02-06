/***********************************************************************************************************************
NAME						: [USP_CONF_GetProphylacticMeasures_GET]		


Description					: Retreives Entries For Prophylactic Measures

Author						: Lamont Mitchell

Revision History
		
Name						Date				Change Detail
Lamont Mitchell				04/03/19			Initial Created
Leo Tracchia				08/11/2021			modified to add sorting and omit deleted records		
***********************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_GetProphylacticMeasures_GET]
	
@idfsBaseReference							BIGINT = NULL,
@intHACode									BIGINT = NULL,
@strLanguageID								VARCHAR(5) = NULL
AS BEGIN

SET NOCOUNT ON;

	BEGIN TRY

			Select t.idfsBaseReference,t.strDefault,p.strActionCode
			FROM trtBaseReference t
			LEFT JOIN trtProphilacticAction p ON p.idfsProphilacticAction = t.idfsBaseReference
			INNER JOIN FN_GBL_Reference_GETList(@strLanguageID, 19000074) pabr ON p.idfsProphilacticAction = pabr.idfsReference and p.intRowStatus = 0				
			WHERE t.idfsReferenceType = @idfsBaseReference -- Disease				
			AND @intHACode in  (SELECT value from String_Split([dbo].[FN_GBL_HACode_ToCSV]('en',t.intHaCode),',')) 
			AND t.intRowStatus = 0
			ORDER BY t.intOrder, pabr.[name] Asc

	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END


