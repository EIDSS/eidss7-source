﻿

--=====================================================================================================
-- Created by:				Joan Li
-- Last modified date:		06/13/2017
-- Last modified by:		Joan Li
-- Description:				06/13/2017: Created based on V6 spStatistic_Post:  V7 usp54
--                          purpose: save records in tlbStatistic
--                          06/15/2017: change action parameter
-- Revision History
-- Name                 Date            Change Detail
-- Steven Verner        10/20/2021      Added @AuditUser and @AuditDTM parameters
/*
----testing code:
DECLARE @idfStatistic BIGINT
EXECUTE usp_Statistic_Set 'd',10736140000000--10736130000000
select * from tlbStatistic
*/
--=====================================================================================================

CREATE PROCEDURE [dbo].[usp_Statistic_Set]
	(
	@Action						VARCHAR(2)			--##PARAM @Action - set action,  I - add record, D - delete record, U - modify record
	,@idfStatistic				BIGINT				--##PARAM @idfStatistic - statistic record ID
	,@idfsStatisticDataType		BIGINT		= NULL	--##PARAM @idfsStatisticDataType - statistic data Type
	,@idfsMainBaseReference		BIGINT		= NULL	--##PARAM @idfsMainBaseReference - statistic base reference
	,@idfsStatisticAreaType		BIGINT		= NULL	--##PARAM @idfsStatisticAreaType - statistic Area Type
	,@idfsStatisticPeriodType	BIGINT		= NULL	--##PARAM @idfsStatisticPeriodType - statistic period Type
	,@idfsCountry				BIGINT		= NULL	--##PARAM @idfsArea - statistic Area
	,@idfsRegion				BIGINT		= NULL	--##PARAM @idfsArea - statistic Area
	,@idfsRayon					BIGINT		= NULL	--##PARAM @idfsArea - statistic Area
	,@datStatisticStartDate		DATETIME	= NULL	--##PARAM @datStatisticStartDate - start date
	,@datStatisticFinishDate	DATETIME	= NULL	--##PARAM @datStatisticFinishDate - finish date 
	,@varValue					SQL_VARIANT = NULL	--##PARAM @varValue - statistic content
	,@idfsStatisticalAgeGroup	BIGINT		= NULL
	,@idfNewStatisticID			BIGINT OUTPUT -- return  new Settlement after insert
    ,@AuditUser                 VARCHAR(100) = NULL
	)
AS

	DECLARE @LogErrMsg VARCHAR(MAX)
	SELECT @LogErrMsg = ''
	DECLARE @SupressSelect TABLE
	(
		retrunCode INT,
		returnMessage VARCHAR(200)
	)

	BEGIN TRY  	

		/*
		MD: Should we be using XACT_STATE() 
			We can check this in the CATCH block
		*/
		BEGIN TRANSACTION


		IF (UPPER(@Action) = 'I') 

			BEGIN
				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 
					@tableName = 'tlbStatistic',
					@idfsKey = @idfStatistic OUTPUT

				INSERT INTO dbo.tlbStatistic
				(
				    idfStatistic,
				    idfsStatisticDataType,
				    idfsMainBaseReference,
				    idfsStatisticAreaType,
				    idfsStatisticPeriodType,
				    idfsArea,
				    datStatisticStartDate,
				    datStatisticFinishDate,
				    varValue,
				    intRowStatus,
				    rowguid,
				    idfsStatisticalAgeGroup,
				    strMaintenanceFlag,
				    strReservedAttribute,
				    SourceSystemNameID,
				    SourceSystemKeyValue,
				    AuditCreateUser,
				    AuditCreateDTM,
				    AuditUpdateUser,
				    AuditUpdateDTM
				)
				VALUES
				(
					@idfStatistic,
					@idfsStatisticDataType,
					@idfsMainBaseReference,
					@idfsStatisticAreaType,
					@idfsStatisticPeriodType,
					CASE ISNULL(@idfsRayon, '') 
						WHEN '' THEN 
					CASE ISNULL(@idfsRegion, '') 
						WHEN '' THEN 
								@idfsCountry 
						ELSE 
								@idfsRegion 
						END 
					ELSE 
						@idfsRayon 
					END,
					@datStatisticStartDate,
					@datStatisticFinishDate,
					CAST(@varValue AS INT),
					0,
					NEWID(),
					@idfsStatisticalAgeGroup,
					NULL,
					NULL,
					10519001,
					'[{"idfStatistic":' + CAST(@idfStatistic AS NVARCHAR(300)) + '}]',
					@AuditUser,
					GETDATE(),
					@AuditUser,
					GETDATE()
				)
			END

		ELSE IF (UPPER(@Action) = 'D') 
			EXECUTE usp_Statistic_Delete @idfStatistic
		ELSE IF (UPPER(@Action) = 'U')
			UPDATE 
				tlbStatistic
			SET 
				idfsStatisticDataType = @idfsStatisticDataType
				,idfsMainBaseReference = @idfsMainBaseReference
				,idfsStatisticAreaType = @idfsStatisticAreaType
				,idfsStatisticPeriodType = @idfsStatisticPeriodType
				,idfsArea = CASE ISNULL(@idfsRayon, '') 
							WHEN '' THEN 
								CASE ISNULL(@idfsRegion, '') 
									WHEN '' THEN 
										@idfsCountry 
									ELSE 
										@idfsRegion 
								END 
							ELSE 
								@idfsRayon 
							END
				,datStatisticStartDate = @datStatisticStartDate
				,datStatisticFinishDate = @datStatisticFinishDate
				,varValue = CAST(@varValue AS INT)
				,idfsStatisticalAgeGroup = @idfsStatisticalAgeGroup
                ,AuditUpdateUser = @AuditUser
                ,AuditUpdateDTM = GETDATE()
			 WHERE 
				idfStatistic = @idfStatistic
		COMMIT  

		SELECT @idfNewStatisticID = @idfStatistic
		SET @LogErrMsg = 'Success' 
		SELECT @LogErrMsg 

	END TRY  

	BEGIN CATCH  

		-- Execute error retrieval routine. 
		IF @@TRANCOUNT = 0
			--MD: Not sure what to return. But we need a result set to be returned
			BEGIN
				
				SELECT @idfNewStatisticID = -1
				SET @LogErrMsg = '' 
				SELECT @LogErrMsg 
				
				RETURN
			END

		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK

				SELECT @idfNewStatisticID = -1
				SET @LogErrMsg = 
				'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER() ) 
				+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY() )
				+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
				+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE() ,'')
				+ ' ErrorLine: ' +  CONVERT(VARCHAR,ISNULL(ERROR_LINE() ,''))
				+ ' ErrorMessage: '+ ERROR_MESSAGE()
				SELECT @LogErrMsg
			END

	END CATCH; 


