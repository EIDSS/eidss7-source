﻿
-- ================================================================================================
-- Name: USSP_LAB_FREEZER_SUBDIVISION_SET
--
-- Description:	Inserts or updates freezer subdivision records for various laboratory module use 
-- cases.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     11/29/2018 Initial release.
-- Stephen Long     01/19/2019 Added box place availability.
-- Stephen Long     03/14/2019 Added check for subdivision type, so the correct barcode type is 
--                             applied to the shelf and rack versus box (LUC 20 and 23).
-- Stephen Long     03/24/2020 Added rack barcode.
-- Steven Verner    10/20/2021 Added @AuditUser parameter
-- ================================================================================================
CREATE PROCEDURE [dbo].[USSP_LAB_FREEZER_SUBDIVISION_SET] (
	@LanguageID NVARCHAR(50),
	@FreezerSubdivisionID BIGINT OUTPUT,
	@SubdivisionTypeID BIGINT = NULL,
	@FreezerID BIGINT,
	@ParentFreezerSubdivisionID BIGINT = NULL,
	@OrganizationID BIGINT,
	@FreezerSubdivisionEIDSSID NVARCHAR(200) = NULL,
	@FreezerSubdivisionName NVARCHAR(200) = NULL,
	@Notes NVARCHAR(200) = NULL,
	@NumberOfLocations INT = NULL,
	@BoxSizeTypeID BIGINT = NULL,
	@BoxPlaceAvailability NVARCHAR(MAX) = NULL,
	@RowStatus INT,
	@RowAction CHAR,
    @AuditUser NVARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @RowAction = 'I'
		BEGIN
			EXECUTE dbo.USP_GBL_NEXTKEYID_GET 
				@tableName = N'tlbFreezerSubdivision',
				@idfsKey = @FreezerSubdivisionID OUTPUT;

			IF @SubdivisionTypeID = 39890000000 -- Box
				BEGIN
					EXECUTE dbo.USP_GBL_NextNumber_GET
						@ObjectName = N'Box Barcode',
						@NextNumberValue = @FreezerSubdivisionEIDSSID OUTPUT,
						@InstallationSite = NULL;
				END
			ELSE IF @SubdivisionTypeID = 39900000000 -- Shelf
				BEGIN
					EXECUTE dbo.USP_GBL_NextNumber_GET 
						@ObjectName = N'Shelf Barcode',
						@NextNumberValue = @FreezerSubdivisionEIDSSID OUTPUT,
						@InstallationSite = NULL;
				END
			ELSE
				BEGIN
					EXECUTE dbo.USP_GBL_NextNumber_GET
						@ObjectName = N'Rack Barcode',
						@NextNumberValue = @FreezerSubdivisionEIDSSID OUTPUT,
						@InstallationSite = NULL;
				END;

			INSERT INTO dbo.tlbFreezerSubdivision
			(
			    idfSubdivision,
			    idfsSubdivisionType,
			    idfFreezer,
			    idfParentSubdivision,
			    idfsSite,
			    strBarcode,
			    strNameChars,
			    strNote,
			    intCapacity,
			    intRowStatus,
			    rowguid,
			    strMaintenanceFlag,
			    strReservedAttribute,
			    BoxSizeID,
			    BoxPlaceAvailability,
			    SourceSystemNameID,
			    SourceSystemKeyValue,
			    AuditCreateUser,
			    AuditCreateDTM,
			    AuditUpdateUser,
			    AuditUpdateDTM
			)
			VALUES 
			(
				@FreezerSubdivisionID,
				@SubdivisionTypeID,
				@FreezerID,
				@ParentFreezerSubdivisionID,
				@OrganizationID,
				@FreezerSubdivisionEIDSSID,
				@FreezerSubdivisionName,
				@Notes,
				@NumberOfLocations,
				@RowStatus,
				NEWID(),
				NULL,
				NULL,
				@BoxSizeTypeID,
				@BoxPlaceAvailability,
                10519001,
				'[{"idfSubdivision":' + CAST(@FreezerSubdivisionID AS NVARCHAR(300)) + '}]',
				@AuditUser,
				GETDATE(),
				@AuditUser,
				GETDATE()
			);
		END;
		ELSE
		BEGIN
			UPDATE dbo.tlbFreezerSubdivision
			SET idfsSubdivisionType = @SubdivisionTypeID,
				idfFreezer = @FreezerID,
				idfParentSubdivision = @ParentFreezerSubdivisionID,
				idfsSite = @OrganizationID,
				strBarcode = @FreezerSubdivisionEIDSSID,
				strNameChars = @FreezerSubdivisionName,
				strNote = @Notes,
				intCapacity = @NumberOfLocations,
				intRowStatus = @RowStatus,
				BoxSizeID = @BoxSizeTypeID,
				BoxPlaceAvailability = @BoxPlaceAvailability,
                AuditUpdateUser = @AuditUser,
                AuditUpdateDTM = GETDATE()
			WHERE idfSubdivision = @FreezerSubdivisionID;
		END;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
