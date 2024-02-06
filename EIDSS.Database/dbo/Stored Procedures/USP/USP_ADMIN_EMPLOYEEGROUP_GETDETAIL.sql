-- =================================================================================================================
-- NAME:				USP_ADMIN_EMPLOYEEGROUP_GETDETAIL
-- DESCRIPTION:			Retrieves a role given a role identifier and language
-- AUTHOR:				Ricky Moss
-- 
-- HISTORY OF CHANGES:	
-- NAME:			DATE:			DESCRIPTION OF CHANGE
-- -----------------------------------------------------------------------------------------------------------------
-- Ricky Moss		12/02/2019		Initial Release
-- Ann Xiong		03/01/2023		Fixed the issue of wrong National Name returned
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_GETDETAIL -499, 'en', NULL
-- =================================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_GETDETAIL]
(
	@idfEmployeeGroup BIGINT,
	@langId NVARCHAR(50),
	@user NVARCHAR(100)
)
AS
BEGIN
	BEGIN TRY
		SELECT eg.idfEmployeeGroup, eg.idfsEmployeeGroupName, egbr.strDefault, eg.strName as strName, eg.strDescription FROM tlbEmployeeGroup eg
		JOIN FN_GBL_Reference_GETList(@langId, 19000022) egbr
		ON eg.idfsEmployeeGroupName = egbr.idfsReference
		WHERE idfEmployeeGroup = @idfEmployeeGroup AND intRowStatus = 0
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END

