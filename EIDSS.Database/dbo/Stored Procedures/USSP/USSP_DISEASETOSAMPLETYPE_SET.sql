-- ==========================================================================================================================
-- Name: USSP_DISEASETOSAMPLETYPE_SET
-- Description:	Create a relationship between a disease and sample types
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- ----------------------------------------------------------------------------------------------
-- Ricky Moss		03/20/2020 Initial release.
-- Doug Albanese	04/14/2021	Refactored to keep tests from not going into a soft delete status.
-- Leo Tracchia		04/17/2023	modified to correctly audit changes to sample types associated with diseases
-- ==========================================================================================================================
CREATE PROCEDURE [dbo].[USSP_DISEASETOSAMPLETYPE_SET]
(
	@idfsDiagnosis BIGINT,
	@strSampleType NVARCHAR(MAX),
	@SiteId BIGINT = null,
    @UserId BIGINT = null,
	@idfDataAuditEvent BIGINT = NULL
)

AS

BEGIN

	DECLARE @idfsSampleType BIGINT
	DECLARE @idfMaterialForDisease BIGINT

	--Data Audit			
	DECLARE @idfsObjectType bigint = 10017018; 
	DECLARE @idfObject bigint = @idfsDiagnosis;
	DECLARE @idfObjectTable_trtMaterialForDisease bigint = 75880000000;

	--Temp Tables
	DECLARE @SupressSelect TABLE 
	(	
		retrunCode INT, 
		returnMessage VARCHAR(200)
	)	

	DECLARE @InputSamples TABLE 
	(
		idfsSampleType bigint
	) 

	DECLARE @CurrentActiveSamples TABLE
	(
		idfsSampleType bigint		
	);

	DECLARE @SamplesToRemove TABLE
	(
		idfsSampleType bigint		
	);

	BEGIN TRY

		--active samples
		insert into @CurrentActiveSamples select idfsSampleType from trtMaterialForDisease where idfsDiagnosis = @idfsDiagnosis and intRowStatus = 0		

		--input parameter samples 
		INSERT INTO @InputSamples SELECT VALUE AS idfsSampleType FROM STRING_SPLIT(@strSampleType,',');

		--samples to remove
		insert into @SamplesToRemove select idfsSampleType from @CurrentActiveSamples cas where (not exists(select idfsSampleType from @InputSamples it where (it.idfsSampleType = cas.idfsSampleType)))

		--if there are samples being passed in
		IF (select count(idfsSampleType) from @InputSamples) > 0

			begin
				
				--deactivate the ones to be removed (if any)
				WHILE(SELECT COUNT(idfsSampleType) FROM @SamplesToRemove) > 0

					BEGIN

						SELECT @idfsSampleType = (SELECT TOP 1 (idfsSampleType) FROM @SamplesToRemove)

						UPDATE 
							trtMaterialForDisease 
						SET	
							intRowStatus = 1 
						WHERE 
							idfsDiagnosis = @idfsDiagnosis AND 
							idfsSampleType = @idfsSampleType AND
							intRowStatus = 0;

						-- Get the number of affected rows
						DECLARE @RowsDeleted1 INT; 
						SET @RowsDeleted1 = @@ROWCOUNT; 

						IF @RowsDeleted1 > 0

							begin												

								--audit for "delete"
								insert into dbo.tauDataAuditDetailDelete(
									idfDataAuditEvent, 
									idfObjectTable, 							 
									idfObject, 
									idfObjectDetail, 
									idfDataAuditDetailDelete)				
								select 
									@idfDataAuditEvent,
									@idfObjectTable_trtMaterialForDisease, 
									@idfsDiagnosis,
									@idfsSampleType,
									newid()									

							end

						SET @RowsDeleted1 = 0;
						DELETE FROM @SamplesToRemove WHERE idfsSampleType = @idfsSampleType
					
					END					
				
				--activate the ones to be added (if any)
				WHILE(SELECT COUNT(idfsSampleType) FROM @InputSamples) > 0

					BEGIN

						SELECT @idfsSampleType = (SELECT TOP 1 (idfsSampleType) FROM @InputSamples)

						IF EXISTS(SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType AND intRowStatus = 1) 

							BEGIN
								
								UPDATE 
									trtMaterialForDisease 
								SET	
									intRowStatus = 0 
								WHERE 
									idfsDiagnosis = @idfsDiagnosis AND 
									idfsSampleType = @idfsSampleType AND
									intRowStatus = 1
								
								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
								VALUES (@idfDataAuditEvent, @idfObjectTable_trtMaterialForDisease, @idfsDiagnosis, @idfsSampleType)	

							END

						ELSE IF (NOT EXISTS(SELECT idfMaterialForDisease FROM trtMaterialForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsSampleType = @idfsSampleType)) 

							BEGIN

								INSERT INTO @SupressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtMaterialForDisease', @idfMaterialForDisease OUTPUT;								

								INSERT INTO trtMaterialForDisease (idfMaterialForDisease, idfsSampleType, idfsDiagnosis, intRowStatus) 
								VALUES(@idfMaterialForDisease, @idfsSampleType, @idfsDiagnosis, 0)

								--Data Audit
								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
								VALUES (@idfDataAuditEvent, @idfObjectTable_trtMaterialForDisease, @idfsDiagnosis, @idfsSampleType)
											
							END

						DELETE FROM @InputSamples WHERE idfsSampleType = @idfsSampleType;

					END							

				END	
		
		ELSE --if no samples are passed in, then they could have been all potentially removed from UI, therefore check if there are any active samples and deactivate them all

			BEGIN
				
				WHILE(SELECT COUNT(idfsSampleType) FROM @CurrentActiveSamples) > 0

					BEGIN

						SELECT @idfsSampleType = (SELECT TOP 1 (idfsSampleType) FROM @CurrentActiveSamples)

						UPDATE 
							trtMaterialForDisease 
						SET	
							intRowStatus = 1 
						WHERE 
							idfsDiagnosis = @idfsDiagnosis AND
							idfsSampleType = @idfsSampleType AND
							intRowStatus = 0;

						-- Get the number of affected rows
						DECLARE @RowsDeleted2 INT; 
						SET @RowsDeleted2 = @@ROWCOUNT; 

						IF @RowsDeleted2 > 0

							BEGIN

								INSERT INTO dbo.tauDataAuditDetailDelete(
									idfDataAuditEvent, 
									idfObjectTable, 							 
									idfObject, 
									idfObjectDetail, 
									idfDataAuditDetailDelete)				
								SELECT 
									@idfDataAuditEvent,
									@idfObjectTable_trtMaterialForDisease, 
									@idfsDiagnosis,
									@idfsSampleType,
									newid()											

							END
						
						SET @RowsDeleted2 = 0;

						DELETE FROM @CurrentActiveSamples WHERE idfsSampleType = @idfsSampleType;

					END

			END

	END TRY

	BEGIN CATCH
		THROW
	END CATCH

END