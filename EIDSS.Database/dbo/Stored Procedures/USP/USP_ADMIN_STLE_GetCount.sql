
--*************************************************************
-- Name 				: USP_ADMIN_STLE_GetCount
-- Description			: Get Settlement details
--          
-- Author               : Ricky Moss
--
-- Revision History
--		Name       Date       Change Detail
-- Ricky Moss	 11/19/2019	  Initial Release
-- Ricky Moss    05/18/2020   Resolved Lat Long querying issues

-- Testing code:
-- EXECUTE USP_ADMIN_STLE_GetCount 'en', null, null, null, null, NULL, NULL, NULL, NULL, NULL, NULL, null, null
--*************************************************************

CREATE  PROCEDURE [dbo].[USP_ADMIN_STLE_GetCount] 
(
	 @LangID				NVARCHAR(50) --##PARAM @LangID - language ID
	,@idfsSettlement		BIGINT = NULL
	,@idfsSettlementType	BIGINT = NULL
	,@DefaultName           NVARCHAR(100) = NULL 
	,@strNationalName		NVARCHAR(100) = NULL
	,@idfsRegion			BIGINT = NULL
	,@idfsRayon				BIGINT = NULL
	,@LatMin				FLOAT = NULL
	,@LatMax				FLOAT = NULL
	,@LngMin				FLOAT = NULL
	,@LngMax				FLOAT = NULL
	,@EleMin				FLOAT = NULL
	,@EleMax				FLOAT = NULL)
AS 
BEGIN

	BEGIN TRY  	
		SELECT COUNT(*) as SettlementCount FROM	dbo.FN_ADMIN_STLE_GetList(@LangID) WHERE
			ISNULL(idfsSettlement,'') = IIF(@idfsSettlement IS NOT NULL, @idfsSettlement, ISNULL(idfsSettlement,'')) AND
			ISNULL(idfsSettlementType,'') = IIF(@idfsSettlementType IS NOT NULL, @idfsSettlementType, ISNULL(idfsSettlementType,'')) AND
			ISNULL(SettlementDefaultName, '') LIKE IIF(@DefaultName IS NOT NULL, '%' + @DefaultName + '%', ISNULL(SettlementDefaultName, '')) AND
			ISNULL(SettlementNationalName, '') LIKE IIF(@strNationalName IS NOT NULL, '%' + @strNationalName + '%',ISNULL(SettlementNationalName, '')) AND
			ISNULL(idfsRegion,'') = IIF(@idfsRegion IS NOT NULL, @idfsRegion , ISNULL(idfsRegion,'')) AND
			ISNULL(idfsRayon,'') = IIF(@idfsRayon IS NOT NULL, @idfsRayon , ISNULL(idfsRayon,'')) AND
			(
				(@LatMin IS NULL AND @LatMax IS NULL) OR
				(dblLatitude >= @LatMin AND @LatMax IS NULL) OR
				(@LatMin IS NULL AND dblLatitude <= @LatMax) OR
				(dblLatitude >= @LatMin AND dblLatitude <= @LatMax)
			) AND
			(
				(@LngMin IS NULL AND @LngMax IS NULL) OR
				(dblLongitude >= @LngMin AND @LngMax IS NULL) OR
				(@LngMin IS NULL AND dblLongitude <= @LngMax) OR
				(dblLongitude >= @LngMin AND dblLongitude <= @LngMax)
			) AND
			(
				(@EleMin IS NULL AND @EleMax IS NULL) OR
				(intElevation >= @EleMin AND @EleMax IS NULL) OR
				(@EleMin IS NULL AND intElevation <= @EleMax) OR
				(intElevation >= @EleMin AND intElevation <= @EleMax)
			)	
	END TRY

	BEGIN CATCH
		THROW
	END CATCH

END


