-- ================================================================================================
-- Name: USP_GBL_Department_Set
--
-- Description:	Add, updates and deletes department records.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Joan Li          04/18/2017 Initial release; created based on V6.
-- Joan Li			04/26/2017 Insert data into table tlbDepartment.
-- Joan Li			06/21/2017 Add data to modify date and user info.
-- Joan Li			05/16/2018 Change to valid function FN_GBL_DATACHANGE_INFO.
-- Stephen Long     11/19/2018 Renamed for global use; used by multiple modules.
-- Ricky Moss		06/23/2019 Added return code and return message
-- Ricky Moss		06/24/2019 Removed output departmentID variable
-- Ricky Moss		07/02/2019 Select first active department if current exists.
-- Ricky Moss		03/11/2020 Added reference type condition when searching for department name
-- Testing Code:
-- EXECUTE USP_GBL_Department_Set 'en', NULL, 52448330000058, 'Epizoology', NULL, NULL, 'demo', NULL
-- SELECT * FROM dbo.tlbdepartment ORDER BY idfdepartment DESC;
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_GBL_Department_Set] 
(
	@LanguageID								NVARCHAR(50),
	@DepartmentID							BIGINT,
	@OrganizationID							BIGINT,
	@DefaultName							NVARCHAR(200) = NULL,
	@NationalName							NVARCHAR(200) = NULL,
	@CountryID								BIGINT = NULL,
	@UserName								VARCHAR(100) = NULL, 
	@RecordAction							NCHAR = NULL
)
AS
	DECLARE @returnMsg				VARCHAR(MAX) = 'SUCCESS';
	DECLARE @returnCode				BIGINT = 0;
	DECLARE @SupressSelect			TABLE (retrunCode INT, returnMessage VARCHAR(200))
	DECLARE @DepartmentNameTypeID	BIGINT
	DECLARE @NewRecordIndicator		BIT
BEGIN
	BEGIN TRY
		SET XACT_ABORT, NOCOUNT ON;

		BEGIN TRANSACTION

		IF UPPER(@RecordAction) = 'D' -- Delete
		BEGIN
			EXECUTE							dbo.usp_Department_Delete @DepartmentID;
		END
		ELSE
		BEGIN

			IF (EXISTS(SELECT idfsBaseReference FROM trtBaseReference WHERE strDefault = @DefaultName AND idfsReferenceType = 19000164 AND intRowStatus = 0))
			BEGIN
				SELECT @DepartmentNameTypeID = (SELECT TOP(1) idfsBaseReference FROM trtBaseReference WHERE strDefault = @DefaultName AND idfsReferenceType = 19000164 AND intRowStatus = 0)
			END
			ELSE IF (EXISTS(SELECT idfsBaseReference FROM trtBaseReference WHERE strDefault = @DefaultName AND intRowStatus = 1))
			BEGIN
				SELECT @DepartmentNameTypeID = (SELECT TOP(1) idfsBaseReference FROM trtBaseReference WHERE strDefault = @DefaultName AND idfsReferenceType = 19000164 AND intRowStatus = 1)
				UPDATE trtBaseReference SET intRowStatus = 0 WHERE idfsBaseReference = @DepartmentNameTypeID AND intRowStatus = 1
			END
			ELSE
			BEGIN
				--EXECUTE						dbo.usp_sysGetNewID @DepartmentNameTypeID OUTPUT;
				INSERT INTO @SupressSelect	
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'trtBaseReference', @DepartmentNameTypeID OUTPUT;
				IF(UPPER(@LanguageID) = 'EN' AND ISNULL(@DefaultName, N'') = N'')
				BEGIN
					SET							@DefaultName = @NationalName;
				END
	
				EXECUTE							dbo.usp_BaseReference_SysSet @DepartmentNameTypeID, 19000164, @LanguageID, @DefaultName, @NationalName, 0;
			END


			--IF @NewRecordIndicator = 1
			--BEGIN
				IF @DepartmentID IS NULL
				BEGIN
					
					INSERT INTO @SupressSelect	
					EXECUTE					dbo.usp_sysGetNewID @DepartmentID OUTPUT;
				
				INSERT INTO					dbo.tlbDepartment
				(
											idfDepartment,
											idfsDepartmentName,
											idfOrganization,
											strReservedAttribute,
											intRowStatus
				)
				VALUES
				(
											@DepartmentID,
											@DepartmentNameTypeID,
											@OrganizationID,
											dbo.FN_GBL_DATACHANGE_INFO(@UserName),
											0
				);	   
				END
				ELSE
				BEGIN
					UPDATE tlbDepartment SET idfsDepartmentName =  @DepartmentNameTypeID WHERE idfDepartment = @DepartmentID
				END
			--END
		END

		IF @@TRANCOUNT > 0
			COMMIT;

		SELECT @returnCode 'returnCode', @returnMsg 'returnMessage', @DepartmentID 'DepartmentID'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK;

		THROW;
	END CATCH
END
