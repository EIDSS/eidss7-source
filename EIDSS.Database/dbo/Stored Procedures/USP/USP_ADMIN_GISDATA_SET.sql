


-- ================================================================================================
-- Name: USP_ADMIN_GISDATA_SET
--
-- Description: Add/Update GIS Admin Levels.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni   11292021          Initial release.
-- Steven Verner	03/16/2022	Wrapped in transaction and initializing @idfsCountry,@idfsRegion and @idfsRayon from denormalized table...
-- Manickandan Govindarajan 03/17/2022 Commented updating node value in gislocation table for update statements in 3 place.
-- Manickandan Govindarajan 11/09/2022 Added strcode for region and rayon levels
--          
-- Testing Code:
/*

-- Move to a new node
EXEC dbo.USP_ADMIN_GISDATA_SET
	@LangID = N'en-US',
	@idfsParent = 1344350000000,
	@strHASC = N'AZORN1',
	@strCode = NULL,
	@idfsLocation = 3724160000000,
	@strDefaultName = 'NewRayon',
	@strNationalName = 'NewRayon',
	@idfsType = NULL,
	@Latitude = NULL,
	@Longitude = NULL,
	@Elevation = NULL,
	@intOrder = 100,
	@UserName = 'PowerUser'



-- add a new location
EXEC dbo.USP_ADMIN_GISDATA_SET
	@LangID = N'en-US',
	@idfsParent = 3723990000000,
	@strHASC = NULL,
	@strCode = 'NewSettlementCode',
	@idfsLocation = NULL,
	@strDefaultName = 'NewSettlement_DF',
	@strNationalName = 'NewSettlement_EN',
	@idfsType = 730120000000,
	@Latitude = 50.3322,
	@Longitude = 40.4219512939453,
	@Elevation = 1000,
	@intOrder = 1,
	@UserName = 'PowerUser'



*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_GISDATA_SET] 
(
		@LangID NVARCHAR(20),
	@idfsParent BIGINT, --  parent location of the location being added
	@strHASC NVARCHAR(6), -- AZ0000, AZBK00, AZBKBK
	@strCode NVARCHAR(200), -- SettlementCode
	@idfsLocation BIGINT = NULL, -- the location being added or updated
	@strDefaultName NVARCHAR(100),
	@strNationalName NVARCHAR(100),
	@idfsType BIGINT  = NULL,
	@Latitude FLOAT = NULL,
	@Longitude FLOAT = NULL,
	@Elevation INT = NULL,
	@intOrder INT = 100,
	@userName NVARCHAR(200) = NULL
)
AS

BEGIN

	DECLARE @ReturnCode INT = 0,
			@ReturnMessage NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY

		BEGIN TRANSACTION gisUpdate

		DECLARE @SupressSelect TABLE
		( 
			retrunCode int,
			returnMessage varchar(200)
		)

		DECLARE @idfsLanguage BIGINT, 
				@SourceSystemKeyValue NVARCHAR(MAX),
				@idfsGISBaseReference BIGINT

		DECLARE @ParentNode HIERARCHYID 
		
		SELECT @ParentNode = node 
		FROM dbo.gisLocation WHERE idfsLocation = @idfsParent
		
		DECLARE @MaxNode HIERARCHYID -- the max node of the Location's level
		DECLARE @NewNode HIERARCHYID -- the max node of the Location's level


		SELECT
			@MaxNode = MAX(node)
		FROM dbo.gisLocation
		WHERE node.GetAncestor(1) = @ParentNode

		SELECT @NewNode = @ParentNode.GetDescendant(@MaxNode, NULL) -- get next available node for insert

		DECLARE @idfsCountry BIGINT,
				@idfsRegion BIGINT,
				@idfsRayon BIGINT

		SELECT @idfsCountry = ld.Level1ID, @idfsRegion =ld.Level2ID, @idfsRayon=ld.Level3ID
		FROM gisLocationDenormalized ld
		WHERE ld.idfsLocation = @idfsParent

		SELECT @idfsLanguage = idfsBaseReference
		FROM dbo.trtBaseReference 
		WHERE strBaseReferenceCode = @LangID
		
-----------------------------------------------------------------------------------------------------------------------------------------
---------- The location is Admin Level 2 (this corresponds to Region in EIDSS6)
		-- If administrative level unit being added or updated is Level 2 (e.g. Region), the Parent is Level 1 (Country)
		IF @ParentNode.GetLevel() = 1  
		BEGIN
			IF EXISTS (SELECT * FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsLocation)
				BEGIN
					UPDATE dbo.gisBaseReference
					SET strDefault = @strDefaultName,
						strBaseReferenceCode = @strHASC,
						intRowStatus = 0,
						intOrder = @intOrder,
						auditUpdateUser = @userName,
						auditUpdateDTM = GETDATE()
					WHERE idfsGISBaseReference = @idfsLocation

					
					-- update a translation
					IF EXISTS(SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation AND idfsLanguage = @idfsLanguage)
					BEGIN
						UPDATE dbo.gisStringNameTranslation
						SET strTextString = @strNationalName,
							intRowStatus = 0,
							auditUpdateUser = @userName,
							auditUpdateDTM = GETDATE()
						WHERE idfsGISBaseReference = @idfsLocation
						AND idfsLanguage = @idfsLanguage
					END

					-- add a new translation
					IF NOT EXISTS(SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation AND idfsLanguage = @idfsLanguage)
					BEGIN
						INSERT INTO dbo.gisStringNameTranslation
						(
						    idfsGISBaseReference,
						    idfsLanguage,
						    strTextString,
						    rowguid,
						    intRowStatus,
						    SourceSystemNameID,
						    SourceSystemKeyValue,
						    AuditCreateUser,
						    AuditCreateDTM,
						    AuditUpdateUser,
						    AuditUpdateDTM
						)
						VALUES
						(   @idfsLocation,
						    @idfsLanguage,
						    @strNationalName,
						    NEWID(),
						    0,
							10519001,
							'[{"idfsGISBaseReference":' + CAST(@idfsLocation AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(@idfsLanguage AS NVARCHAR(24)) + ']',
						    @userName,
						    GETDATE(),
						    @userName,
						    GETDATE()
						    )
					END

					UPDATE dbo.gisLocation
						SET strHASC = @strHASC,
					    strCode=@strCode,
						--node = @NewNode,
						intRowStatus = 0,
						dblLongitude = @Longitude,
						dblLatitude = @Latitude,
						intElevation = @Elevation,
						auditUpdateUser = @userName,
						auditUpdateDTM = GETDATE()
					WHERE idfsLocation = @idfsLocation

					UPDATE dbo.gisRegion
					SET strHASC = @strHASC,
					    strCode = @strCode,
						intRowStatus = 0,
						dblLongitude = @Longitude,
						dblLatitude = @Latitude,
						intElevation = @Elevation,
						auditUpdateUser = @userName,
						auditUpdateDTM = GETDATE()
					WHERE idfsRegion = @idfsLocation
				END
			ELSE
				BEGIN

					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'gisBaseReference', @idfsGISBaseReference OUTPUT;
					
					--SET @idfsGISBaseReference = (SELECT MAX(idfsGISBaseReference) 
					--							FROM dbo.gisBaseReference)

					--EXEC dbo.USP_GBL_GIS_NewID_GET
					--	@ID = @idfsGISBaseReference OUTPUT;

					SET @SourceSystemKeyValue = '[{"idfsGisBaseReference":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]'
					INSERT INTO dbo.gisBaseReference
					(
					    idfsGISBaseReference,
					    idfsGISReferenceType,
					    strBaseReferenceCode,
					    strDefault,
					    intOrder,
					    rowguid,
					    intRowStatus,
					    SourceSystemNameID,
					    SourceSystemKeyValue,
					    AuditCreateUser,
					    AuditCreateDTM
					)
					VALUES
					(   
						@idfsGISBaseReference,
					    19000003,
					    @strHASC,
					    @strDefaultName,
					    @intOrder,
					    NEWID(),
					    0,
					    10519001,
					    '[{"idfsGisBaseReference":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
					    @userName,
					    GETDATE()
					 )

					INSERT INTO dbo.gisStringNameTranslation
					(
					    idfsGISBaseReference,
					    idfsLanguage,
					    strTextString,
					    rowguid,
					    intRowStatus,
					    SourceSystemNameID,
					    SourceSystemKeyValue,
					    AuditCreateUser,
					    AuditCreateDTM
					)
					VALUES
					(   
						@idfsGISBaseReference,
					    @idfsLanguage,
					    @strNationalName,
					    NEWID(),
					    0,
					    10519001,
					    '[{"idfsGISBaseReference":' + CAST(@idfsLocation AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(@idfsLanguage AS NVARCHAR(24)) + ']',
					    @userName,
					    GETDATE()
					)
				
					INSERT INTO dbo.gisRegion
					(
					    idfsRegion,
					    idfsCountry,
					    strHASC,
						strCode,
					    rowguid,
					    intRowStatus,
					    SourceSystemNameID,
					    SourceSystemKeyValue,
						dblLongitude,
						dblLatitude,
						intElevation,
					    AuditCreateUser,
					    AuditCreateDTM
					)
					VALUES
					(   
						@idfsGISBaseReference,
					    @idfsCountry,
					    @strHASC,
						@strCode,
					    NEWID(), 
					    0,
					    10519001,
					    '[{"idfsRegion":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
						@Longitude,
						@Latitude,
						@Elevation,
					    @userName,
					    GETDATE()
					 )

					INSERT INTO dbo.gisLocation
					(
					    idfsLocation,
					    node,
					    strHASC,
						strCode,
					    rowguid,
					    intRowStatus,
					    SourceSystemNameID,
					    SourceSystemKeyValue,
						dblLongitude,
						dblLatitude,
						intElevation,
					    AuditCreateUser,
					    AuditCreateDTM
					)
					VALUES
					(   
						@idfsGISBaseReference,
					    @NewNode,
					    @strHASC,
						@strCode,
					    NEWID(),
					    0,
					    10519001,
					    '[{"idfsLocation":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
						@Longitude,
						@Latitude,
						@Elevation,
					    @userName,
					    GETDATE()
					)
				END 
		END
-----------------------------------------------------------------------------------------------------------------------------------------
---------- The location is Admin Level 3 (this corresponds to Rayon in EIDSS6)
		--
		-- If administrative level unit is Rayon, the parent is Level2 = Region
		ELSE IF @ParentNode.GetLevel() = 2  
		BEGIN
			IF EXISTS (SELECT * FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsLocation)
			BEGIN
				UPDATE dbo.gisBaseReference
				SET strDefault = @strDefaultName,
					strBaseReferenceCode = @strHASC,
					intOrder = @intOrder,
					intRowStatus = 0,
					auditUpdateUser = @userName,
					auditUpdateDTM = GETDATE()
				WHERE idfsGISBaseReference = @idfsLocation

				-- update a translation
				IF EXISTS(SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation AND idfsLanguage = @idfsLanguage)
				BEGIN
					UPDATE dbo.gisStringNameTranslation
					SET strTextString = @strNationalName,
						intRowStatus = 0,
						auditUpdateUser = @userName,
						auditUpdateDTM = GETDATE()
					WHERE idfsGISBaseReference = @idfsLocation
					AND idfsLanguage = @idfsLanguage
				END

				-- add a new translation
				IF NOT EXISTS(SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation AND idfsLanguage = @idfsLanguage)
				BEGIN
					INSERT INTO dbo.gisStringNameTranslation
					(
						idfsGISBaseReference,
						idfsLanguage,
						strTextString,
						rowguid,
						intRowStatus,
						SourceSystemNameID,
						SourceSystemKeyValue,
						AuditCreateUser,
						AuditCreateDTM,
						AuditUpdateUser,
						AuditUpdateDTM
					)
					VALUES
					(   @idfsLocation,
						@idfsLanguage,
						@strNationalName,
						NEWID(),
						0,
						10519001,
						'[{"idfsGISBaseReference":' + CAST(@idfsLocation AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(@idfsLanguage AS NVARCHAR(24)) + ']',
						@userName,
						GETDATE(),
						@userName,
						GETDATE()
						)
				END

				UPDATE dbo.gisLocation
				SET strHASC = @strHASC,
					strCode=@strCode,
					--node = @NewNode,
					intRowStatus = 0,
					dblLongitude = @Longitude,
					dblLatitude = @Latitude,
					intElevation = @Elevation,
					auditUpdateUser = @userName,
					auditUpdateDTM = GETDATE()
				WHERE idfsLocation = @idfsLocation

				UPDATE dbo.gisRayon
				SET strHASC = @strHASC,
					strCode= strCode,
					idfsRegion = @idfsParent,
					intRowStatus = 0,
					dblLongitude = @Longitude,
					dblLatitude = @Latitude,
					intElevation = @Elevation,
					auditUpdateUser = @userName,
					auditUpdateDTM = GETDATE()
				WHERE idfsRayon = @idfsLocation

			END

			ELSE
			BEGIN
			
				INSERT INTO @SupressSelect
				EXEC dbo.USP_GBL_NEXTKEYID_GET 'gisBaseReference', @idfsGISBaseReference OUTPUT;
				
				--SET @idfsGISBaseReference = (SELECT MAX(idfsGISBaseReference) 
				--							FROM dbo.gisBaseReference)
				--EXEC dbo.USP_GBL_GIS_NewID_GET 
				--	@ID = @idfsGISBaseReference OUTPUT;
				
				SET @SourceSystemKeyValue = '[{"idfsGisBaseReference":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]'
				INSERT INTO dbo.gisBaseReference
				(
					idfsGISBaseReference,
					idfsGISReferenceType,
					strBaseReferenceCode,
					strDefault,
					intOrder,
					rowguid,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser,
					AuditCreateDTM
				)
				VALUES
				(   
					@idfsGISBaseReference,
					19000002,
					@strHASC,
					@strDefaultName,
					@intOrder,
					NEWID(),
					0,
					10519001,
					'[{"idfsGisBaseReference":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
					@userName,
					GETDATE()
					)

				INSERT INTO dbo.gisStringNameTranslation
				(
					idfsGISBaseReference,
					idfsLanguage,
					strTextString,
					rowguid,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser,
					AuditCreateDTM
				)
				VALUES
				(   
					@idfsGISBaseReference,
					@idfsLanguage,
					@strNationalName,
					NEWID(),
					0,
					10519001,
					'[{"idfsGISBaseReference":' + CAST(@idfsLocation AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(@idfsLanguage AS NVARCHAR(24)) + ']',
					@userName,
					GETDATE()
				)

				INSERT INTO dbo.gisRayon
				(
					idfsRayon,
					idfsRegion,
					idfsCountry,
					strHASC,
					strCode,
					rowguid,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					dblLongitude,
					dblLatitude,
					intElevation,
					AuditCreateUser,
					AuditCreateDTM
				)
				VALUES
				(   @idfsGISBaseReference,       -- idfsRayon - bigint
					@idfsRegion,       -- idfsRegion - bigint
					@idfsCountry,       -- idfsCountry - bigint
					@strHASC,     -- strHASC - nvarchar(6)
					@strCode,
					NEWID(), -- rowguid - uniqueidentifier
					0, -- intRowStatus - int
					10519001,    -- SourceSystemNameID - bigint
					@SourceSystemKeyValue,    -- SourceSystemKeyValue - nvarchar(max)
					@Longitude,
					@Latitude,
					@Elevation,
					@userName,    -- AuditCreateUser - nvarchar(200)
					GETDATE() -- AuditCreateDTM - datetime
					)

				INSERT INTO dbo.gisLocation
				(
					idfsLocation,
					node,
					strHASC,
					strCode,
					rowguid,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					dblLongitude,
					dblLatitude,
					intElevation,
					AuditCreateUser,
					AuditCreateDTM
				)
				VALUES
				(   @idfsGISBaseReference, -- idfsLocation - bigint
					@NewNode,    -- node - hierarchyid
					@strHASC,    -- strHASC - nvarchar(6)
					@strCode,
					NEWID(), -- rowguid - uniqueidentifier
					0, -- intRowStatus - int
					10519001, -- SourceSystemNameID - bigint
					@SourceSystemKeyValue,    -- SourceSystemKeyValue - nvarchar(200)
					@Longitude,
					@Latitude,
					@Elevation,
					@userName,    -- AuditCreateUser - nvarchar(200)
					GETDATE() -- AuditCreateDTM - datetime
					)
			END 

		END

-----------------------------------------------------------------------------------------------------------------------------------------
---------- The location is Admin Level 4 (this corresponds to Settlement in EIDSS6)
		-- If administrative level unit is Settlement, the Parent is level 3
		ELSE IF @ParentNode.GetLevel() = 3  
		BEGIN
			IF EXISTS (SELECT * FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsLocation)  -- this is an update
			BEGIN
				UPDATE dbo.gisBaseReference
				SET strDefault = @strDefaultName,
					intRowStatus = 0,
					intOrder = @intOrder,
					auditUpdateUser = @userName,
					auditUpdateDTM = GETDATE()
				WHERE idfsGISBaseReference = @idfsLocation

				-- update a translation
				IF EXISTS(SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation AND idfsLanguage = @idfsLanguage)
				BEGIN
					UPDATE dbo.gisStringNameTranslation
					SET strTextString = @strNationalName,
						intRowStatus = 0,
						auditUpdateUser = @userName,
						auditUpdateDTM = GETDATE()
					WHERE idfsGISBaseReference = @idfsLocation
					AND idfsLanguage = @idfsLanguage
				END

				-- add a new translation
				IF NOT EXISTS(SELECT * FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation AND idfsLanguage = @idfsLanguage)
				BEGIN
					INSERT INTO dbo.gisStringNameTranslation
					(
						idfsGISBaseReference,
						idfsLanguage,
						strTextString,
						rowguid,
						intRowStatus,
						SourceSystemNameID,
						SourceSystemKeyValue,
						AuditCreateUser,
						AuditCreateDTM,
						AuditUpdateUser,
						AuditUpdateDTM
					)
					VALUES
					(   @idfsLocation,
						@idfsLanguage,
						@strNationalName,
						NEWID(),
						0,
						10519001,
						'[{"idfsGISBaseReference":' + CAST(@idfsLocation AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(@idfsLanguage AS NVARCHAR(24)) + ']',
						@userName,
						GETDATE(),
						@userName,
						GETDATE()
						)
				END

				UPDATE dbo.gisLocation
				SET strHASC = NULL, -- no HASC data for Level 4 and higher
					idfsType = @idfsType,
					strCode = @strCode,
					--node = @NewNode,
					dblLatitude = @Latitude,
					dblLongitude = @Longitude,
					intElevation = @Elevation,
					intRowStatus = 0,
					auditUpdateUser = @userName,
					auditUpdateDTM = GETDATE()
				WHERE idfsLocation = @idfsLocation

				UPDATE dbo.gisSettlement
				SET idfsRayon = @idfsParent,
					idfsRegion = @idfsRegion,
					idfsSettlementType = @idfsType,
					strSettlementCode = @strCode,
					dblLatitude = @Latitude,
					dblLongitude = @Longitude,
					intRowStatus = 0,
					intElevation = @Elevation,
					auditUpdateUser = @userName,
					auditUpdateDTM = GETDATE()
				WHERE idfsSettlement = @idfsLocation

			END

			ELSE -- This is an insert

				BEGIN

				
					INSERT INTO @SupressSelect
					EXEC dbo.USP_GBL_NEXTKEYID_GET 'gisBaseReference', @idfsGISBaseReference OUTPUT;

				--SET @idfsGISBaseReference = (SELECT MAX(idfsGISBaseReference) 
				--							FROM dbo.gisBaseReference) 
				--EXEC dbo.USP_GBL_GIS_NewID_GET
				--	@ID = @idfsGISBaseReference OUTPUT;

				INSERT INTO dbo.gisBaseReference
				(
					idfsGISBaseReference,
					idfsGISReferenceType,
					strBaseReferenceCode,
					strDefault,
					intOrder,
					rowguid,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser,
					AuditCreateDTM
				)
				VALUES
				(   
					@idfsGISBaseReference,
					19000004,
					NULL,
					@strDefaultName,
					@intOrder,
					NEWID(),
					0,
					10519001,
					'[{"idfsGisBaseReference":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
					@userName,
					GETDATE()
					)


				INSERT INTO dbo.gisStringNameTranslation
				(
					idfsGISBaseReference,
					idfsLanguage,
					strTextString,
					rowguid,
					intRowStatus,
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateUser,
					AuditCreateDTM
				)
				VALUES
				(   
					@idfsGISBaseReference,
					@idfsLanguage,
					@strNationalName,
					NEWID(),
					0,
					10519001,
					'[{"idfsGISBaseReference":' + CAST(@idfsLocation AS NVARCHAR(24)) + '}, "idfsLanguage":' + CAST(@idfsLanguage AS NVARCHAR(24)) + ']',
					@userName,
					GETDATE()
				)

					INSERT INTO dbo.gisSettlement
					(
					    idfsSettlement,
					    idfsSettlementType,
					    idfsCountry,
					    idfsRegion,
					    idfsRayon,
					    strSettlementCode,
					    dblLongitude,
					    dblLatitude,
					    rowguid,
					    intRowStatus,
					    intElevation,
					    SourceSystemNameID,
					    SourceSystemKeyValue,
					    AuditCreateUser,
					    AuditCreateDTM
					)
					VALUES
					(   @idfsGISBaseReference, -- idfsSettlement - bigint
					    @idfsType,       -- idfsSettlementType - bigint
					    @idfsCountry,       -- idfsCountry - bigint
					    @idfsRegion,       -- idfsRegion - bigint
					    @idfsRayon,       -- idfsRayon - bigint
					    @strCode,    -- strSettlementCode - nvarchar(200)
					    @Longitude,    -- dblLongitude - float
					    @Latitude,    -- dblLatitude - float
					    NEWID(), -- rowguid - uniqueidentifier
					    0, -- intRowStatus - int
					    @Elevation,    -- intElevation - int
					    10519001,    -- SourceSystemNameID - bigint
						'[{"idfsSettlement":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
					    @userName,    -- AuditCreateUser - nvarchar(200)
					    GETDATE() -- AuditCreateDTM - datetime
					    )		

					INSERT INTO dbo.gisLocation
					(
					    idfsLocation,
					    node,
						idfsType,
						strCode,
						dblLatitude,
						dblLongitude,
						intElevation,
					    rowguid,
					    intRowStatus,
					    SourceSystemNameID,
					    SourceSystemKeyValue,
					    AuditCreateUser,
					    AuditCreateDTM
					)
					VALUES
					(   @idfsGISBaseReference,
					    @NewNode,
					    @idfsType,
						@strCode,
						@Latitude,
						@Longitude,
						@Elevation,
					    NEWID(),
					    0,
					    10519001,
						'[{"idfsLocation":' + CAST(@idfsGISBaseReference AS NVARCHAR(MAX) )+'}]',
					    @userName,
					    GETDATE()
					    )
				END 
		END

		COMMIT TRANSACTION gisUpdate;

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage
			,@idfsGISBaseReference idfsGISBaseReference
		

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION gisUpdate;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,	@ReturnMessage, @idfsGISBaseReference

		THROW;

	END CATCH;

END

