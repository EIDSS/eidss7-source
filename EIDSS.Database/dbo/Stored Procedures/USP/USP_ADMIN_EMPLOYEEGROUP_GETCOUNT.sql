SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Name: USP_ADMIN_EMPLOYEEGROUP_GETCOUNT
-- Description: 
-- Author: Ricky Moss
--
-- History of changes
--
-- Name					Date			Change
-- ---------------------------------------------------------------------------------------------------------------
-- Ricky Moss			11/25/2019		Initial Release
-- Ricky Moss			12/03/2019		Added Pagination
-- Olga Mirnaya			11/08/2023		Modified FN_GBL_Reference_GETList to FN_GBL_ReferenceRepair, added eg.intRowStatus =0 and egbr.intRowStatus=0 and eg.idfsEmployeeGroupName != -506 and eg.idfEmployeeGroup != -506 and eg.idfEmployeeGroup != -1
--
-- EXEC USP_ADMIN_EMPLOYEEGROUP_GETCOUNT null, 'l', 'en', NULL
-- EXEC USP_ADMIN_EMPLOYEEGROUP_GETCOUNT 'La', null, 'ru', NULL
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_GETCOUNT]
(
		@strName NVARCHAR(500),
		@strDescription NVARCHAR(1000),
		@langId NVARCHAR(50),
		@user NVARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		SELECT COUNT(idfEmployeeGroup) AS EmployeeGroupCount FROM tlbEmployeeGroup eg
		JOIN FN_GBL_ReferenceRepair(@langId, 19000022) egbr
		ON eg.idfsEmployeeGroupName = egbr.idfsReference
		WHERE ISNULL(strName, '') LIKE IIF(@strName IS NOT NULL, '%' + @strName + '%', ISNULL(strName,'')) AND
			ISNULL(strDescription, '') LIKE IIF(@strDescription IS NOT NULL, '%' + @strDescription + '%', ISNULL(strDescription,''))
		AND eg.intRowStatus =0 and egbr.intRowStatus=0 and eg.idfsEmployeeGroupName != -506 and eg.idfEmployeeGroup != -506 and eg.idfEmployeeGroup != -1

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
