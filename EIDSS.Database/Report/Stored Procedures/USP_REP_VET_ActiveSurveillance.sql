-- ================================================================================================
-- Name: USP_REP_VET_ActiveSurveillance
--
-- Description: Generate dataset for the Active Surveillance Report.
--          
-- Revision History:
-- Name             Date       Change Detail
-- Mark Wilson		10/25/2021 Original code to revert back to multi disease
-- Mark Wilson		08/09/2022 updated to return # Samples as Sampled #
-- Mark Wilson		10/07/2022 updated to return # Samples root
-- Mani Govindarajan 10/17/2022 Added distct in the DetailCount 
/*
--Example of a call of procedure:

exec report.USP_REP_VET_ActiveSurveillance  'en-US', '2021'

*/

CREATE  PROCEDURE [Report].[USP_REP_VET_ActiveSurveillance]
(
	@LangID NVARCHAR(10),
    @Year INT,
    @UseArchiveData	AS BIT = 0 --if User selected Use Archive Data then 1
)
AS
BEGIN
	IF OBJECT_ID('tempdb.dbo.#ReportTable') IS NOT NULL
	DROP TABLE #ReportTable
	
	CREATE TABLE #ReportTable	
	(	
		idfReportRow	BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		idfsDiagnosis	BIGINT NOT NULL,
		strDiagnosis	NVARCHAR(2000) COLLATE database_default NULL,
		idfsSpeciesType	BIGINT NOT NULL,
		strSpeciesType	NVARCHAR(2000) COLLATE database_default NULL,
		intPlanned		BIGINT NULL,
		intSampled		BIGINT NULL
	)

	IF ((ISNULL(@Year, 0) >= 1900) AND (ISNULL(@Year, 0) <= YEAR(GETDATE()) + 1))
	BEGIN

		DECLARE @Campaigns	TABLE
		(	
			idfCampaign BIGINT NOT NULL PRIMARY KEY
		)
		
		DECLARE	@Sessions TABLE
		(	
			idfMonitoringSession BIGINT NOT NULL PRIMARY KEY
		)
		
		declare	@SampledValuesFromSummary	table
		(	
			idfReportRow BIGINT NOT NULL PRIMARY KEY,
			idfsDisease	BIGINT,
			idfsSpecies BIGINT,
			intSampled BIGINT NOT NULL
		)
		
		DECLARE @SampledValuesFromDetail TABLE
		(	
			idfReportRow BIGINT NOT NULL PRIMARY KEY,
			idfsDisease	BIGINT,
			idfsSpecies BIGINT,
			intSampled BIGINT NOT NULL
		)

		INSERT INTO @Campaigns	
		(
			idfCampaign
		)
		SELECT
			c.idfCampaign
		FROM dbo.tlbCampaign c
		WHERE ((c.datCampaignDateStart IS NOT NULL AND c.datCampaignDateEnd IS NOT NULL AND YEAR(dateadd(ss, datediff(ss, c.datCampaignDateStart, c.datCampaignDateEnd) / 2, c.datCampaignDateStart)) = @Year)
						OR (c.datCampaignDateStart IS NOT NULL AND c.datCampaignDateEnd IS NULL AND YEAR(c.datCampaignDateStart) = @Year)
						OR (c.datCampaignDateStart IS NULL AND c.datCampaignDateEnd IS NOT NULL AND YEAR(c.datCampaignDateEnd) = @Year))
		AND c.intRowStatus = 0
		AND c.CampaignCategoryID in (10501002)


		INSERT INTO	@Sessions	(idfMonitoringSession)
		SELECT
			ms.idfMonitoringSession
		FROM dbo.tlbMonitoringSession ms
		INNER JOIN dbo.tlbCampaign c ON c.idfCampaign = ms.idfCampaign AND c.intRowStatus = 0
		INNER JOIN @Campaigns c_selected ON c_selected.idfCampaign = ms.idfCampaign
		WHERE ms.intRowStatus = 0
		AND ms.SessionCategoryID in (10502002,10502009)


		INSERT INTO	@Sessions (idfMonitoringSession)
		SELECT
			ms.idfMonitoringSession
		FROM dbo.tlbMonitoringSession ms
		LEFT JOIN dbo.tlbCampaign c ON c.idfCampaign = ms.idfCampaign AND c.intRowStatus = 0 AND c.CampaignCategoryID = 10501002
		WHERE ((ms.datStartDate IS NOT NULL AND	ms.datEndDate IS NOT NULL AND YEAR(DATEADD(ss, DATEDIFF(ss, ms.datStartDate, ms.datEndDate) / 2, ms.datStartDate)) = @Year)
						OR (ms.datStartDate IS NOT NULL AND	ms.datEndDate IS NULL AND YEAR(ms.datStartDate) = @Year)
						OR (ms.datStartDate IS NULL AND ms.datEndDate IS NOT NULL AND YEAR(ms.datEndDate) = @Year))
		AND ms.intRowStatus = 0
		AND c.idfCampaign IS NULL
        AND ms.SessionCategoryID in (10502002,10502009)

		insert into	#ReportTable
		(	
			idfsDiagnosis,
			strDiagnosis,
			idfsSpeciesType,
			strSpeciesType,
			intPlanned
		)
		SELECT
			cd.idfsDiagnosis,
			ISNULL(d.[name], N''),
			st.idfsReference,
			ISNULL(st.[name], N''),
			SUM(ISNULL(cd.intPlannedNumber, 0))

		FROM dbo.tlbCampaignToDiagnosis cd
		INNER JOIN dbo.tlbCampaign c ON c.idfCampaign = cd.idfCampaign AND c.intRowStatus = 0
		INNER JOIN @Campaigns c_selected ON c_selected.idfCampaign = c.idfCampaign
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) d ON d.idfsReference = cd.idfsDiagnosis
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) st ON st.idfsReference = cd.idfsSpeciesType
		WHERE cd.intRowStatus = 0
		GROUP BY
			cd.idfsDiagnosis,
			ISNULL(d.[name], N''),
			st.idfsReference,
			ISNULL(st.[name], N'')

		UPDATE rt
		SET rt.intPlanned = NULL
        FROM #ReportTable rt
		left join (	dbo.tlbCampaignToDiagnosis cd
					INNER JOIN dbo.tlbCampaign c ON c.idfCampaign = cd.idfCampaign AND c.intRowStatus = 0
					INNER JOIN @Campaigns c_selected ON c_selected.idfCampaign = c.idfCampaign
					INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) d ON d.idfsReference = cd.idfsDiagnosis
					INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) st ON st.idfsReference = cd.idfsSpeciesType
					) ON cd.idfsDiagnosis = rt.idfsDiagnosis
					and ISNULL(st.idfsReference, 0) = ISNULL(rt.idfsSpeciesType, 0)
					and cd.intRowStatus = 0
					and cd.intPlannedNumber IS NOT NULL
		WHERE cd.idfCampaignToDiagnosis IS NULL


		INSERT INTO #ReportTable
		(	
			idfsDiagnosis,
			strDiagnosis,
			idfsSpeciesType,
			strSpeciesType,
			intPlanned,
			intSampled
		)
		SELECT 
			DISTINCT msd.idfsDiagnosis,
			ISNULL(d.[name], N''),
			st.idfsReference,
			ISNULL(st.[name], N''),
			NULL,
			NULL

		FROM dbo.tlbMonitoringSessionToDiagnosis msd
		INNER JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = msd.idfMonitoringSession AND ms.intRowStatus = 0
		INNER JOIN @Sessions s_selected ON s_selected.idfMonitoringSession = ms.idfMonitoringSession
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) d ON d.idfsReference = msd.idfsDiagnosis
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) st ON st.idfsReference = msd.idfsSpeciesType
		LEFT JOIN #ReportTable rt ON rt.idfsDiagnosis = msd.idfsDiagnosis AND ISNULL(rt.idfsSpeciesType, 0) = ISNULL(st.idfsReference, 0)
		WHERE msd.intRowStatus = 0
		AND rt.idfReportRow is null

		-- aggregate numbers
		INSERT INTO @SampledValuesFromSummary
		(	
			idfReportRow,
			idfsDisease,
			idfsSpecies,
			intSampled
			
		)
		SELECT	
			rt.idfReportRow,
			rt.idfsDiagnosis,
			rt.idfsSpeciesType,
			SUM(ISNULL(mss.intSamplesQty, 0))

		FROM dbo.tlbMonitoringSessionToDiagnosis msd
		INNER JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = msd.idfMonitoringSession AND ms.intRowStatus = 0
		INNER JOIN @Sessions s_selected ON s_selected.idfMonitoringSession = ms.idfMonitoringSession
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) d ON d.idfsReference = msd.idfsDiagnosis
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) st	ON st.idfsReference = msd.idfsSpeciesType
		INNER JOIN #ReportTable rt ON rt.idfsDiagnosis = msd.idfsDiagnosis AND ISNULL(rt.idfsSpeciesType, 0) = ISNULL(st.idfsReference, 0)
		INNER JOIN dbo.tlbMonitoringSessionSummary mss
				INNER JOIN dbo.tlbSpecies s ON s.idfSpecies = ISNULL(mss.idfSpecies, 0) AND s.intRowStatus = 0
				INNER JOIN dbo.tlbHerd h ON h.idfHerd = s.idfHerd AND h.idfFarm = mss.idfFarm AND h.intRowStatus = 0
				INNER JOIN dbo.tlbFarm f ON f.idfFarm = h.idfFarm AND f.intRowStatus = 0
				ON mss.idfMonitoringSession = ms.idfMonitoringSession AND s.idfsSpeciesType = ISNULL(rt.idfsSpeciesType, 0)
				AND mss.intRowStatus = 0 AND mss.intSampledAnimalsQty IS NOT NULL
		WHERE msd.intRowStatus = 0
		GROUP BY rt.idfReportRow,rt.idfsDiagnosis,rt.idfsSpeciesType

		INSERT INTO	@SampledValuesFromDetail
		(	
			idfReportRow,
			idfsDisease,
			idfsSpecies,
			intSampled
		)
		SELECT
			rt.idfReportRow,
			rt.idfsDiagnosis,
			rt.idfsSpeciesType,
			COUNT(distinct M.idfMaterial)

		FROM dbo.tlbMonitoringSessionToDiagnosis msd
		INNER JOIN dbo.tlbMonitoringSession ms ON ms.idfMonitoringSession = msd.idfMonitoringSession AND ms.intRowStatus = 0
		INNER JOIN @Sessions s_selected ON s_selected.idfMonitoringSession = ms.idfMonitoringSession
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) d ON d.idfsReference = msd.idfsDiagnosis
		INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000086) st ON st.idfsReference = msd.idfsSpeciesType
		INNER JOIN #ReportTable rt ON rt.idfsDiagnosis = msd.idfsDiagnosis AND rt.idfsSpeciesType = st.idfsReference
		INNER JOIN dbo.tlbMaterial M ON M.idfMonitoringSession = ms.idfMonitoringSession AND M.idfParentMaterial IS NULL AND M.intRowStatus = 0 AND M.idfsSampleType = msd.idfsSampleType
		INNER JOIN dbo.tlbSpecies S ON S.idfSpecies = M.idfSpecies AND S.idfsSpeciesType = RT.idfsSpeciesType AND S.intRowStatus = 0
		
		WHERE msd.intRowStatus = 0
		
		GROUP BY rt.idfReportRow, rt.idfsDiagnosis, rt.idfsSpeciesType

		UPDATE rt
		SET rt.intSampled = sv_s.intSampled
		FROM #ReportTable rt
		INNER JOIN @SampledValuesFromSummary sv_s ON sv_s.idfReportRow = rt.idfReportRow


		UPDATE rt
		SET rt.intSampled = rt.intSampled + sv_d.intSampled
		FROM #ReportTable rt
		INNER JOIN @SampledValuesFromDetail sv_d ON sv_d.idfReportRow = rt.idfReportRow
		WHERE rt.intSampled IS NOT NULL


		UPDATE rt
		SET rt.intSampled = sv_d.intSampled
		FROM #ReportTable rt
		INNER JOIN @SampledValuesFromDetail sv_d ON sv_d.idfReportRow = rt.idfReportRow
		WHERE rt.intSampled IS NULL

	END


	SELECT
		idfsDiagnosis,
		strDiagnosis,
		idfsSpeciesType,
		strSpeciesType,
		ISNULL(intPlanned,0) intPlanned,
		ISNULL(intSampled,0) intSampled

	FROM #ReportTable

	ORDER BY
		strDiagnosis,
		idfsDiagnosis,
		strSpeciesType,
		idfsSpeciesType
				
END
GO
