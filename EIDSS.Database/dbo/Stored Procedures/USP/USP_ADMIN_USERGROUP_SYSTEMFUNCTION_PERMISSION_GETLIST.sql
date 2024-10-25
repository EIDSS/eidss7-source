

-- ===============================================================================================================
-- NAME:					[USP_ADMIN_USERGROUP_SYSTEMFUNCTION_PERMISSION_GETLIST]
-- DESCRIPTION:				Returns a list of Permission assoicated with SystemFunction
-- AUTHOR:					Manickandan Govindarajan
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Manickandan Govindarajan			12/24/2019	Initial Release
-- Manickandan Govindarajan			01/06/2021	Addded trtStringNameTranslation table for translation
-- Mark Wilson						04/27/2022	Updated to order by intOrder

/*

 EXEC USP_ADMIN_USERGROUP_SYSTEMFUNCTION_PERMISSION_GETLIST 'en-US'

*/
-- ===============================================================================================================
CREATE   PROCEDURE [dbo].[USP_ADMIN_USERGROUP_SYSTEMFUNCTION_PERMISSION_GETLIST] 
(
	@langId NVARCHAR(50),
	@SystemFunctionId BIGINT = NULL
)

AS
BEGIN
	
	BEGIN TRY

		SET NOCOUNT ON;

		SELECT 
		SFO.SystemFunctionID,
		sf.name AS strSystemFunction,
		SFO.SystemFunctionOperationID,
		o.name AS strSystemFunctionOperation,
		SFO.intRowStatus
	
		FROM dbo.LkupSystemFunctionToOperation SFO 
		INNER JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000094) sf ON sfo.SystemFunctionID = sf.idfsReference
		LEFT JOIN dbo.FN_GBL_Reference_GETList(@langId, 19000059) AS o
						ON o.idfsReference = sfo.SystemFunctionOperationID
						WHERE  (
				SFO.SystemFunctionID = @SystemFunctionId
				OR @SystemFunctionId IS NULL
				)
		ORDER BY sf.intOrder

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
