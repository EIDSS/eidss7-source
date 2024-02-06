
--=====================================================================================================
-- Created by:				Mandar Kulkarni
-- Description:				04/19/2017: Created based on V6 spPerson_Post: V7 USP

-- Ricky Moss				02/12/2020 Added remove aspnetuser by idfsUserID feature
-- Ricky Moss				03/06/2020 Change Delete statements to update intRowStatus to 1
-- Ricky Moss				03/06/2020 Rollback of previous change
/*
----testing code:
DECLARE @idfPerson bigint
EXECUTE SP_ADMIN_EMP_DEL
  @idfPerson
*/

--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_DEL]
( 

	@idfPerson			BIGINT =NULL--##PARAM @idfPerson person ID
)
AS
DECLARE @idfUserID BIGINT
DECLARE @returnMsg VARCHAR(MAX) = 'SUCCESS'
DECLARE @returnCode BIGINT = 0 
BEGIN
	BEGIN TRY  	
	BEGIN TRANSACTION

	SELECT @idfUserID = (SELECT idfUserID FROM AspNetUsers WHERE idfUserID = (SELECT idfUserID FROM tstUserTable WHERE idfPerson = @idfPerson))
	
	IF @idfUserID IS NOT NULL
	BEGIN
		SELECT @returnCode = @idfUserID
		SELECT @returnMsg = 'CANNOT DELETE'
	END
	ELSE
	BEGIN
		UPDATE tlbPerson SET intRowStatus = 1 WHERE idfPerson = @idfPerson
		UPDATE tlbEmployee SET intRowStatus = 1 WHERE idfEmployee = @idfPerson
	END
		--BEGIN
		--	--UPDATE tstObjectAccess SET intRowStatus = 1 WHERE	idfActor = @idfPerson
		--	DELETE 
		--	FROM	tstObjectAccess 
		--	WHERE	idfActor = @idfPerson
		--END

		--BEGIN
		--	--UPDATE tlbEmployeeGroupMember SET intRowStatus = 1 WHERE idfEmployee = @idfPerson
		--	DELETE 
		--	FROM	tlbEmployeeGroupMember 
		--	WHERE	idfEmployee = @idfPerson
		--END

		--BEGIN
		--	--UPDATE AspNetUsers SET intRowStatus = 1 WHERE idfUserID = (SELECT idfUserID FROM tstUserTable WHERE idfPerson = @idfPerson)
		--	DELETE
		--	FROM AspNetUsers
		--	WHERE idfUserID = (SELECT idfUserID FROM tstUserTable WHERE idfPerson = @idfPerson)
		--END

		--BEGIN
		--	--UPDATE tstUserTable SET intRowStatus = 1 WHERE idfPerson = @idfPerson
		--	DELETE
		--	FROM tstUserTable
		--	WHERE idfPerson = @idfPerson
		--END

		--BEGIN
		--	UPDATE tlbPerson SET intRowStatus = 1 WHERE idfPerson = @idfPerson
		--	--DELETE 
		--	--FROM	tlbPerson 
		--	--WHERE	idfPerson = @idfPerson
		--END
	
		--BEGIN
		--	UPDATE tlbEmployee SET intRowStatus=1 WHERE idfEmployee = @idfPerson
		--	--DELETE 
		--	--FROM	tlbEmployee 
		--	--WHERE	idfEmployee = @idfPerson
		--END


		IF @@TRANCOUNT > 0 
			COMMIT  

		SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
	END TRY  

	BEGIN CATCH  

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK

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
END





