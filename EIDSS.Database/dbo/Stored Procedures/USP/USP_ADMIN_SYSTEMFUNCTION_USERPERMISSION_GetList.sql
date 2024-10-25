

--==============================================================================================================
-- NAME:					[[USP_ADMIN_SYSTEMFUNCTION_USERPERMISSION_GetList]]
-- DESCRIPTION:				Returns a list of Permisson for given user and system function
-- AUTHOR:					Manickandan Govindarajan
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Manickandan Govindarajan			06/11/2021	Initial Release
-- EXEC [USP_ADMIN_SYSTEMFUNCTION_USERPERMISSION_GetList] 'en',-501,10094013

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_SYSTEMFUNCTION_USERPERMISSION_GetList]
	@LanguageId NVARCHAR(50),
	@EmployeeId bigint,
	@SystemFunctionId bigint

AS
BEGIN
	
	BEGIN TRY

	SET NOCOUNT ON;

	SELECT 
		SFA.idfEmployee IdfEmployee,
		SFO.SystemFunctionID SystemFunctionID,
		ISNULL(s.strTextString, SF.strDefault) AS StrSystemFunction,
		SFO.SystemFunctionOperationID as SystemFunctionOperationID,
		ISNULL(so.strTextString, O.strDefault) AS StrSystemFunctionOperation,
		SFA.intRowStatus OperationStatus,
		SFO.intRowStatus AccessStatus
		FROM LkupSystemFunctionToOperation  SFO
		LEFT JOIN LkupRoleSystemFunctionAccess SFA
		on SFA.SystemFunctionID = SFO.SystemFunctionID  and SFA.SystemFunctionOperationID= SFO.SystemFunctionOperationID
		LEFT JOIN dbo.trtBaseReference SF ON SF.idfsBaseReference = SFO.SystemFunctionID
		LEFT JOIN dbo.trtStringNameTranslation AS s ON sf.idfsBaseReference = s.idfsBaseReference AND s.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageId)
		LEFT JOIN dbo.trtBaseReference O ON O.idfsBaseReference = SFO.SystemFunctionOperationID
		LEFT JOIN dbo.trtStringNameTranslation AS so ON o.idfsBaseReference = so.idfsBaseReference AND so.idfsLanguage = dbo.FN_GBL_LanguageCode_Get(@LanguageId)
		where SfA.idfEmployee = @EmployeeId and SFO.SystemFunctionID = @SystemFunctionId and SFO.intRowStatus=0

	END TRY

	BEGIN CATCH
		THROW
	END CATCH
END

