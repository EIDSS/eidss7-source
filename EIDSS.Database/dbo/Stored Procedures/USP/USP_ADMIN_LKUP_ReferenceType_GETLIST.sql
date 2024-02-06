

--*********************
-- Name 				: USP_ADMIN_LKUP_ReferenceType_GETLIST
-- Description			: Get Reference Type Lookup values
--          
-- Author               : Mark Wilson
-- Updated original code from USP_ADMIN_LKUP_BASEREFEDITOR_GETLIST
-- to filter based on bitwise & 4 on intStandard column
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
/*
	EXECUTE USP_ADMIN_LKUP_ReferenceType_GETLIST 'en'
	EXECUTE USP_ADMIN_LKUP_ReferenceType_GETLIST 'ka'

*/
--*********************

CREATE  PROCEDURE [dbo].[USP_ADMIN_LKUP_ReferenceType_GETLIST] 
(
 @LangId	NVARCHAR(20) = 'en'
)
AS 

	DECLARE @returnCode INT = 0;
	DECLARE @returnMsg  NVARCHAR(MAX) = 'SUCCESS'

	BEGIN TRY  	

		SELECT		RT.strReferenceTypeName, 
					TR.[name],
					RT.idfsReferenceType, 
					19000076, -- Reference Types
					BR.blnSystem

		FROM dbo.trtReferenceType RT
		LEFT JOIN dbo.trtBaseReference BR ON BR.idfsBaseReference = RT.idfsReferenceType AND BR.intRowStatus = 0
		INNER JOIN	dbo.FN_GBL_ReferenceRepair(@LangId, 19000076) TR ON	TR.idfsReference = RT.idfsReferenceType
		WHERE BR.idfsReferenceType = 19000076 -- Reference Types
--		AND (RT.intStandard & 4) <> 0 
		AND RT.intRowStatus = 0

		ORDER BY	RT.strReferenceTypeName
			
		SELECT @returnCode, @returnMsg

	END TRY 
	 
	BEGIN CATCH 

		BEGIN
			SET @returnCode = ERROR_NUMBER()
			SET @returnMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()

			SELECT @returnCode, @returnMsg
		END

	END CATCH;
