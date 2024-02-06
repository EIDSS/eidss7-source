
-- ================================================================================================
-- Name: USP_ADMIN_FF_Sections_GET
-- Description: Returns list of sections
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Doug Albanese	05/17/2021 Reorganized the gathering of sections, depending on what is passed.
-- Doug Albanese	07/30/2021	Temp language corection until I can change it globally
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Sections_GET]
(
	@LangID NVARCHAR(50) = NULL 
	,@idfsFormType BIGINT = NULL
	,@idfsSection BIGINT = NULL
	,@idfsParentSection BIGINT = NULL		
)	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE
		@langid_int BIGINT, 
		@returnCode BIGINT,
		@returnMsg  NVARCHAR(MAX) 

	BEGIN TRY
	
		IF (@LangID IS NULL)
			SET @LangID = 'en-us';
	
		DECLARE @SearchType VARCHAR(50)

		IF (@idfsFormType IS NOT NULL)
			BEGIN
				SET @SearchType = 'FormType'
			END

		IF (@idfsSection IS NOT NULL)
			BEGIN
				SET @SearchType = 'Section'
			END

		IF (@idfsParentSection IS NOT NULL)
			BEGIN
				SET @SearchType = 'ParentSection'
			END

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);
	
	
		SELECT S.[idfsSection]
			   ,S.[idfsParentSection]
			   ,S.[idfsFormType]     
			   ,S.[rowguid]
			   ,S.[intRowStatus]
			   ,B.[strDefault] AS [DefaultName]	
			   ,ISNULL(SNT.[strTextString], B.[strDefault]) AS [NationalName]	 
			   ,CASE WHEN COUNT(P.[idfsParameter]) > 0
				THEN 1
				ELSE 0
				END AS [HasParameters]
			   ,CASE WHEN COUNT(S2.[idfsSection]) > 0
				THEN 1
				ELSE 0
				END AS [HasNestedSections]	
			   ,S.blnGrid
			   ,S.blnFixedRowSet
			   ,S.intOrder
			   ,@LangID AS [langid]
			   ,S.idfsMatrixType
		FROM [dbo].[ffSection] S
		INNER JOIN dbo.trtBaseReference B
		ON B.[idfsBaseReference] = S.[idfsSection]
		   AND B.[intRowStatus] = 0  
		LEFT JOIN dbo.ffParameter P
		ON P.idfsSection = S.[idfsSection]
		   AND P.[intRowStatus] = 0
		LEFT JOIN dbo.ffSection S2
		ON S.[idfsSection] = S2.[idfsParentSection]
		   AND S2.[intRowStatus] = 0
		LEFT JOIN dbo.trtStringNameTranslation SNT
		ON SNT.[idfsBaseReference] = S.[idfsSection]
		   AND SNT.idfsLanguage = @langid_int
		   AND SNT.[intRowStatus] = 0
		WHERE (
				(@SearchType = 'FormType' AND S.idfsFormType = @idfsFormType AND S.idfsParentSection IS NULL)
				OR
				(@SearchType = 'Section' AND S.idfsSection = @idfsSection)
				OR
				(@SearchType = 'ParentSection' AND S.idfsParentSection = @idfsParentSection)
			)
			  AND S.[intRowStatus] = 0
		GROUP BY S.[idfsSection]
				 ,S.[idfsParentSection]
				 ,S.[idfsFormType]     
				 ,S.[rowguid]
				 ,S.[intRowStatus]
				 ,B.[strDefault]
				 ,SNT.[strTextString]	  
				 ,S.blnGrid
				 ,S.blnFixedRowSet
				 ,S.intOrder
				 ,S.idfsMatrixType
		ORDER BY [NationalName], S.[intOrder]

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
