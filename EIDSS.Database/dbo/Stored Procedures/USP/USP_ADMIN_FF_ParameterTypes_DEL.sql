
-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterTypes_DEL
-- Description: Deletes the Parameter Type
--          
-- Revision History:
-- Name				Date		Change
-- ---------------	----------	--------------------------------------------------------------------
-- Kishore Kodru    11/28/2018	Initial release for new API.
-- Lamont Mitchell	12/29/2018	Modified Output paramaters
-- Doug Albanese	10/28/2020	Update to a soft delete
-- Doug Albanese	10/28/2020	Added Auditing Information
-- Mike Kornegay	07/26/2021	Added in use checking
-- Mike Kornegay	08/25/2021	Corrected child record logic for reference type parameter types
-- Mike Korengay    10/27/2021  Corrected child record check to exclude inactive records
-- =================/===============================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterTypes_DEL]
(
	@idfsParameterType	BIGINT,
	@User				NVARCHAR(50) = '',
	@deleteAnyway		BIT,
	@LangId				NVARCHAR(200)

)
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE
		@idfsReferenceType BIGINT,
		@ErrorMessage NVARCHAR(400),
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success'   

	BEGIN TRY
		BEGIN TRANSACTION;

		SET @idfsReferenceType = (SELECT PT.idfsReferenceType FROM ffParameterType PT WHERE PT.idfsParameterType = @idfsParameterType)
		
		/*Child Record Check */
		--Fixed Preset Value Type
		IF @idfsReferenceType = 19000069
			BEGIN
				PRINT 'FIXED PRESET VALUE'
				IF EXISTS (SELECT idfsParameterType FROM ffParameterFixedPresetValue WHERE idfsParameterType = @idfsParameterType AND intRowStatus = 0)
					BEGIN
						SET @returnCode = 1
						SET @returnMsg = 'HAS CHILD RECORDS'
						GOTO DONE
					END
				ELSE
					BEGIN
						GOTO RESOLVE
					END
			END
		--Refence Type (non Diagnosis)
		--ELSE IF @idfsReferenceType IS NOT NULL AND @idfsReferenceType <> 19000069 AND @idfsReferenceType <> 19000019
		--	BEGIN
		--		PRINT 'REFERENCE TYPE NON DIAGNOSIS'
		--		IF EXISTS (SELECT R.idfsReference FROM dbo.FN_GBL_Reference_List_GET(@LangID, @idfsReferenceType) R)
		--			BEGIN
		--				SET @returnCode = 1
		--				SET @returnMsg = 'HAS CHILD RECORDS'
		--				GOTO DONE
		--			END
		--		ELSE
		--			BEGIN
		--				GOTO RESOLVE
		--			END
		--	END
		----Reference Type (Diagnosis)
		--ELSE IF @idfsReferenceType IS NOT NULL AND @idfsReferenceType = 19000019
		--	BEGIN
		--		PRINT 'REFERENCE TYPE DIAGNOSIS'
		--		IF EXISTS (SELECT R.idfsReference FROM dbo.FN_GBL_Reference_List_GET(@LangID, @idfsReferenceType) R
		--					INNER JOIN dbo.trtDiagnosis D ON R.idfsReference = D.idfsDiagnosis 
		--					AND D.intRowStatus = 0 AND D.idfsUsingType = 10020001)
		--			BEGIN
		--				SET @returnCode = 1
		--				SET @returnMsg = 'HAS CHILD RECORDS'
		--				GOTO DONE
		--			END
		--		ELSE
		--			BEGIN
		--				GOTO RESOLVE
		--			END
		--	END
		/*In Use Check*/
		ELSE IF EXISTS (SELECT p.idfsParameter FROM tlbActivityParameters p 
						WHERE p.idfsParameter = @idfsParameterType
						AND p.intRowStatus = 0)
				BEGIN
					PRINT 'IN USE'
					IF @deleteAnyway = 1
						BEGIN
							SET @returnCode = 0
							SET @returnMsg = 'Success'
							GOTO RESOLVE
						END
					ELSE
						BEGIN
							SET @returnCode = 1
							SET @returnMsg = 'IN USE'
							GOTO DONE
						END
				END
			ELSE
				BEGIN
					GOTO RESOLVE
				END
		
		RESOLVE:
			--Parameter Type can be Deleted
			BEGIN
				PRINT 'CAN BE DELETED'		
				UPDATE ffParameterType
				SET intRowStatus = 1,
				AuditUpdateDTM = GETDATE(),
				AuditUpdateUser = @User
				WHERE idfsParameterType = @idfsParameterType
				GOTO DONE	
			END
		
		DONE:
			COMMIT TRANSACTION;
			SELECT @returnCode 'ReturnCode', @returnMsg 'ReturnMessage' 		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END
