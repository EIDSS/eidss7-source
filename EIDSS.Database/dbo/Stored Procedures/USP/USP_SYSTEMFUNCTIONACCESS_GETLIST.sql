-- ===============================================================================================================
-- Name: USP_SYSTEMFUNCTIONACCESS_GETLIST
-- Description: Add or reactivates a relationship between an employee and employee group
-- Author: Ricky Moss
--
-- History of changes
--
-- Name					Date			Change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			11/25/2019		Initial Release
--
-- EXEC USP_SYSTEMFUNCTIONACCESS_GETLIST 'en'
--
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_SYSTEMFUNCTIONACCESS_GETLIST]
(
		@strGroupName NVARCHAR(50),
		@strDescription NVARCHAR(500),
		@langId NVARCHAR(50),
		@user NVARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		SELECT fabr.idfsReference, fabr.strDefault, fabr.name as strName, LongName, intOrder FROM dbo.FN_GBL_Reference_GETList(@langId, 19000094) fabr
		WHERE ISNULL([name],'') LIKE '%' +  IIF(@strGroupName IS NULL, @strGroupName, ISNULL([name],'')) +'%' AND
			ISNULL([LongName],'') LIKE '%' + IIF(@strDescription IS NULL, @strDescription, ISNULL([name], '')) + '%'
		--SELECT * FROM LkupRoleSystemFunctionAccess
		--SELECT * FROM FN_GBL_Reference_GETList('en', 19000060)
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
