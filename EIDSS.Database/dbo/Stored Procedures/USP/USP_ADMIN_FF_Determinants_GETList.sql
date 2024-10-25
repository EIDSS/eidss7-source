
-- ================================================================================================
-- Name: USP_ADMIN_FF_Determinants_GETList
-- Description: Retrieves the list of Determinants 
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Doug Albanese   03-27-2020 Initial release for new API.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Determinants_GETList] (
	@LangID NVARCHAR(50) = NULL
	,@idfsFormType BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@LangID IS NULL)
		SET @LangID = 'en';

	DECLARE @langid_int BIGINT
		,@returnCode BIGINT
		,@returnMsg NVARCHAR(MAX)

	BEGIN TRY
		BEGIN TRANSACTION;

		--Leaving this for future use, if needed.
		SET @idfsFormType = CASE @idfsFormType
			WHEN 10034501 THEN 10034011
			WHEN 10034502 THEN 10034015
			WHEN 10034503 THEN 10034007
			WHEN 10034504 THEN 10034011
			WHEN 10034505 THEN 10034014
			WHEN 10034506 THEN 10034011
			WHEN 10034507 THEN 10034011
			WHEN 10034508 THEN 10034011
			WHEN 10034509 THEN 10034011
		END

		SELECT a.idfDeterminantValue
			,c.strDefault
			,dv.name
		FROM ffDeterminantValue a
		LEFT JOIN ffFormTemplate ft ON ft.idfsFormTemplate = a.idfsFormTemplate
		INNER JOIN trtBaseReference b ON b.idfsBaseReference = a.idfsFormTemplate
			AND b.intRowStatus = 0
		INNER JOIN trtBaseReference c ON c.idfsBaseReference = a.idfsBaseReference
			AND c.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langID, 19000019) dv ON dv.idfsReference = a.idfsBaseReference
		WHERE ft.idfsFormType = @idfsFormType
		ORDER BY c.strDefault

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
END
