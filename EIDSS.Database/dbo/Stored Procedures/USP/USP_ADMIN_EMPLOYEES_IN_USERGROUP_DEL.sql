
--*************************************************************
-- Name 				: USP_ADMIN_EMPLOYEES_IN_USERGROUP_DEL
-- Description			: Delete employees from the tlbEmployeeGroupMember table
--          
-- Author               : Manickandan Govindarajan
-- Revision History
-- Name				Date			Change Detail
-- Mani 	01/06/2021		Initital
--
-- Testing code:
--*************************************************************
CREATE PROCEDURE [dbo].[USP_ADMIN_EMPLOYEES_IN_USERGROUP_DEL]
(
	@idfEmployeeGroup bigInt, 
	@idfEmployeeList nvarchar(Max),			-- Comma seperated list of employees as BIGINT
	@AuditUser nvarchar(100)

)
AS
DECLARE @returnCode		INT = 0 
DECLARE	@returnMsg		NVARCHAR(MAX) = 'SUCCESS' 
BEGIN

	BEGIN TRY
	BEGIN TRANSACTION

		--SELECT @returnCode as ReturnCode, @returnMsg as ReturnMessage

		MERGE dbo.tlbEmployeeGroupMember AS target
		USING(SELECT cast( value as bigint), @idfEmployeeGroup FROM String_Split(@idfEmployeeList,',')) as source( idfEmployee,idfEmployeeGroup)
		ON (target.idfEmployeeGroup = source.idfEmployeeGroup and target.idfEmployee = source.idfEmployee ) 
		WHEN MATCHED THEN UPDATE
			SET target.intRowStatus=1, target.AuditUpdateUser=@AuditUser;

		IF @@TRANCOUNT > 0 
		  COMMIT

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END TRY  

	BEGIN CATCH  

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK
			END
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


