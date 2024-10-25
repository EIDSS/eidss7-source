

--*************************************************************
-- Name 				: USP_REP_REPORT_AUDIT_SET
-- Description			: Insert Report Audit
--          
-- Author               : Srini Goli
-- Revision History
--		Name        Date        Change Detail
-- Testing code: EXEC USP_REP_REPORT_AUDIT_SET 1234,'Srini','Rao','Goli',1,'NG','SampleReport',1,'10/19/2020'
-- SELECT * FROM [dbo].[tlbReportAudit]
--*************************************************************
CREATE PROCEDURE [dbo].[USP_REP_REPORT_AUDIT_SET]
(
	@idfUserID									BIGINT, 
	@strFirstName								NVARCHAR(256),
	@strMiddleName								NVARCHAR(256),
	@strLastName								NVARCHAR(256),
	@UserRole									NVARCHAR(256),
	@strOrganization							NVARCHAR(256),
	@strReportName							    NVARCHAR(256),
	@idfIsSignatureIncluded						bit,
	@datGeneratedDate							DATETIME
)
AS
DECLARE @returnCode								INT = 0 
DECLARE	@returnMsg								NVARCHAR(MAX) = 'SUCCESS' 

BEGIN
	BEGIN TRY
	--SET XACT_ABORT ON
		BEGIN TRANSACTION

					INSERT INTO [dbo].[tlbReportAudit]
					   ([idfUserID]
					   ,[FirstName]
					   ,[MiddleName]
					   ,[LastName]
					   ,[UserRole]
					   ,[Organization]
					   ,[ReportName]
					   ,[IsSignatureIncluded]
					   ,[GeneratedDate])
					VALUES
					   (@idfUserID
					   ,@strFirstName
					   ,@strMiddleName
					   ,@strLastName
					   ,@UserRole
					   ,@strOrganization
					   ,@strReportName
					   ,@idfIsSignatureIncluded
					   ,@datGeneratedDate)
				
		IF @@TRANCOUNT > 0 AND @returnCode = 0
			COMMIT;

		SELECT	@returnCode 'ReturnCode', @returnMsg 'ReturnMessage'
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT	@returnCode =ERROR_NUMBER(), @returnMsg=ERROR_MESSAGE();
	END CATCH

END



