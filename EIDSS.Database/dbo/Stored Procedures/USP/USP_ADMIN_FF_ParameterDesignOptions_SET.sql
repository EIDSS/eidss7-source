-- ================================================================================================
-- Name: USP_ADMIN_FF_ParameterDesignOptions_SET
-- Description:	Save the ParameterDesignOptions
--          
-- Revision History:
-- Name            Date       Change
-- --------------- ---------- --------------------------------------------------------------------
-- Kishore Kodru    11/28/2018 Initial release for new API.
-- Doug Albanese	01/19/2021	Added the "Copy Only" feature, for use with the Copy Template SP
-- Doug Albanese	01/19/2021	Added "Begin Transaction"
-- Doug Albanese	07/01/2021	LangId Correction
-- Doug Albanese	03/02/2022	Removed all EIDSS 6 key id SP
-- Doug Albanese	06/02/2022	Removed debugging information that was left over. :(
-- Doug Albanese	01/21/2023	Alter SP to work with POCO. Remove return values, since they are not sued by any method
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_FF_ParameterDesignOptions_SET] 
(	
	@idfsParameter		BIGINT
	,@idfsFormTemplate	BIGINT
	,@intLeft			INT
	,@intTop			INT
    ,@intWidth			INT
    ,@intHeight			INT    
    ,@intScheme			INT
    ,@intLabelSize		INT
    ,@intOrder			INT
    ,@LangID			NVARCHAR(50)  
	,@User				NVARCHAR(50) = ''
	,@CopyOnly			INT = 0
)	
AS
BEGIN	
	SET NOCOUNT ON;
	

	Declare
		@langid_int BIGINT,
		@LangID_intEN BIGINT,
		@idfParameterDesignOption BIGINT,
		@idfParameterDesignOptionEN BIGINT,
		@returnCode BIGINT = 0,
		@returnMsg  NVARCHAR(MAX) = 'Success' 

	Declare @SupressSelect table
		( ReturnCode int,
			ReturnMessage varchar(200)
		)

	BEGIN TRY
		BEGIN TRANSACTION

		SET @langid_int = dbo.FN_GBL_LanguageCode_GET(@LangID);
		SET @LangID_intEN = dbo.FN_GBL_LanguageCode_GET(@LangID); 
	
	
		IF (@idfsFormTemplate IS NULL)
			BEGIN
				SELECT @idfParameterDesignOption = [idfParameterDesignOption]
				FROM dbo.ffParameterDesignOption
				WHERE [idfsParameter] = @idfsParameter
					  AND idfsFormTemplate IS NULL
					  AND [idfsLanguage] = @langid_int
					  AND [intRowStatus] = 0
			END
		ELSE
			BEGIN	         	
				SELECT @idfParameterDesignOption = [idfParameterDesignOption]
				FROM dbo.ffParameterDesignOption
				WHERE [idfsParameter] = @idfsParameter
					  AND [idfsFormTemplate] = @idfsFormTemplate
					  AND [idfsLanguage] = @langid_int
					  AND [intRowStatus] = 0    	
			END

--		SELECT @idfParameterDesignOption

		IF (@idfParameterDesignOption IS NULL)
			BEGIN
				
				--EXEC dbo.[usp_sysGetNewID] @idfParameterDesignOption OUTPUT
				INSERT INTO @SupressSelect
				EXEC	dbo.USP_GBL_NEXTKEYID_GET 'ffParameterDesignOption', @idfParameterDesignOption OUTPUT;
				INSERT [dbo].[ffParameterDesignOption]
					(
				   		[idfParameterDesignOption]
					    ,[intLeft]
					    ,[intTop]
					    ,[intWidth]
					    ,[intHeight]					   
					    ,[intScheme]
					    ,[intLabelSize]					 
					    ,[idfsParameter]
					    ,[idfsLanguage]
					    ,[idfsFormTemplate]
					    ,[intOrder]
						,strMaintenanceFlag
						,SourceSystemNameID
						,SourceSystemKeyValue
						,AuditCreateDTM
						,AuditCreateUser
				   )
				VALUES
				   (
				   		@idfParameterDesignOption
						,@intLeft
						,@intTop
					    ,@intWidth
					    ,@intHeight					   
					    ,@intScheme
					    ,@intLabelSize					  
					    ,@idfsParameter
					    ,@langid_int
					    ,@idfsFormTemplate
					    ,@intOrder
						,'V7 Reference. FF'
						,10519001
						,'[{"idfParameterDesignOption":' + CAST(@idfParameterDesignOption AS NVARCHAR(24)) + '}]'
						,GETDATE()
						,@User
				   )
				   
	
				IF (@LangID <> 'en-US')
					BEGIN
				
						IF (@idfsFormTemplate IS NULL)
							BEGIN
								SELECT @idfParameterDesignOptionEN = [idfParameterDesignOption]
								FROM dbo.ffParameterDesignOption
								WHERE [idfsParameter] = @idfsParameter
									  AND idfsFormTemplate IS NULL
									  AND [idfsLanguage] = @LangID_intEN 
									  AND intRowStatus = 0
							END
						ELSE
							BEGIN	         	
								SELECT @idfParameterDesignOptionEN = [idfParameterDesignOption]
								FROM dbo.ffParameterDesignOption
								WHERE [idfsParameter] = @idfsParameter
									  AND [idfsFormTemplate] = @idfsFormTemplate
									  AND [idfsLanguage] = @LangID_intEN 
									  AND intRowStatus = 0  	
							END
							
				
						IF (@idfParameterDesignOptionEN IS NULL)
							BEGIN
								--EXEC dbo.[usp_sysGetNewID] @idfParameterDesignOptionEN OUTPUT
								INSERT INTO @SupressSelect
								EXEC	dbo.USP_GBL_NEXTKEYID_GET 'ffParameterDesignOption', @idfParameterDesignOption OUTPUT;
								
								INSERT [dbo].[ffParameterDesignOption]
									(
				   						[idfParameterDesignOption]
										,[intLeft]
										,[intTop]
										,[intWidth]
										,[intHeight]					  
										,[intScheme]
										,[intLabelSize]						 
										,[idfsParameter]
										,[idfsLanguage]
										,[idfsFormTemplate]
										,[intOrder]
										,strMaintenanceFlag
										,SourceSystemNameID
										,SourceSystemKeyValue
										,AuditCreateDTM
										,AuditCreateUser
									)
								VALUES
									(
				   						@idfParameterDesignOptionEN
										,@intLeft
										,@intTop
										,@intWidth
										,@intHeight					   
										,@intScheme
										,@intLabelSize					 
										,@idfsParameter
										,@LangID_intEN
										,@idfsFormTemplate
										,@intOrder
										,'V7 Reference. FF'
										,10519001
										,'[{"idfParameterDesignOption":' + CAST(@idfParameterDesignOption AS NVARCHAR(24)) + '}]'
										,GETDATE()
										,@User
									)			                     	
							END
					END
			END
		ELSE
			BEGIN
	         	UPDATE [dbo].[ffParameterDesignOption]
				SET [intLeft] = @intLeft				
					,[intTop] = @intTop
					,[intWidth] = @intWidth
					,[intHeight] = @intHeight						  
					,[intScheme] = @intScheme
					,[intLabelSize] = @intLabelSize
					,[intOrder] = @intOrder
					,[intRowStatus] = 0	
					,AuditUpdateDTM = GETDATE()
					,AuditUpdateUser = @User					
				WHERE [idfParameterDesignOption] = @idfParameterDesignOption
			END	

		--IF @CopyOnly = 0
		--	BEGIN
		--		SELECT @returnCode, @returnMsg
		--	END

		COMMIT TRANSACTION;
	END TRY 
	BEGIN CATCH   
	
		IF @@TRANCOUNT > 0 AND @CopyOnly = 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH;
   
END

