
-- ============================================================================
-- Name: USP_ADMIN_LogSecurityEvent_SET
-- Create Security Event Log for SAUC61
--                      
-- Author: Manickandadn Govindarajan
-- Revision History:
-- Name						 Date        Change Detail
-- ---------------- ---------- -----------------------------------------------
-- Manickandadn Govindarajan 07/11/2022  Initial Release
-- ============================================================================

CREATE PROCEDURE [dbo].[USP_GBL_LogSecurityEvent_SET]
(
	 @idfUserID Bigint = Null
	,@idfsAction bigint
	,@success bit--success	
	,@strErrorText As Nvarchar(200) = Null
	,@strDescription As Nvarchar(200) = Null
	,@idfObjectID as bigint =0
	,@idfsProcessType as bigint = 10130000 ,--eidss
	 @idfSiteId as bigint
	
)
AS
Begin
/*	
	Declare @typeID Bigint
	
	Set @typeID = case @type when 1 then 10110000
						when 0 then 10110001 
						when 2 then 10110005 
						end
*/
	DECLARE @returnMsg						VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode						BIGINT = 0;

	
	BEGIN TRY 
	
		declare @ID bigint
		exec spsysGetNewID @ID out

		insert into dbo.tstSecurityAudit(
			idfSecurityAudit
			,idfsAction
			,idfsResult
			,idfUserID
			,datActionDate
			,idfsProcessType
			,idfAffectedObjectType
			,idfObjectID
			,strErrorText
			,strProcessID
			,strDescription
		)
		values
		(
			@ID
			,@idfsAction--@typeID
			,case @success when 1 then 10120000 else 10120001 end
			,@idfUserID
			,GETUTCDATE()
			,@idfsProcessType
			,0
			,@idfObjectID
			,@strErrorText
			,dbo.fnGetContext()
			,@strDescription
		)

		SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage

	END TRY  
	BEGIN CATCH 
		BEGIN
			SET								@returnCode = ERROR_NUMBER();
			SET								@returnMsg = 
											'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
											+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
											+ ' ErrorState: ' + CONVERT(VARCHAR, ERROR_STATE())
											+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
											+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
											+ ' ErrorMessage: ' + ERROR_MESSAGE();

			SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage
		END
	END CATCH;
END