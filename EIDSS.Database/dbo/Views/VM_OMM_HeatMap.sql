
CREATE VIEW [dbo].[VM_OMM_HeatMap]
AS
SELECT
	OutbreakId
	, CaseType
	, DiseaseReportId
	, '[' + TRIM(STR(Latitude, 25, 13)) + ',' + TRIM(STR(Longitude, 25, 13)) + ',''' + CAST(1 AS varChar(100)) + ''']' AS HeatData
FROM
	(SELECT
		TOP (100) PERCENT CaseList.OutbreakId
		, CaseList.CaseType
		, CaseList.DiseaseReportId
		, MAX(dbo.gisSettlement.dblLatitude) AS Latitude
		, MAX(dbo.gisSettlement.dblLongitude) AS Longitude
	FROM
		(SELECT
			'Hum' AS CaseType
			, HumOutbreak.idfOutbreak AS OutbreakId
			, dbo.tlbHumanCase.idfHuman As DiseaseReportId
			, MAX(HumGISSettlement.idfsCountry) AS CountryId
			, MAX(HumGISSettlement.idfsRegion) AS RegionId
			, MAX(HumGISSettlement.idfsRayon) AS RayonId
			, MAX(HumGISSettlement.idfsSettlement) AS SettlementId
		FROM
			dbo.tlbOutbreak (NoLock) AS HumOutbreak
			INNER JOIN dbo.OutbreakCaseReport (NoLock) AS HumOutbreakCaseReport ON 
				 HumOutbreakCaseReport.idfOutbreak = HumOutbreak.idfOutbreak
			INNER JOIN dbo.tlbHumanCase (NoLock) ON 
				dbo.tlbHumanCase.idfHumanCase = HumOutbreakCaseReport.idfHumanCase 
			INNER JOIN dbo.tlbHuman (NoLock) ON 
				dbo.tlbHuman.idfHuman = dbo.tlbHumanCase.idfHuman 
			INNER JOIN dbo.tlbGeoLocation (NoLock) AS HumGeoLocation ON 
				HumGeoLocation.idfGeoLocation = dbo.tlbHuman.idfCurrentResidenceAddress
			INNER JOIN dbo.gisSettlement (NoLock) AS  HumGISSettlement ON
				HumGISSettlement.idfsCountry = HumGeoLocation.idfsCountry
				AND
				HumGISSettlement.idfsRegion = Case IsNull(HumGeoLocation.idfsRegion, 0) When 0 Then HumGISSettlement.idfsRegion Else HumGeoLocation.idfsRegion End
				AND
				HumGISSettlement.idfsRayon = Case IsNull(HumGeoLocation.idfsRayon, 0) When 0 Then HumGISSettlement.idfsRayon Else HumGeoLocation.idfsRayon End
				AND
				HumGISSettlement.idfsSettlement = Case IsNull(HumGeoLocation.idfsSettlement, 0) When 0 Then HumGISSettlement.idfsSettlement Else HumGeoLocation.idfsSettlement End
		GROUP BY 
			HumOutbreak.idfOutbreak
			, dbo.tlbHumanCase.idfHuman

		UNION ALL

		SELECT
			'Vet' AS CaseType
			, VetOutbreak.idfOutbreak As OutbreakId
			, dbo.tlbVetCase.idfVetCase As DiseaseReportId
			, MAX(VetGISSettlement.idfsCountry) AS CountryId
			, MAX(VetGISSettlement.idfsRegion) AS RegionId
			, MAX(VetGISSettlement.idfsRayon) AS RayonId
			, MAX(VetGISSettlement.idfsSettlement) AS SettlementId
		FROM
			dbo.tlbOutbreak AS VetOutbreak
			INNER JOIN dbo.OutbreakCaseReport (NoLock) AS VetOutbreakCaseReport ON 
				VetOutbreakCaseReport.idfOutbreak = VetOutbreak.idfOutbreak
			INNER JOIN dbo.tlbVetCase (NoLock) ON 
				dbo.tlbVetCase.idfVetCase = VetOutbreakCaseReport.idfVetCase 
			INNER JOIN dbo.tlbFarm (NoLock) ON 
				dbo.tlbFarm.idfFarm = dbo.tlbVetCase.idfFarm 
			INNER JOIN dbo.tlbGeoLocation (NoLock) AS VetGeoLocation ON 
				VetGeoLocation.idfGeoLocation = dbo.tlbFarm.idfFarmAddress
			INNER JOIN dbo.gisSettlement (NoLock) VetGISSettlement ON
				VetGISSettlement.idfsCountry = VetGeoLocation.idfsCountry
				AND
				VetGISSettlement.idfsRegion = Case IsNull(VetGeoLocation.idfsRegion, 0) When 0 Then VetGISSettlement.idfsRegion Else VetGeoLocation.idfsRegion End
				AND
				VetGISSettlement.idfsRayon = Case IsNull(VetGeoLocation.idfsRayon, 0) When 0 Then VetGISSettlement.idfsRayon Else VetGeoLocation.idfsRayon End
				AND
				VetGISSettlement.idfsSettlement = Case IsNull(VetGeoLocation.idfsSettlement, 0) When 0 Then VetGISSettlement.idfsSettlement Else VetGeoLocation.idfsSettlement End
		GROUP BY 
			VetOutbreak.idfOutbreak
			, dbo.tlbVetCase.idfVetCase
		) AS CaseList
		INNER JOIN dbo.gisSettlement ON 
			CaseList.CountryId = dbo.gisSettlement.idfsCountry 
			AND 
			CaseList.RegionId = dbo.gisSettlement.idfsRegion 
			AND 
			CaseList.RayonId = dbo.gisSettlement.idfsRayon
			AND 
			CaseList.SettlementId = dbo.gisSettlement.idfsSettlement
		GROUP BY 
			CaseList.OutbreakId
			, CaseList.CaseType
			, CaseList.DiseaseReportId
		) AS HeatTable
