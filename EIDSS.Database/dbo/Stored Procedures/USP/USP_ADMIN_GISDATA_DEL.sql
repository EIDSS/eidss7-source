
-- ================================================================================================
-- Name: USP_ADMIN_GISDATA_DEL
--
-- Description: DELETE GIS Admin Levels.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark WIlson		12/07/2021  Initial release.
-- Mani Govindarajan  11/01/2022 Added condtions to check  if the record is referenced in child table and reference tables         
-- Mani Govindarajan  11/04/2022 Fixed Else condtion issue for settlement         

--          
-- Testing Code:
/*

EXEC dbo.USP_ADMIN_GISDATA_DEL
	@idfsLocation = 3724160000000,
	@UserName = 'PowerUser'

*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_ADMIN_GISDATA_DEL] 
(
	@idfsLocation BIGINT = NULL, -- the location being added or updated
	@userName NVARCHAR(200) = NULL
)
AS

BEGIN

	DECLARE @ReturnCode INT = 0,
			@ReturnMessage NVARCHAR(MAX) = 'SUCCESS',
			@SettlementCount  int =0,
			@RayonCount  int =0,
			@RegionCount  int =0,
			@GeoLocationRefCount  int=0,
			@GeoLocationSharedRefCount  int=0;

	BEGIN TRY

		BEGIN TRANSACTION 

		DECLARE @AdminLevelNode HIERARCHYID

		SELECT @AdminLevelNode = node FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation

		DECLARE @AdminLevel3 TABLE
		(
			
			idfsLocation BIGINT
		)	

		
		DECLARE @AdminLevel4 TABLE
		(
			
			idfsLocation BIGINT
		)	

		-- additional levels will be needed as the database is expanded


-----------------------------------------------------------------------------------------------------------------------------------------
		IF @AdminLevelNode.GetLevel() = 2
		BEGIN

			INSERT INTO @AdminLevel3
			SELECT
				idfsLocation
			FROM dbo.gisLocationDenormalized WHERE Level = 3 AND Level2ID = @idfsLocation

			INSERT INTO @AdminLevel4
			SELECT
				idfsLocation
			FROM dbo.gisLocationDenormalized WHERE Level = 4 AND Level2ID = @idfsLocation
			SELECT @SettlementCount=  COUNT(*) FROM @AdminLevel4;
			SELECT @RayonCount=  COUNT(*) FROM @AdminLevel3;
			select @SettlementCount= count(idfsSettlement)  FROM dbo.gisSettlement WHERE idfsRegion = @idfsLocation and intRowStatus =0
			SELECT @GeoLocationRefCount =count(idfsLocation) FROM dbo.tlbGeoLocation where idfsLocation=@idfsLocation and intRowStatus =0
			SELECT @GeoLocationSharedRefCount =count(idfsLocation) FROM dbo.tlbGeoLocationShared where idfsRegion=@idfsLocation and intRowStatus =0

			if (@RayonCount =0 and @SettlementCount =0 AND @GeoLocationRefCount=0 AND @GeoLocationSharedRefCount=0)
			BEGIN

				DELETE FROM dbo.gisLocation WHERE idfsLocation IN (SELECT * FROM @AdminLevel4)

				DELETE FROM dbo.gisLocation WHERE idfsLocation IN (SELECT * FROM @AdminLevel3)

				DELETE FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation

				DELETE FROM dbo.gisSettlement WHERE idfsRegion = @idfsLocation

				DELETE FROM dbo.gisRayon WHERE idfsRegion = @idfsLocation

				DELETE FROM dbo.gisRegion WHERE idfsRegion = @idfsLocation

				DELETE FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation

				DELETE FROM dbo.gisBaseReference WHERE idfsGISBaseReference IN (SELECT * FROM @AdminLevel4)

				DELETE FROM dbo.gisBaseReference WHERE idfsGISBaseReference IN (SELECT * FROM @AdminLevel3)

				DELETE FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsLocation
			END
			ELSE
			BEGIN
			 set @ReturnCode=-1;
			END

		END

-----------------------------------------------------------------------------------------------------------------------------------------
		IF @AdminLevelNode.GetLevel() = 3
		BEGIN

			INSERT INTO @AdminLevel4
			SELECT
				idfsLocation
			FROM dbo.gisLocationDenormalized WHERE Level = 4 AND Level3ID = @idfsLocation
			--select @SettlementCount= count(idfsSettlement)  FROM dbo.gisSettlement WHERE idfsRegion = @idfsLocation and intRowStatus =0
			SELECT @GeoLocationRefCount =count(idfsLocation) FROM dbo.tlbGeoLocation where idfsLocation=@idfsLocation and intRowStatus =0
			SELECT @GeoLocationSharedRefCount =count(idfsLocation) FROM dbo.tlbGeoLocationShared where idfsRayon=@idfsLocation and intRowStatus =0
			SELECT @SettlementCount=  COUNT(*) FROM @AdminLevel4;
			
			if (@SettlementCount =0 AND @GeoLocationRefCount=0 AND @GeoLocationSharedRefCount=0)
			BEGIN

				DELETE FROM dbo.gisLocation WHERE idfsLocation IN (SELECT * FROM @AdminLevel4)

				DELETE FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation

				DELETE FROM dbo.gisSettlement WHERE idfsRegion = @idfsLocation

				DELETE FROM dbo.gisRayon WHERE idfsRegion = @idfsLocation

				DELETE FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation

				DELETE FROM dbo.gisBaseReference WHERE idfsGISBaseReference IN (SELECT * FROM @AdminLevel4)

				DELETE FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsLocation
			end
			ELSE
			BEGIN
			 set @ReturnCode=-1;
			END

		END

-----------------------------------------------------------------------------------------------------------------------------------------
		IF @AdminLevelNode.GetLevel() = 4
		BEGIN
			SELECT @GeoLocationRefCount =count(idfsLocation) FROM dbo.tlbGeoLocation where idfsLocation=@idfsLocation and intRowStatus =0
			SELECT @GeoLocationSharedRefCount =count(idfsLocation) FROM dbo.tlbGeoLocationShared where idfsSettlement=@idfsLocation and intRowStatus =0
			if ( @GeoLocationRefCount=0 AND @GeoLocationSharedRefCount=0)
			BEGIN

				DELETE FROM dbo.gisLocation WHERE idfsLocation = @idfsLocation

				DELETE FROM dbo.gisSettlement WHERE idfsRegion = @idfsLocation

				DELETE FROM dbo.gisStringNameTranslation WHERE idfsGISBaseReference = @idfsLocation

				DELETE FROM dbo.gisBaseReference WHERE idfsGISBaseReference = @idfsLocation
			END
			ELSE
			BEGIN
			 set @ReturnCode=-1;
			END


		END

		if (@SettlementCount =0 AND @GeoLocationRefCount=0 AND @GeoLocationSharedRefCount=0)
		BEGIN
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION;
		END

		SELECT @ReturnCode ReturnCode
			,@ReturnMessage ReturnMessage
			,@idfsLocation IdfsLocation
			,@SettlementCount SettlementCount
			,@RayonCount RayonCount
			,@RegionCount RegionCount
			,@GeoLocationRefCount GeoLocationRefCount
			,@GeoLocationSharedRefCount GeoLocationSharedRefCount

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		--SELECT @ReturnCode,	@ReturnMessage, @idfsLocation

		THROW;

	END CATCH;

END

