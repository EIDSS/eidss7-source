-- ===============================================================================================================
-- NAME:					[USP_ADMIN_EMPLOYEEGROUP_BYUSER_GetDetail]
-- DESCRIPTION:				Returns a list of Permission assoicated with SystemFunction
-- AUTHOR:					Manickandan Govindarajan
--
-- HISTORY OF CHANGES:
-- Name:				Date:		Description of change
-- ---------------------------------------------------------------------------------------------------------------
-- Manickandan Govindarajan			12/24/2019	Initial Release
--
-- EXEC [USP_ADMIN_EMPLOYEEGROUP_BYUSER_GetDetail]  12,'en'

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEEGROUP_BYUSER_GetDetail] 
(
	@idfUserId BIGINT
)

AS
BEGIN
	
	BEGIN TRY

		SET NOCOUNT ON;

		select eg.idfEmployeeGroup,eg.idfsEmployeeGroupName,eg.strName from AspNetUsers a
		inner join tstUserTable u
			on a.idfUserID = u.idfUserID
		inner join tlbemployee e
			on u.idfPerson = e.idfEmployee
		inner join tlbEmployeeGroupMember egm
			on e.idfEmployee = egm.idfEmployee
		inner join tlbEmployeeGroup eg 
			on eg.idfEmployeeGroup= egm.idfEmployeeGroup
			where a.idfUserID=@idfUserId
	
	END TRY

	BEGIN CATCH
		THROW
	END CATCH
END
