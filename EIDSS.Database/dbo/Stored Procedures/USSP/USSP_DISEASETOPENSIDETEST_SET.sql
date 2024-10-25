-- ==========================================================================================================================
-- Name: USSP_DISEASETOPENSIDETEST_SET
-- Description:	Create a relationship between a disease and penside tests
--                      
-- Author: Ricky Moss
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- ----------------------------------------------------------------------------------------------
-- Ricky Moss		03/20/2020 Initial release.
-- Doug Albanese	04/14/2021	Refactored to keep tests from not going into a soft delete status.
-- Leo Tracchia		04/17/2023	modified to correctly audit changes to penside tests associated with diseases
-- ==========================================================================================================================
CREATE PROCEDURE [dbo].[USSP_DISEASETOPENSIDETEST_SET]
(		
	@idfsDiagnosis BIGINT,
	@strPensideTest NVARCHAR(MAX),
	@SiteId BIGINT = null,
    @UserId BIGINT = null,
	@idfDataAuditEvent BIGINT = NULL
)

AS

BEGIN

	DECLARE @idfsPensideTestName BIGINT
	DECLARE @idfPensideTestForDisease BIGINT	

	--Data Audit			
	DECLARE @idfsObjectType bigint = 10017018; 
	DECLARE @idfObject bigint = @idfsDiagnosis;
	DECLARE @idfObjectTable_trtPensideTestForDisease bigint = 6617430000000;		

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
		insert into @CurrentActiveTests select idfsPensideTestName from trtPensideTestForDisease where idfsDiagnosis = @idfsDiagnosis and intRowStatus = 0		

		--input parameter tests 
		INSERT INTO @InputTests SELECT VALUE AS idfsTestName FROM STRING_SPLIT(@strPensideTest,',');

		--tests to remove
		insert into @TestsToRemove select idfsTestName from @CurrentActiveTests cat where (not exists(select idfsTestName from @InputTests it where (it.idfsTestName = cat.idfsTestName)))

		--if there are tests being passed in
		IF (select count(idfsTestName) from @InputTests) > 0

			begin
				
				--deactivate the ones to be removed (if any)
				WHILE(SELECT COUNT(idfsTestName) FROM @TestsToRemove) > 0

					BEGIN

						SELECT @idfsPensideTestName = (SELECT TOP 1 (idfsTestName) FROM @TestsToRemove)

						UPDATE 
							trtPensideTestForDisease 
						SET	
							intRowStatus = 1 
						WHERE 
							idfsDiagnosis = @idfsDiagnosis AND 
							idfsPensideTestName = @idfsPensideTestName AND
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
									@idfObjectTable_trtPensideTestForDisease, 
									@idfsDiagnosis,
									@idfsPensideTestName,
									newid()									

							end

						SET @RowsDeleted1 = 0;
						DELETE FROM @TestsToRemove WHERE idfsTestName = @idfsPensideTestName
					
					END
				
				--activate the ones to be added (if any)
				WHILE(SELECT COUNT(idfsTestName) FROM @InputTests) > 0

					BEGIN

						SELECT @idfsPensideTestName = (SELECT TOP 1 (idfsTestName) FROM @InputTests)

						IF EXISTS(SELECT idfPensideTestForDisease FROM trtPensideTestForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsPensideTestName = @idfsPensideTestName AND intRowStatus = 1) 

							BEGIN
								
								UPDATE 
									trtPensideTestForDisease 
								SET	
									intRowStatus = 0 
								WHERE 
									idfsDiagnosis = @idfsDiagnosis AND 
									idfsPensideTestName = @idfsPensideTestName AND
									intRowStatus = 1
								
								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
								VALUES (@idfDataAuditEvent, @idfObjectTable_trtPensideTestForDisease, @idfsDiagnosis, @idfsPensideTestName)	

							END

						ELSE IF (NOT EXISTS(SELECT idfPensideTestForDisease FROM trtPensideTestForDisease WHERE idfsDiagnosis = @idfsDiagnosis AND idfsPensideTestName = @idfsPensideTestName)) 

							BEGIN

								INSERT INTO @SupressSelect
								EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtPensideTestForDisease', @idfPensideTestForDisease OUTPUT;								

								INSERT INTO trtPensideTestForDisease (idfPensideTestForDisease, idfsPensideTestName, idfsDiagnosis, intRowStatus) 
								VALUES(@idfPensideTestForDisease, @idfsPensideTestName, @idfsDiagnosis, 0)

								--Data Audit
								INSERT INTO tauDataAuditDetailCreate(idfDataAuditEvent, idfObjectTable, idfObject, idfObjectDetail)
								VALUES (@idfDataAuditEvent, @idfObjectTable_trtPensideTestForDisease, @idfsDiagnosis, @idfsPensideTestName)
											
							END

						DELETE FROM @InputTests WHERE idfsTestName = @idfsPensideTestName;

					END							

			END	
		
		ELSE --if no tests are passed in, then they could have been all potentially removed from UI, therefore check if there are any active tests and deactivate them all

			BEGIN
				
				WHILE(SELECT COUNT(idfsTestName) FROM @CurrentActiveTests) > 0

					BEGIN

						SELECT @idfsPensideTestName = (SELECT TOP 1 (idfsTestName) FROM @CurrentActiveTests)

						UPDATE 
							trtPensideTestForDisease 
						SET	
							intRowStatus = 1 
						WHERE 
							idfsDiagnosis = @idfsDiagnosis AND
							idfsPensideTestName = @idfsPensideTestName AND
							intRowStatus = 0

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
									@idfObjectTable_trtPensideTestForDisease, 
									@idfsDiagnosis,
									@idfsPensideTestName,
									newid()											

							END
						
						SET @RowsDeleted2 = 0;

						DELETE FROM @CurrentActiveTests WHERE idfsTestName = @idfsPensideTestName

					END

			END

	END TRY

	BEGIN CATCH
		THROW
	END CATCH

END