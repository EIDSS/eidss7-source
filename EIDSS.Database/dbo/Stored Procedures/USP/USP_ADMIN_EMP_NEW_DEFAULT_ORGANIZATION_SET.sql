
-- ================================================================================================
-- Name: USP_ADMIN_EMP_NEW_DEFAULT_ORGANIZATION_SET		
-- 
-- Description: Set the the isDefault flag of the new default organization to true, set the the isDefault flag of the old default organization to false, 
--              and update the idfUserID column in the ASPNetUsers table to ensure that the correct idfUserID Is associated with the logon.
--
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong        09/14/2020 	Initial release.
-- Steven Verner	07/29/2020  Added functionality to update the tlbPerson's Institution when the default changes in the EmployeeToInstitution table.
-- Minal Shah		09/08/2021  Removed funcionality to update tlbperson for new default org as tlperson has multiple entry 
-- Testing Code:
-- EXEC USP_ADMIN_EMP_NEW_DEFAULT_ORGANIZATION_SET 155, 156
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_NEW_DEFAULT_ORGANIZATION_SET]
( 
	@idfUserID BIGINT,
	@idfNewUserID BIGINT
)
AS
BEGIN
	DECLARE @returnMsg	VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode	BIGINT = 0;
	DECLARE @newDefaultOrg BIGINT 

	BEGIN TRY  
	BEGIN TRANSACTION

		DECLARE	@aspNetUserId NVARCHAR(128);

		SELECT	 @aspNetUserId = Id
		FROM	dbo.AspNetUsers
		WHERE	idfUserID  = @idfUserID

		UPDATE	[dbo].[EmployeeToInstitution]
		SET		IsDefault = 0
		WHERE	idfUserId = @idfUserID and aspNetUserId = @aspNetUserId

		UPDATE	[dbo].[EmployeeToInstitution]
		SET		IsDefault = 1
		WHERE	idfUserId = @idfNewUserID and aspNetUserId = @aspNetUserId
		
		-- Select new default org to update tlbPerson table...
		SELECT @newDefaultOrg = eti.idfInstitution
		FROM EmployeeToInstitution eti 
		WHERE idfUserId = @idfNewUserId AND eti.aspNetUserId = @aspNetUserId and IsDefault=1

		UPDATE	[dbo].[AspNetUsers]
		SET		idfUserID = @idfNewUserID
		WHERE	Id = @aspNetUserId

		--UPDATE dbo.tlbPerson
		--SET idfInstitution = @newDefaultOrg 
		--WHERE idfPerson = (SELECT tlbPerson.idfPerson FROM tstUserTable WHERE idfUserID = @idfNewUserId)

		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
	END TRY  
	BEGIN CATCH 
		BEGIN
			SET	@returnCode = ERROR_NUMBER();
			SET	@returnMsg = 
						'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
						+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
						+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
						+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
						+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
						+ ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage
		END
	END CATCH;
END


