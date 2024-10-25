


-- ================================================================================================
-- Name: USP_ADMIN_FF_Sections_SET
--
-- Description: Save the sections.
--          
-- Revision History:
-- Name            Date			Change
-- --------------- ----------	--------------------------------------------------------------------
-- Kishore Kodru   11/28/2018	Initial release for new API.
-- Stephen Long    08/19/2019	Changed base reference set to use new USSP stored procedure with 
--								output parameter so section insert will function correctly. 
-- Doug Albanese	2/26/2020	Refactored to remove Eidss 6 items
-- Doug Albanese	6/8/2020	Add intRowStatus
-- Doug Albanese	10/20/2020	Added Auditing Information
-- Doug Albanese	01/14/2021	Correct the output to show...depending on the CopyOnly parameter value
-- Doug Albanese	05/05/2021	Corrected the return values for ReturnCode and ReturnMessage to match the application APIPostResponseModel
-- Mark Wilson		09/29/2021	Removed @LangID check.  it is required.  updated for all fields
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_Sections_SET] (
	@idfsSection			BIGINT = NULL
	,@idfsParentSection		BIGINT = NULL
	,@idfsFormType			BIGINT = NULL
	,@DefaultName			NVARCHAR(400) = NULL
	,@NationalName			NVARCHAR(600) = NULL
	,@LangID				NVARCHAR(50) = NULL
	,@intOrder				INT = 0
	,@blnGrid				BIT = 0
	,@blnFixedRowset		BIT = 0
	,@idfsMatrixType		BIGINT = NULL
	,@intRowStatus			INT = 0
	,@User					NVARCHAR(50) = ''
	,@CopyOnly				INT = 0				--For use by USP_ADMIN_FF_Copy_Template only
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @returnCode BIGINT = 0
		,@returnMsg NVARCHAR(MAX) = 'Success'

	BEGIN TRY
		BEGIN TRANSACTION;

		IF (@idfsParentSection <= 0)
			SET @idfsParentSection = NULL;

		IF @CopyOnly = 0
			BEGIN
				EXEC dbo.USSP_GBL_BaseReference_SET @idfsSection OUTPUT
					,19000101 /*'rftSection'*/
					,@LangID
					,@DefaultName
					,@NationalName
					,0
			END

		IF NOT EXISTS (
				SELECT TOP 1 1
				FROM dbo.ffSection
				WHERE idfsSection = @idfsSection
				)
			BEGIN
				INSERT INTO [dbo].[ffSection] (
					[idfsSection]
					,[idfsParentSection]
					,[idfsFormType]
					,[intOrder]
					,[blnGrid]
					,[blnFixedRowSet]
					,[idfsMatrixType]
					,rowguid
					,AuditCreateDTM
					,AuditCreateUser
					,AuditUpdateDTM
					,AuditUpdateUser
					)
				VALUES (
					@idfsSection
					,@idfsParentSection
					,@idfsFormType
					,@intOrder
					,@blnGrid
					,@blnFixedRowset
					,@idfsMatrixType
					,NEWID()
					,GETDATE()
					,@User
					,GETDATE()
					,@User
					)
			END
		ELSE
			BEGIN
				UPDATE [dbo].[ffSection]
				SET 
					[intOrder] = COALESCE(@intOrder,0)
					,[blnGrid] = COALESCE(@blnGrid,0)
					,[blnFixedRowSet] = COALESCE(@blnFixedRowset,0)
					,[intRowStatus] = COALESCE(@intRowStatus,0)
					,[idfsMatrixType] = @idfsMatrixType
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User
				WHERE [idfsSection] = COALESCE(@idfsSection,0)
		END

		IF @CopyOnly = 0
			BEGIN
				SELECT @returnCode AS ReturnCode, @returnMsg AS ReturnMessage, @idfsSection AS idfsSection
			END

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		--IF @@TRANCOUNT > 0
		--	ROLLBACK TRANSACTION;

		THROW;
	END CATCH
END
