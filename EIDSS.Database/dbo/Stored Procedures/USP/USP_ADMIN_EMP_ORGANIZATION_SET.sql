

-- ================================================================================================
-- Name: USP_ADMIN_EMP_ORGANIZATION_SET		
-- 
-- Description: Insert/update an employee's organization via the idfUserID to table EmployeeToInstitution.
--
-- Revision History:
--		
-- Name				Date       	Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Ann Xiong     		08/26/2020 	Initial release.
-- Ann Xiong     		09/14/2020   Added intRowStatus parameter.
-- Ann Xiong     		10/09/2020   Added script to update idfInstitution
-- Ann Xiong     		11/17/2020   Modified to create new IDs using USP_GBL_NEXTKEYID_GET.
-- Minal Shah			08/20/2021   Added Active Column to EmployeeToInstitution
--
-- Testing Code:
-- EXEC USP_ADMIN_EMP_ORGANIZATION_SET -447, 'en'
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_EMP_ORGANIZATION_SET]
( 
	@aspNetUserId NVARCHAR(128),
	@idfUserId BIGINT,
	--@idfInstitution AS BIGINT,
	@IsDefault BIT = 0
	,@intRowStatus INT = NULL,
	@active BIT=0
)
AS
BEGIN
	DECLARE @returnMsg						VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode						BIGINT = 0;
	DECLARE @idfInstitution BIGINT
	DECLARE @SupressSelect TABLE
	(	
		retrunCode				INT,
		returnMessage			VARCHAR(200)
	) 


	SELECT	@idfInstitution = p.idfInstitution
	FROM	tlbPerson p 
			INNER JOIN 	tstUserTable ut
			ON ut.idfPerson = p.idfPerson AND ut.intRowStatus = 0
	WHERE	ut.idfUserID = @idfUserId

	BEGIN TRY  	
		IF NOT EXISTS (SELECT EmployeeToInstitution FROM dbo.EmployeeToInstitution WHERE aspNetUserId = @aspNetUserId AND idfUserId = @idfUserId)
			BEGIN  

				DECLARE	@EmployeeToInstitution BIGINT

				BEGIN
					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'EmployeeToInstitution', @EmployeeToInstitution OUTPUT
				


					-- Insert into EmployeeToInstitution table    
					INSERT INTO [dbo].[EmployeeToInstitution]   
					(    
		 				EmployeeToInstitution    
		 				,aspNetUserId   
		 				,idfUserID    
		 				,idfInstitution 
		 				,IsDefault    
						,intRowStatus
						,Active
					)    
					VALUES    
					(    
		 				@EmployeeToInstitution    
		 				,@aspNetUserId  
		 				,@idfUserID    
		 				,@idfInstitution  
		 				,@IsDefault   
						,@intRowStatus
						,@active
					)   

				END

			END 

		ELSE 
			BEGIN
				UPDATE [dbo].[EmployeeToInstitution]    
				SET  	IsDefault = @IsDefault  
						,idfInstitution  = @idfInstitution 
						,intRowStatus = @intRowStatus
						,Active=@active
				WHERE  	aspNetUserId = @aspNetUserId AND idfUserId = @idfUserId 

			END---end update 

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
