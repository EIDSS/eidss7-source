

/**************************************************************************************************
NAME						: [USP_CONF_GetVetDiseaseList_GET]		


Description					: Retreives Entries Vet Disease

Author						: Lamont Mitchell

Revision History
		
			Name							Date		Change Detail
			Lamont Mitchell					04/03/19	Initial Created
			Stephen Long                    10/03/2019  Added using type aggregate.
			Ricky Moss						04/21/2020  Added Translated Value
			Leo Tracchia					07/09/2021	Add OR condition to retrive all Avian and Livestock
**************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_CONF_GetVetDiseaseList_GET] 
	@idfsBaseReference BIGINT = NULL,
	@intHACode BIGINT = NULL,
	@strLanguageID VARCHAR(5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT t.idfsReference as idfsBaseReference,
			t.strDefault,
			t.[name],
			d.strIDC10,
			d.strOIECode,
			t.intHACode	
		FROM dbo.FN_GBL_Reference_GETList('en', 19000019) t
		LEFT JOIN dbo.trtDiagnosis d
			ON t.idfsReference = d.idfsDiagnosis
		WHERE (32 IN (
						SELECT *
						FROM dbo.FN_GBL_SplitHACode(t.intHACode, 510)
						)
			OR
				64 IN (
						SELECT *
						FROM dbo.FN_GBL_SplitHACode(t.intHACode, 510)
						)
			)
			AND d.idfsUsingType = 10020002 --aggregate case
		ORDER BY t.intOrder, t.[name];

	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
