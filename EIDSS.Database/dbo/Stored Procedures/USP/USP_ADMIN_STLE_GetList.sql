
--*************************************************************
-- Name 				: USP_ADMIN_STLE_GetList
-- Description			: Get Settlement details
--          
-- Author               : Maheshwar D Deo
-- Revision History
--		Name       Date       Change Detail
-- Ricky Moss	 07/25/2019	  Refactored SP to accommodate API methods
-- Ricky Moss	 09/13/2019	  Added AuditCreateDTM field order by date ordering
-- Ricky Moss	 11/15/2019	  Added parameters to pull a certain number of fields at a time.
-- Ricky Moss    05/18/2020   Resolved Lat Long querying issues
-- Doug Albanese 08/26/2020   Fixed the result set to return for exact search lat/long.
-- Testing code:
-- EXECUTE USP_ADMIN_STLE_GetList 'en', null, null, null, null, null, null, 43.430297, 43.4302979648222, null, null, null, null, 10, 10, 1
--*************************************************************

CREATE  PROCEDURE [dbo].[USP_ADMIN_STLE_GetList] 
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
	,@EleMax				FLOAT = NULL
	,@pageSize				INT = 10 -- Indicates the number of rows that make up a grid page of data.  This value must default to 10 rows per grid page.
	,@maxPagesPerFetch		INT = 10 --Determines the maximum number of pages to return in a single call.  This variable must be defaulted to 10 pages per fetch.
	,@paginationSet			INT = 1 --Specifies the set of data to return.  A set is the maximum pages per fetch (@maxPagesPerFetch) * the page size (@pageSize).  This must default to pagination set 1; so, by default we’ll retrieve the 1st set of data; which is equal to 100 rows.
)
AS 
BEGIN

	BEGIN TRY  	
		DECLARE @LatMinLen						INT
		DECLARE @LatMaxLen						INT
		DECLARE @LngMinLen						INT
		DECLARE @LngMaxLen						INT

		DECLARE @FloatValue						NVARCHAR(MAX)
		DECLARE @decimalIndex					INT
		DECLARE @LatMinDecimalLength			INT
		DECLARE @LngMinDecimalLength			INT
		DECLARE @LatMaxDecimalLength			INT
		DECLARE @LngMaxDecimalLength			INT

		IF @LatMin IS NOT NULL
			BEGIN
				SET @FloatValue = convert(VARCHAR(50), @LatMin,128)
				SET @decimalIndex = CHARINDEX('.',@FloatValue)
				SET @LatMinDecimalLength = LEN(@FloatValue) - @decimalIndex
			END

		IF @LngMin IS NOT NULL
			BEGIN
				SET @FloatValue = convert(VARCHAR(50), @LngMin,128)
				SET @decimalIndex = CHARINDEX('.',@FloatValue)
				SET @LngMinDecimalLength = LEN(@FloatValue) - @decimalIndex
			END

		IF @LatMax IS NOT NULL
			BEGIN
				SET @FloatValue = convert(VARCHAR(50), @LatMax,128)
				SET @decimalIndex = CHARINDEX('.',@FloatValue)
				SET @LatMaxDecimalLength = LEN(@FloatValue) - @decimalIndex
			END

		IF @LngMax IS NOT NULL
			BEGIN
				SET @FloatValue = convert(VARCHAR(50), @LngMax,128)
				SET @decimalIndex = CHARINDEX('.',@FloatValue)
				SET @LngMaxDecimalLength = LEN(@FloatValue) - @decimalIndex
			END

		SELECT * FROM	dbo.FN_ADMIN_STLE_GetList(@LangID) WHERE
			ISNULL(idfsSettlement,'') = IIF(@idfsSettlement IS NOT NULL, @idfsSettlement, ISNULL(idfsSettlement,'')) AND
			ISNULL(idfsSettlementType,'') = IIF(@idfsSettlementType IS NOT NULL, @idfsSettlementType, ISNULL(idfsSettlementType,'')) AND
			ISNULL(SettlementDefaultName, '') LIKE IIF(@DefaultName IS NOT NULL, '%' + @DefaultName + '%', ISNULL(SettlementDefaultName, '')) AND
			ISNULL(SettlementNationalName, '') LIKE IIF(@strNationalName IS NOT NULL, '%' + @strNationalName + '%',ISNULL(SettlementNationalName, '')) AND
			ISNULL(idfsRegion,'') = IIF(@idfsRegion IS NOT NULL, @idfsRegion , ISNULL(idfsRegion,'')) AND
			ISNULL(idfsRayon,'') = IIF(@idfsRayon IS NOT NULL, @idfsRayon , ISNULL(idfsRayon,'')) AND
			(
				(@LatMin IS NULL AND @LatMax IS NULL) OR
				(ROUND(dblLatitude,@LatMinDecimalLength) >= @LatMin AND @LatMax IS NULL) OR
				(@LatMin IS NULL AND ROUND(dblLatitude,@LatMaxDecimalLength) <= @LatMax) OR
				(ROUND(dblLatitude,@LatMinDecimalLength) >= @LatMin AND ROUND(dblLatitude,@LatMaxDecimalLength) <= @LatMax)
			) AND
			(
				(@LngMin IS NULL AND @LngMax IS NULL) OR
				(ROUND(dblLongitude, @LngMinDecimalLength) >= @LngMin AND @LngMax IS NULL) OR
				(@LngMin IS NULL AND ROUND(dblLongitude, @LngMaxDecimalLength) <= @LngMax) OR
				(ROUND(dblLongitude,@LngMinDecimalLength) >= @LngMin AND ROUND(dblLongitude,@LngMaxDecimalLength) <= @LngMax)
			) AND
			(
				(@EleMin IS NULL AND @EleMax IS NULL) OR
				(intElevation >= @EleMin AND @EleMax IS NULL) OR
				(@EleMin IS NULL AND intElevation <= @EleMax) OR
				(intElevation >= @EleMin AND intElevation <= @EleMax)
			)	

		ORDER BY AuditCreateDTM DESC OFFSET(@PageSize * @MaxPagesPerFetch) * (@PaginationSet - 1) ROWS
		FETCH NEXT (@PageSize * @MaxPagesPerFetch) ROWS ONLY;

	END TRY

	BEGIN CATCH
		THROW
	END CATCH

END


