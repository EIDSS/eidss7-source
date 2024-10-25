
--*************************************************************
-- Name 				: [USP_HUMAN_DISEASE_GEOLOCATION_SET]
-- Description			: Set Address
--          
-- Author               : Lamont Mitchell
-- Revision History
--		Name       Date       Change Detail
--
--    LJM			3/17/2020	Initial taken from GLOBAL changed parameters , removed new key generation. Expected to be passed in from calling procedure.
								--Re factored conditional logic
-- Testing code:

/*
--Example of a call of procedure:
DECLARE @idfGeoLocation BIGINT
DECLARE @idfsGroundType BIGINT
DECLARE @idfsGeoLocationType BIGINT
DECLARE @idfsCountry BIGINT
DECLARE @idfsRegion BIGINT
DECLARE @idfsRayon BIGINT
DECLARE @idfsSettlement BIGINT
DECLARE @strDescription NVARCHAR(200)
DECLARE @dblDistance FLOAT
DECLARE @dblLatitude FLOAT
DECLARE @dblLongitude FLOAT
DECLARE @dblAccuracy FLOAT
DECLARE @dblAlignment FLOAT
declare @blnGeoLocationShared bit

-- TODO: Set parameter values here.

EXECUTE dbo.USP_GBL_GEOLOCATION_SET
   @idfGeoLocation
  ,@idfsGroundType
  ,@idfsGeoLocationType
  ,@idfsCountry
  ,@idfsRegion
  ,@idfsRayon
  ,@idfsSettlement
  ,@strDescription
  ,@dblDistance
  ,@dblLatitude
  ,@dblLongitude
  ,@dblAccuracy
  ,@dblAlignment
  ,@blnGeoLocationShared
*/


CREATE   PROCEDURE [dbo].[USP_HUMAN_DISEASE_GEOLOCATION_SET]
(
	 @idfGeoLocation		BIGINT --##PARAM idfGeoLocation - ID of geolocation record
    ,@idfsGroundType		BIGINT --##PARAM idfsGroundType - ID of ground Type for relative location
    ,@idfsGeoLocationType	BIGINT --##PARAM idfsGeoLocationType - ID geolocation Type (can point to ExactPoint or Relative geolocation Type
    ,@idfsCountry			BIGINT --##PARAM idfsCountry - ID of country
    ,@idfsRegion			BIGINT --##PARAM idfsRegion - ID of region
    ,@idfsRayon				BIGINT --##PARAM idfsRayon - ID rayon
    ,@idfsSettlement		BIGINT --##PARAM idfsSettlement - ID of settlement (for Relative location only)
    ,@strDescription		NVARCHAR(200) --##PARAM strDescription - free text description of reolocation record
    ,@dblLatitude			FLOAT --##PARAM dblLatitude - Latitude (for ExactPoint location only)
    ,@dblLongitude			FLOAT --##PARAM dblLongitude  - Longitude (for ExactPoint location only)
    ,@dblAccuracy			FLOAT --##PARAM dblAccuracy - Accuracy of all other numeric data in the geolocation record
    ,@dblDistance			FLOAT --##PARAM dblDistance - distance (in kilometers) from settlement to relative point (for Relative location only)
    ,@dblAlignment			FLOAT --##PARAM dblAlignment - azimuth (in degrees) of direction from settlement to relative point(for Relative location only)
    ,@strForeignAddress 	NVARCHAR(200)
    ,@blnGeoLocationShared 	BIT = 0
	,@dblElevation          FLOAT = NULL  --##PARAM dbElevation - Elevation (for ExactPoint location only)
	,@AuditUser				NVARCHAR(100) = ''
)
AS
DECLARE @returnCode			INT = 0;
DECLARE @returnMsg			NVARCHAR(max) = 'SUCCESS'
DECLARE @strAddressString	NVARCHAR(max)
DECLARE @idfsLocation BIGINT = COALESCE(@idfsSettlement, @idfsRayon, @idfsRegion, @idfsCountry)
BEGIN
	BEGIN TRY

			IF EXISTS(SELECT * FROM dbo.tlbGeoLocation WHERE idfGeoLocation = @idfGeoLocation)
				BEGIN
						UPDATE [dbo].[tlbGeoLocation]
						SET [idfsGroundType] = @idfsGroundType
							,[idfsGeoLocationType] = @idfsGeoLocationType
							,[idfsCountry] = @idfsCountry
							,[idfsRegion] = @idfsRegion
							,[idfsRayon] = @idfsRayon
							,[idfsSettlement] = @idfsSettlement
							,[idfsLocation] = @idfsLocation
							,[strDescription] = @strDescription
							,[dblDistance] = @dblDistance
							,[dblLatitude] = @dblLatitude 
							,[dblLongitude] = @dblLongitude 
							,[dblAccuracy] = @dblAccuracy
							,[dblAlignment] = @dblAlignment
							,strForeignAddress = @strForeignAddress
							,blnForeignAddress = CASE WHEN @idfsGeoLocationType = 10036001 THEN 1 ELSE 0 END
							,dblElevation = @dblElevation
							,AuditUpdateUser = @AuditUser
						 WHERE idfGeoLocation = @idfGeoLocation
				END
			ELSE
				BEGIN
					INSERT INTO tlbGeoLocation
								(
									idfGeoLocation
									,idfsGroundType
									,idfsGeoLocationType
									,idfsCountry
									,idfsRegion
									,idfsRayon
									,idfsSettlement
									,idfsLocation
									,strDescription
									,dblDistance
									,dblLatitude
									,dblLongitude
									,dblAccuracy
									,dblAlignment
									,strForeignAddress
									,blnForeignAddress
									,dblElevation
									,AuditCreateUser
								)
							VALUES
								(
									@idfGeoLocation
									,@idfsGroundType
									,@idfsGeoLocationType
									,@idfsCountry
									,@idfsRegion
									,@idfsRayon
									,@idfsSettlement
									,@idfsLocation
									,@strDescription
									,@dblDistance
									,@dblLatitude 
									,@dblLongitude 
									,@dblAccuracy
									,@dblAlignment
									,@strForeignAddress
									,CASE WHEN @idfsGeoLocationType = 10036001 THEN 1 ELSE 0 END
									,@dblElevation
									,@AuditUser
								)
				END

			SELECT @returnCode, @returnMsg, @idfGeoLocation
	END TRY
	BEGIN CATCH
		  SET @returnCode = ERROR_NUMBER()
		  SET @returnMsg = ERROR_MESSAGE()

		  SELECT @returnCode, @returnMsg,@idfGeoLocation
	END CATCH
END
