
--*************************************************************
-- Name 				: USP_ADMIN_USR_GROUPMEMBER_DEL
-- Description			: Delete user from member group
--          
-- Author               : Maheshwar Deo
-- Revision History
-- Name				Date			Change Detail
-- ??				??				Creation
-- Steven Verner	12/19/2019		changed to allow SP to pass in a list of roles to delete for the given user.
--
-- Testing code:
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ADMIN_USR_GROUPMEMBER_DEL]
(
	@idfEmployeeGroups varchar(1000), -- Comma seperated list of roles as BIGINT
	--@idfEmployeeGroup bigint,
	@idfEmployee bigint
)
AS
DECLARE @returnCode		INT = 0 
DECLARE	@returnMsg		NVARCHAR(MAX) = 'SUCCESS' 
BEGIN

	BEGIN TRY
	BEGIN TRANSACTION

		--DELETE 
		--FROM	dbo.tlbEmployeeGroupMember 
		--WHERE	idfEmployeeGroup = @idfEmployeeGroup and idfEmployee = @idfEmployee

		--IF @@TRANCOUNT > 0 
		--  COMMIT

		--SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage

		MERGE dbo.tlbEmployeeGroupMember AS target
		USING(SELECT cast( value as bigint), @idfEmployee FROM String_Split(@idfEmployeeGroups,',')) as source( idfEmployeeGroup, idfEmployee)
		ON (target.idfEmployeeGroup = source.idfEmployeeGroup and target.idfEmployee = source.idfEmployee ) 
		WHEN MATCHED THEN 
			DELETE;

		IF @@TRANCOUNT > 0 
		  COMMIT

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END TRY  

	BEGIN CATCH 

		SET @returnMsg = 
			'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
			+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
			+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
			+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
			+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
			+ ' ErrorMessage: '+ ERROR_MESSAGE()

		SET @returnCode = ERROR_NUMBER()

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END CATCH
END


