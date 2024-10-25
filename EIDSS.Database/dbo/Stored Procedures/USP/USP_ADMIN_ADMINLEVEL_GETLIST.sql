-- ================================================================================================
-- Name: USP_ADMIN_ADMINLEVEL_GETLIST
--
-- Description: Get the list of admin level units based on search criteria entered.
--          
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mandar Kulkarni   11292021          Initial release.
-- Manickandan Govindarajan 03/16/2022   Fixed Rayan  National name and Default Name          
-- Manickandan Govindarajan 10/27/2022  Added strSettlementHASC as retrun type         
-- Manickandan Govindarajan 11/09/2022  Added strCode paramter and pulling hascode and strcode for all the levels.
-- Testing Code:
/*

EXEC	[dbo].[USP_ADMIN_ADMINLEVEL_GETLIST]
N'en-US',10003005,NULL,NULL,NULL,NULL,N'BAKU',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,10,NULL,NULL

*/
-- ================================================================================================
CREATE       PROCEDURE [dbo].[USP_ADMIN_ADMINLEVEL_GETLIST] 
(
	@LangId NVARCHAR(20),
	@idfsAdminLevel BIGINT,
	@idfsCountry BIGINT,
	@idfsRegion BIGINT,
	@idfsRayon BIGINT,
	@idfsSettlement BIGINT,
	@strDefaultName NVARCHAR(100),
	@strNationalName NVARCHAR(100),
	@idfsSettlementType BIGINT,
	@LatFrom FLOAT,
	@LatTo FLOAT,
	@LongFrom FLOAT,
	@LongTo FLOAT,
	@ElevationFrom FLOAT,
	@ElevationTo FLOAT,
	@pageNo INT = 1,
	@pageSize INT = 10, 
	@sortColumn NVARCHAR(30) = '', 
	@sortOrder NVARCHAR(4) = 'asc',
	@strHASC NVARCHAR(6) = NULL,
	@strCode NVARCHAR(200) = NULL

)
AS
BEGIN
	BEGIN TRY
		DECLARE @firstRec INT, @lastRec INT,@idfsLangId BIGINT 
		
		SELECT @idfsLangId = idfsBaseReference 
		FROM dbo.trtBaseReference a 
		WHERE a.strBaseReferenceCode = @LangId 
		AND a.idfsReferenceType = 19000049

		DECLARE @Results TABLE
		( 
			idfKey BIGINT PRIMARY KEY IDENTITY(1,1),
			idfsAdministrativeLevel BIGINT,
			idfsCountry BIGINT,
			strCountryHASC NVARCHAR(255),
			strCountryCode NVARCHAR(255),
			strDefaultCountryName NVARCHAR(200),
			strNationalCountryName NVARCHAR(200),
			idfsRegion BIGINT,
			strRegionHASC NVARCHAR(255),
			strRegionCode NVARCHAR(255),
			strDefaultRegionName NVARCHAR(200),
			strNationalRegionName NVARCHAR(200),
			idfsRayon BIGINT,
			strRayonHASC NVARCHAR(255),
			strRayonCode NVARCHAR(255),
			strDefaultRayonName NVARCHAR(200),
			strNationalRayonName NVARCHAR(200),
			idfsSettlement NVARCHAR(200),
			strSettlementHASC NVARCHAR(255),
			strSettlementCode NVARCHAR(255),
			strDefaultSettlementName NVARCHAR(200),
			strNationalSettlementName NVARCHAR(200),
			idfsSettlementType BIGINT,
			strSettlementTypeDefaultName NVARCHAR(200),
			strSettlementTypeNationalName NVARCHAR(200),
			Latitude FLOAT,
			Longitude FLOAT,
			Elevation FLOAT
		)
		IF @idfsAdminLevel = 10003001
			BEGIN
				SET @idfsRegion = NULL
				SET @idfsRayon = NULL
				SET @idfsSettlement = NULL
			END

		IF @idfsAdminLevel = 10003003
			BEGIN
				SET @idfsRayon = NULL
				SET @idfsSettlement = NULL
			END

		IF @idfsAdminLevel = 10003002
			BEGIN
				SET @idfsSettlement = NULL
			END

		-- Populate country names if Administrative Level is for the country
		IF ((@idfsAdminLevel = 10003001 OR @idfsCountry IS NOT NULL) AND (@idfsAdminLevel = 10003001  AND @idfsRegion IS NULL AND @idfsRayon IS NULL AND @idfsSettlement IS NULL))
			OR @idfsAdminLevel IS NULL
			BEGIN 
				INSERT INTO @Results
				(
					idfsAdministrativeLevel,
					idfsCountry,
					strCountryHASC,
					strCountryCode,
					strNationalCountryName,
					strDefaultCountryName
				)
				SELECT @idfsAdminLevel, 
						a.idfsCountry,
						a.strHASC,
						a.strCode,
						c.strTextString,
						b.strDefault
				FROM dbo.gisCountry a
				INNER JOIN dbo.gisBaseReference b ON a.idfsCountry = b.idfsGISBaseReference AND b.intRowStatus = 0 
				INNER JOIN dbo.gisStringNameTranslation c ON b.idfsGISBaseReference = c.idfsGISBaseReference AND b.intRowStatus = 0  AND c.idfsLanguage = @idfsLangId
				WHERE ((@strDefaultName IS NOT NULL AND b.strDefault LIKE '%' + @strDefaultName  + '%')
					OR @strDefaultName IS NULL)
				AND ((@strNationalName IS NOT NULL AND c.strTextString LIKE '%' + @strNationalName + '%')
					OR @strNationalName IS NULL)
				AND (a.idfsCountry = @idfsCountry OR @idfsCountry IS NULL)
				AND (a.strHASC = @strHASC OR @strHASC IS NULL)
				AND (a.strCode = @strCode OR @strCode IS NULL)
			END

		-- Populate region names if Administrative Level is for the region
		IF ((@idfsAdminLevel = 10003003 OR @idfsRegion IS NOT NULL) AND (@idfsAdminLevel = 10003003 AND @idfsRayon IS NULL AND @idfsSettlement IS NULL))
			OR @idfsAdminLevel IS NULL
			BEGIN 
				INSERT INTO @Results
				(
					idfsAdministrativeLevel,
					idfsCountry,
					strCountryHASC,
					strCountryCode,
					strNationalCountryName,
					strDefaultCountryName,
					idfsRegion,
					strRegionHASC,
					strRegionCode,
					strNationalRegionName,
					strDefaultRegionName,
					Longitude,
					Latitude,
					Elevation
				)
				SELECT	@idfsAdminLevel, 
						a.idfsCountry,
						f.strHASC,
						f.strCode,
						e.strTextString,
						d.strDefault,
						a.idfsRegion,
						a.strHASC,
						a.strCode,
						c.strTextString,
						b.strDefault,
						a.dbllongitude,
						a.dbllatitude,
						a.intelevation
				FROM dbo.gisRegion a
				INNER JOIN dbo.gisBaseReference b ON a.idfsRegion = b.idfsGISBaseReference AND b.intRowStatus =0
				INNER JOIN dbo.gisStringNameTranslation c ON b.idfsGISBaseReference = c.idfsGISBaseReference AND c.intRowStatus = 0 AND c.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference d ON a.idfsCountry = d.idfsGISBaseReference AND d.intRowStatus = 0
				INNER JOIN dbo.gisStringNameTranslation e ON d.idfsGISBaseReference = e.idfsGISBaseReference AND e.intRowStatus = 0 AND e.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisCountry f ON a.idfsCountry = f.idfsCountry AND f.intRowStatus =0
				WHERE ((@strDefaultName IS NOT NULL AND b.strDefault LIKE '%' + @strDefaultName  + '%')
					OR @strDefaultName IS NULL)
				AND ((@strNationalName IS NOT NULL AND c.strTextString LIKE '%' + @strNationalName + '%')
					OR @strNationalName IS NULL)
				AND ((a.dblLatitude BETWEEN @LatFrom AND @LatTo) OR (@LatFrom IS NULL AND @LatTo IS NULL))
				AND ((a.dblLongitude BETWEEN @LongFrom AND @LongTo) OR (@LongFrom IS NULL AND @LongTo IS NULL))
				AND ((a.intElevation BETWEEN @ElevationFrom AND @ElevationTo) OR (@ElevationFrom IS NULL AND @ElevationTo IS NULL))
				AND (a.idfsRegion = @idfsRegion OR @idfsRegion IS NULL)
				AND (a.idfsCountry = @idfsCountry OR @idfsCountry IS NULL)
				AND (a.strHASC = @strHASC OR @strHASC IS NULL)
				AND (a.strCode = @strCode OR @strCode IS NULL)
			END

		-- Populate Rayon names if Administrative Level is for the rayon
		IF ((@idfsAdminLevel = 10003002 OR @idfsRayon IS NOT NULL) AND (@idfsAdminLevel = 10003002  AND @idfsSettlement IS NULL)) 
			OR @idfsAdminLevel IS NULL
			BEGIN 
				INSERT INTO @Results
				(
					idfsAdministrativeLevel,
					idfsCountry,
					strCountryHASC,
					strCountryCode,
					strNationalCountryName,
					strDefaultCountryName,
					idfsRegion,
					strRegionHASC,
					strRegionCode,
					strNationalRegionName,
					strDefaultRegionName,
					idfsRayon,
					strRayonHASC,
					strRayonCode,
					strNationalRayonName,
					strDefaultRayonName,
					Latitude,
					Longitude,
					Elevation
				)
				SELECT	@idfsAdminLevel, 
						a.idfsCountry,
						i.strHASC,
						i.strCode,
						e.strTextString,
						d.strDefault,
						a.idfsRegion,
						h.strHASC,
						h.strCode,
						g.strTextString,
						f.strDefault,
						a.idfsRayon,
						a.strHASC,
						a.strCode,
						c.strTextString,
						b.strDefault,
						a.dblLatitude,
						a.dblLongitude,
						a.intElevation
				FROM dbo.gisRayon a
				INNER JOIN dbo.gisBaseReference b ON a.idfsRayon = b.idfsGISBaseReference AND b.intRowStatus =0
				LEFT JOIN dbo.gisStringNameTranslation c ON b.idfsGISBaseReference = c.idfsGISBaseReference AND c.intRowStatus = 0 AND c.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference d ON a.idfsCountry = d.idfsGISBaseReference AND d.intRowStatus = 0
				LEFT JOIN dbo.gisStringNameTranslation e ON d.idfsGISBaseReference = e.idfsGISBaseReference AND e.intRowStatus = 0 AND e.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference f ON a.idfsRegion = f.idfsGISBaseReference AND f.intRowStatus = 0
				LEFT JOIN dbo.gisStringNameTranslation g ON f.idfsGISBaseReference = g.idfsGISBaseReference AND g.intRowStatus = 0 AND g.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisRegion h ON a.idfsRegion = h.idfsRegion AND h.intRowStatus = 0
				INNER JOIN dbo.gisCountry i ON a.idfsCountry = i.idfsCountry AND i.intRowStatus = 0
				WHERE ((@strDefaultName IS NOT NULL AND b.strDefault LIKE '%' + @strDefaultName  + '%') 
					OR @strDefaultName IS NULL)
				AND ((@strNationalName IS NOT NULL AND c.strTextString LIKE '%' + @strNationalName + '%')
					OR @strNationalName IS NULL)
				AND ((a.dblLatitude BETWEEN @LatFrom AND @LatTo) OR (@LatFrom IS NULL AND @LatTo IS NULL))
				AND ((a.dblLongitude BETWEEN @LongFrom AND @LongTo) OR (@LongFrom IS NULL AND @LongTo IS NULL))
				AND ((a.intElevation BETWEEN @ElevationFrom AND @ElevationTo) OR (@ElevationFrom IS NULL AND @ElevationTo IS NULL))
				AND ((a.idfsRayon = @idfsRayon OR @idfsRayon IS NULL)
					AND ((@idfsRegion IS NOT NULL AND a.idfsRegion= @idfsRegion) OR @idfsRegion IS NULL)
					AND ((@idfsCountry IS NOT NULL AND a.idfsCountry = @idfsCountry) OR @idfsCountry IS NULL)
					)
						AND (a.strHASC = @strHASC OR @strHASC IS NULL)
						AND (a.strCode = @strCode OR @strCode IS NULL)
			END

		-- Populate Settlement names if Administrative Level is for the Settlement
		IF (@idfsAdminLevel = 10003004 OR @idfsSettlement IS NOT NULL) OR @idfsAdminLevel IS NULL
			BEGIN 
				INSERT INTO @Results
				(
					idfsAdministrativeLevel,
					idfsCountry,
					strCountryHASC,
					strCountryCode,
					strNationalCountryName,
					strDefaultCountryName,
					idfsRegion,
					strRegionHASC,
					strRegionCode,
					strNationalRegionName,
					strDefaultRegionName,
					idfsRayon,
					strRayonHASC,
					strRayonCode,
					strNationalRayonName,
					strDefaultRayonName,
					idfsSettlement,
					strSettlementHASC,
					strSettlementCode,
					strNationalSettlementName,
					strDefaultSettlementName,
					idfsSettlementType,
					strSettlementTypeNationalName,
					strSettlementTypeDefaultName,
					Latitude,
					Longitude,
					Elevation
				)
				SELECT	@idfsAdminLevel, 
						a.idfsCountry,
						n.strHASC,
						n.strCode,
						e.strTextString,
						d.strDefault,
						a.idfsRegion,
						m.strHASC,
						m.strCode,
						g.strTextString,
						f.strDefault,
						a.idfsRayon,
						l.strHASC,
						l.strCode,
						i.strTextString,
						h.strDefault,
						a.idfsSettlement,
						b.strBaseReferenceCode,
						a.strSettlementCode,
						c.strTextString,
						b.strDefault,
						a.idfsSettlementType,
						k.strTextString,
						j.strDefault,
						a.dblLatitude,
						a.dblLongitude,
						a.intElevation
				FROM dbo.gisSettlement a
				INNER JOIN dbo.gisBaseReference b ON a.idfsSettlement = b.idfsGISBaseReference AND b.intRowStatus =0
				LEFT JOIN dbo.gisStringNameTranslation c ON b.idfsGISBaseReference = c.idfsGISBaseReference AND c.intRowStatus = 0 AND c.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference d ON a.idfsCountry = d.idfsGISBaseReference AND d.intRowStatus = 0
				LEFT JOIN dbo.gisStringNameTranslation e ON d.idfsGISBaseReference = e.idfsGISBaseReference AND e.intRowStatus = 0 AND e.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference f ON a.idfsRegion = f.idfsGISBaseReference AND f.intRowStatus = 0
				LEFT JOIN dbo.gisStringNameTranslation g ON d.idfsGISBaseReference = g.idfsGISBaseReference AND e.intRowStatus = 0 AND g.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference h ON a.idfsRayon = h.idfsGISBaseReference AND h.intRowStatus = 0
				LEFT JOIN dbo.gisStringNameTranslation i ON h.idfsGISBaseReference = i.idfsGISBaseReference AND i.intRowStatus = 0 AND i.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisBaseReference j ON a.idfsSettlementType = j.idfsGISBaseReference AND j.intRowStatus = 0
				LEFT JOIN dbo.gisStringNameTranslation k ON j.idfsGISBaseReference = k.idfsGISBaseReference AND k.intRowStatus = 0 AND k.idfsLanguage = @idfsLangId
				INNER JOIN dbo.gisRayon l ON a.idfsRayon = l.idfsRayon AND l.intRowStatus = 0
				INNER JOIN dbo.gisRegion m ON a.idfsRegion = m.idfsRegion AND m.intRowStatus = 0
				INNER JOIN dbo.gisCountry n ON a.idfsCountry = n.idfsCountry AND n.intRowStatus = 0
				WHERE ((@strDefaultName IS NOT NULL AND b.strDefault LIKE '%' + @strDefaultName  + '%') 
					OR @strDefaultName IS NULL)
				AND ((@strNationalName IS NOT NULL AND c.strTextString LIKE '%' + @strNationalName + '%')
					OR @strNationalName IS NULL)
				AND (a.idfsSettlementType = @idfsSettlementType OR @idfsSettlementType IS NULL)
				AND ((a.dblLatitude BETWEEN @LatFrom AND @LatTo) OR (@LatFrom IS NULL OR @LatTo IS NULL))
				AND ((a.dblLongitude BETWEEN @LongFrom AND @LongTo) OR (@LongFrom IS NULL OR @LongTo IS NULL))
				AND ((a.intElevation BETWEEN @ElevationFrom AND @ElevationTo) OR (@ElevationFrom IS NULL OR @ElevationTo IS NULL))
				AND ((a.idfsSettlement = @idfsSettlement OR @idfsSettlement IS NULL) 
					AND ((@idfsRayon IS NOT NULL AND a.idfsRayon = @idfsRayon) OR @idfsRayon IS NULL)
					AND ((@idfsRegion IS NOT NULL AND a.idfsRegion= @idfsRegion) OR @idfsRegion IS NULL)
					AND ((@idfsCountry IS NOT NULL AND a.idfsCountry = @idfsCountry) OR @idfsCountry IS NULL)
					)
				AND (b.strBaseReferenceCode = @strHASC OR @strHASC IS NULL)
				AND (a.strSettlementCode = @strCode OR @strCode IS NULL)
			END

		SET @firstRec = (@pageNo-1)* @pagesize
		SET @lastRec = (@pageNo*@pageSize+1);
		
		WITH CTEResults AS
		(
			SELECT ROW_NUMBER() OVER ( ORDER BY 
			CASE WHEN @sortColumn = 'strNationalCountryName' AND @SortOrder = 'asc' THEN a.strNationalCountryName END ASC,
			CASE WHEN @sortColumn = 'strNationalCountryName' AND @SortOrder = 'desc' THEN a.strNationalCountryName END DESC,
			CASE WHEN @sortColumn = 'strDefaultCountryName' AND @SortOrder = 'asc' THEN a.strDefaultCountryName END ASC,	
			CASE WHEN @sortColumn = 'strDefaultCountryName' AND @SortOrder = 'desc' THEN a.strDefaultCountryName END DESC,
			CASE WHEN @sortColumn = 'strNationalRegionName' AND @SortOrder = 'asc' THEN a.strNationalRegionName END ASC,	
			CASE WHEN @sortColumn = 'strNationalRegionName' AND @SortOrder = 'desc' THEN a.strNationalRegionName END DESC,
			CASE WHEN @sortColumn = 'strDefaultRegionName' AND @SortOrder = 'asc' THEN a.strDefaultRegionName END ASC,	
			CASE WHEN @sortColumn = 'strDefaultRegionName' AND @SortOrder = 'desc' THEN a.strDefaultRegionName END DESC,
			CASE WHEN @sortColumn = 'strNationalRayonName' AND @SortOrder = 'asc' THEN a.strNationalRayonName END ASC,	
			CASE WHEN @sortColumn = 'strNationalRayonName' AND @SortOrder = 'desc' THEN a.strNationalRayonName END DESC,
			CASE WHEN @sortColumn = 'strDefaultRayonName' AND @SortOrder = 'asc' THEN a.strDefaultRayonName END ASC,	
			CASE WHEN @sortColumn = 'strDefaultRayonName' AND @SortOrder = 'desc' THEN a.strDefaultRayonName END DESC,
			CASE WHEN @sortColumn = 'strNationalSettlementName' AND @SortOrder = 'asc' THEN a.strNationalSettlementName END ASC,	
			CASE WHEN @sortColumn = 'strNationalSettlementName' AND @SortOrder = 'desc' THEN a.strNationalSettlementName END DESC,
			CASE WHEN @sortColumn = 'strDefaultSettlementName' AND @SortOrder = 'asc' THEN a.strDefaultSettlementName END ASC,	
			CASE WHEN @sortColumn = 'strDefaultSettlementName' AND @SortOrder = 'desc' THEN a.strDefaultSettlementName END DESC,
			CASE WHEN @sortColumn = 'strSettlementTypeDefaultName' AND @SortOrder = 'asc' THEN a.strSettlementTypeDefaultName END ASC,	
			CASE WHEN @sortColumn = 'strSettlementTypeDefaultName' AND @SortOrder = 'desc' THEN a.strSettlementTypeDefaultName END DESC,
			CASE WHEN @sortColumn = 'strSettlementTypeNationalName' AND @SortOrder = 'asc' THEN a.strSettlementTypeNationalName END ASC,	
			CASE WHEN @sortColumn = 'strSettlementTypeNationalName' AND @SortOrder = 'desc' THEN a.strSettlementTypeNationalName END DESC,
			CASE WHEN @sortColumn = 'Latitude' AND @SortOrder = 'asc' THEN a.Latitude END ASC,	
			CASE WHEN @sortColumn = 'Latitude' AND @SortOrder = 'desc' THEN a.Latitude END DESC,
			CASE WHEN @sortColumn = 'Longitude' AND @SortOrder = 'asc' THEN a.Longitude END ASC,	
			CASE WHEN @sortColumn = 'Longitude' AND @SortOrder = 'desc' THEN a.Longitude END DESC,
			CASE WHEN @sortColumn = 'Elevation' AND @SortOrder = 'asc' THEN a.elevation END ASC,	
			CASE WHEN @sortColumn = 'Elevation' AND @SortOrder = 'desc' THEN a.elevation END DESC
		) AS ROWNUM,
			COUNT(*) OVER () AS TotalRowCount,
			a.idfsCountry,
			a.strCountryHASC,
			a.strCountryCode,
			a.strNationalCountryName,	
			a.strDefaultCountryName,	
			a.idfsRegion,
			a.strRegionHASC,
			a.strRegionCode,
			a.strNationalRegionName,	
			a.strDefaultRegionName,	
			a.idfsRayon,
			a.strRayonHASC,
			a.strRayonCode,
			a.strNationalRayonName,	
			a.strDefaultRayonName,	
			a.idfsSettlement,
			a.strSettlementHASC,
			a.strSettlementCode,
			a.strNationalSettlementName,	
			a.strDefaultSettlementName,	
			a.idfsSettlementType,
			a.strSettlementTypeDefaultName,	
			a.strSettlementTypeNationalName,	
			a.Latitude,	
			a.Longitude,	
			a.Elevation	
		FROM @Results a
		)

		SELECT 
				TotalRowCount,
				a.idfsCountry,
				a.strCountryHASC,
				a.strCountryCode,
				a.strNationalCountryName,	
				a.strDefaultCountryName,	
				a.idfsRegion,
				a.strRegionHASC,
				a.strRegionCode,
				a.strNationalRegionName,	
				a.strDefaultRegionName,	
				a.idfsRayon,
				a.strRayonHASC,
				a.strRayonCode,
				a.strNationalRayonName,	
				a.strDefaultRayonName,	
				a.idfsSettlement,
				a.strSettlementHASC,
				a.strSettlementCode,
				a.strNationalSettlementName,	
				a.strDefaultSettlementName,	
				a.idfsSettlementType,
				a.strSettlementTypeDefaultName,	
				strSettlementTypeNationalName,	
				a.Latitude,	
				a.Longitude,	
				a.Elevation,	
				TotalPages = (TotalRowCount/@pageSize)+IIF(TotalRowCount%@pageSize>0,1,0),
				CurrentPage = @pageNo 
		FROM CTEResults A
		WHERE a.ROWNUM > @firstRec AND RowNum < @lastRec 	
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END

