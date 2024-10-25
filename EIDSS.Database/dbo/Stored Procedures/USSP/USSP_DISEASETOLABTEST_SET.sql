-- ==========================================================================================================================
-- Name: USSP_DISEASETOLABTEST_SET
-- Description:	Create a relationship between a disease and lab tests
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- ----------------------------------------------------------------------------------------------
-- Ricky Moss		03/20/2020 Initial release.
-- Doug Albanese	04/14/2021	Refactored to keep tests from not going into a soft delete status.
-- Leo Tracchia		04/12/2023	Added data audit logic
-- Leo Tracchia		04/13/2023	modified to correctly audit changes to tests associated with diseases
-- ==========================================================================================================================
CREATE PROCEDURE [dbo].[USSP_DISEASETOLABTEST_SET]
(
	@idfsDiagnosis BIGINT,
	@strLabTest NVARCHAR(MAX),
	@SiteId BIGINT = null,
    @UserId BIGINT = null,
	@idfDataAuditEvent BIGINT = NULL
)

AS

BEGIN
		
	DECLARE @idfsTestName BIGINT
	DECLARE @idfTestForDisease BIGINT

	--Data Audit			
	DECLARE @idfsObjectType bigint = 10017018; 
	DECLARE @idfObject bigint = @idfsDiagnosis;
	DECLARE @idfObjectTable_trtTestForDisease bigint = 76010000000;		

	--Temp Tables
	DECLARE @SupressSelect TABLE 
	(
		retrunCode INT, 
		returnMessage VARCHAR(200)
	)

	DECLARE @InputTests TABLE 
	(
		idfsTestName bigint
	) 

	DECLARE @CurrentActiveTests TABLE
	(
		idfsTestName bigint		
	);

	DECLARE @TestsToRemove TABLE
	(
		idfsTestName bigint		
	);

	BEGIN TRY

		--active tests
		insert into @CurrentActiveTests select idfsTestName from trtTestForDisease where idfsDiagnosis = @idfsDiagnosis and intRowStatus = 0		

		--input parameter tests 
		INSERT INTO @InputTests SELECT VALUE AS idfsTestName FROM STRING_SPLIT(@strLabTest,',');
		
		--tests to remove
		insert into @TestsToRemove select idfsTestName from @CurrentActiveTests cat where (not exists(select idfsTestName from @InputTests it where (it.idfsTestName = cat.idfsTestName)))

		--if there are tests being passed in
		IF (select count(idfsTestName) from @InputTests) > 0

			begin
				
				--deactivate the ones to be removed (if any)
				WHILE(SELECT COUNT(idfsTestName) FROM @TestsToRemove) > 0

					BEGIN

						SELECT @idfsTestName = (SELECT TOP 1 (idfsTestName) FROM @TestsToRemove)

						UPDATE 
							trtTestForDisease 
						SET	
							intRowStatus = 1 
						WHERE 
							idfsDiagnosis = @idfsDiagnosis AND 
							idfsTestName = @idfsTestName AND
							intRowStatus = 0

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
									@idfObjectTable_trtTestForDisease, 
									@idfsDiagnosis,
									@idfsTestName,
									newid()									

							end

						SET @RowsDeleted1 = 0;
						DELETE FROM @TestsToRemove WHERE idfsTestName = @idfsTestName

					END

				--activate the ones to be added (if any)
				WHILE(SELECT COUNT(idfsTestName) FROM @InputTests) > 0

					BEGIN

						SELECT @idfsTestName = (SELECT TOP 1 (idfsTestName) FROM @InputTests)
						
						IF EXISTS(SELECT idfTestForDisease FROM trtTestForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsTestName = @idfsTestName AND intRowStatus = 1) 

							BEGIN								

								UPDATE 
									trtTestForDisease 
								SET	
									intRowStatus = 0 
								WHERE 
									idfsDiagnosis = @idfsDiagnosis AND 
									idfsTestName = @idfsTestName AND
									intRowStatus = 1
								
								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
								VALUES (@idfDataAuditEvent, @idfObjectTable_trtTestForDisease, @idfsDiagnosis, @idfsTestName)	

							END

						ELSE IF (NOT EXISTS(SELECT idfTestForDisease FROM trtTestForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsTestName = @idfsTestName)) 

							begin

								INSERT INTO @SupressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtTestForDisease', @idfTestForDisease OUTPUT;								
								
								INSERT INTO trtTestForDisease (idfTestForDisease, idfsTestName, idfsDiagnosis, intRowStatus) 
								VALUES(@idfTestForDisease, @idfsTestName, @idfsDiagnosis, 0)

								--Data Audit
								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
								VALUES (@idfDataAuditEvent, @idfObjectTable_trtTestForDisease, @idfsDiagnosis, @idfsTestName)
											
							end

						DELETE FROM @InputTests WHERE idfsTestName = @idfsTestName

					END							

			END	

		ELSE --if no tests are passed in, then they could have been all potentially removed from UI, therefore check if there are any active tests and deactivate them all

			BEGIN
				
				WHILE(SELECT COUNT(idfsTestName) FROM @CurrentActiveTests) > 0

					begin

						SELECT @idfsTestName = (SELECT TOP 1 (idfsTestName) FROM @CurrentActiveTests)

						UPDATE 
							trtTestForDisease 
						SET	
							intRowStatus = 1 
						WHERE 
							idfsDiagnosis = @idfsDiagnosis AND
							idfsTestName = @idfsTestName AND
							intRowStatus = 0

						-- Get the number of affected rows
						DECLARE @RowsDeleted2 INT; 
						SET @RowsDeleted2 = @@ROWCOUNT; 

						IF @RowsDeleted2 > 0

							begin

								insert into dbo.tauDataAuditDetailDelete(
									idfDataAuditEvent, 
									idfObjectTable, 							 
									idfObject, 
									idfObjectDetail, 
									idfDataAuditDetailDelete)				
								select 
									@idfDataAuditEvent,
									@idfObjectTable_trtTestForDisease, 
									@idfsDiagnosis,
									@idfsTestName,
									newid()											

							end
						
						SET @RowsDeleted2 = 0;

						DELETE FROM @CurrentActiveTests WHERE idfsTestName = @idfsTestName

					end

			end

	END TRY

	BEGIN CATCH
		THROW
	END CATCH

END
