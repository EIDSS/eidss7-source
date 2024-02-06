-- ================================================================================================================================================
-- NAME:		USP_ADMIN_DEPARTMENT_SET
-- DESCRIPTION:	Assigns departments to an organization
-- AUTHOR:		Ricky Moss
-- 
-- HISTORY OF CHANGE
-- Name:				Date:		Description:
-- ------------------------------------------------------------------------------------------------------------------------------------------------
-- Ricky Moss			01/07/2019	Initial Release
-- ================================================================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_DEPARTMENTTOORGANIZATION_SET]
(
	@idfOrganization BIGINT
	,@idfsDepartmentName NVARCHAR(500)
	,@userName VARCHAR(50)
)
AS

DECLARE @returnMsg VARCHAR(MAX) = 'Success'
DECLARE @returnCode BIGINT = 0 
DECLARE @DepartmentName BIGINT
DECLARE @idfDepartment BIGINT
DECLARE @SupressSelect table
			( retrunCode int,
			  returnMessage varchar(200)
			)
DECLARE @DepartmentNames TABLE ( idfsDepartment BIGINT)
BEGIN
	BEGIN TRY
		UPDATE tlbDepartment SET intRowStatus = 1 WHERE idfOrganization = @idfOrganization
		INSERT INTO @DepartmentNames SELECT VALUE AS idfsDepartment FROM STRING_SPLIT(@idfsDepartmentName,',')
		WHILE(SELECT COUNT(idfsDepartment) FROM @DepartmentNames) > 0
		BEGIN
			SELECT @DepartmentName = (SELECT TOP 1(idfsDepartment) FROM @DepartmentNames)
			IF EXISTS(SELECT idfDepartment FROM tlbDepartment WHERE idfsDepartmentName = @DepartmentName AND idfOrganization = @idfOrganization)
			BEGIN
				UPDATE tlbDepartment SET intRowStatus = 0, strReservedAttribute = dbo.FN_GBL_DATACHANGE_INFO(@UserName) WHERE idfsDepartmentName = @DepartmentName AND idfOrganization = @idfOrganization
			END
			ELSE
			BEGIN
				INSERT @SupressSelect					
					EXECUTE	dbo.usp_sysGetNewID @idfDepartment OUTPUT;
				INSERT INTO tlbDepartment (idfDepartment, idfsDepartmentName, idfOrganization, strReservedAttribute, intRowStatus) VALUES (@idfDepartment, @DepartmentName, @idfOrganization, dbo.FN_GBL_DATACHANGE_INFO(@userName), 0)
			END
			DELETE FROM @DepartmentNames WHERE idfsDepartment = @DepartmentName
		END
		SELECT @ReturnCode ReturnCode,
			@returnMsg ReturnMessage
	END TRY
	BEGIN CATCH	
		THROW
	END CATCH
END
