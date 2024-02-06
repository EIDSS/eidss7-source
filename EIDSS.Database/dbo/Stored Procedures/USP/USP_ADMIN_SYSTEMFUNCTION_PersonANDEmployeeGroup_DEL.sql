-- ================================================================================================
-- Name: [USP_ADMIN_SYSTEMFUNCTION_PersonANDEmployeeGroup_DEL]
--
-- Description:	Creates and/or removes at relationship between a role, system function, and 
-- operation.
--                      
-- Author: Ricky Moss
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Manickandan Govindarajan 06/24/2011 - set intRowStatusForSystemFunction = 1, intRowStatus=1  for the @UserId and @SystemFunctionID

-- exec USP_ADMIN_SYSTEMFUNCTION_PersonANDEmployeeGroup_DEL 10094517,-513
-- ================================================================================================
CREATE  PROCEDURE [dbo].[USP_ADMIN_SYSTEMFUNCTION_PersonANDEmployeeGroup_DEL]
(
	@SystemFunctionID BIGINT ,
	@UserId BIGINT
)
AS

DECLARE @returnCode INT = 0
DECLARE @returnMsg NVARCHAR(MAX) = 'SUCCESS'
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		UPDATE LkupRoleSystemFunctionAccess set intRowStatusForSystemFunction = 1, intRowStatus=1  where idfEmployee=@UserId  and  SystemFunctionID = @SystemFunctionID 

		IF @@TRANCOUNT > 0
			COMMIT


		SELECT @returnCode 'ReturnCode',@returnMsg 'ReturnMessage'

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK
		END;

		THROW
	END CATCH
END
