/*******************************************************
NAME						: [USP_CONF_GetSpeciesList_GET]		


Description					: Retreives Entries For List of Species

Author						: Lamont Mitchell

Revision History
		
			Name							Date								Change Detail
			Lamont Mitchell					04/03/19							Initial Created
			Ricky Moss						04/03/20							Add translated value field
*******************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_GetSpeciesList_GET]
	
@idfsBaseReference							BIGINT = NULL,
@intHACode									BIGINT = NULL,
@strLanguageID								VARCHAR(5) = NULL
AS BEGIN

SET NOCOUNT ON;

	BEGIN TRY
			Select t.idfsReference as idfsBaseReference,
			t.strDefault, 
			t.[name] as 'strName',
			t.intOrder
			FROM dbo.FN_GBL_Reference_GETList(@strLanguageID, @idfsBaseReference) t
			INNER JOIN trtSpeciesType tst 
			ON tst.idfsSpeciesType = t.idfsReference
			WHERE t.idfsReferenceType = @idfsBaseReference -- Disease
			AND intHACode IN (SELECT * FROM dbo.FN_GBL_SplitHACode(@intHACode, 510))
			ORDER BY t.intOrder, t.[name] Asc
	END TRY
	BEGIN CATCH
			THROW;
	END CATCH
END
