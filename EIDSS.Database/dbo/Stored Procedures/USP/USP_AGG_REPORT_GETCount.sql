
-- ================================================================================================
-- Name:  USP_AGG_REPORT_GETCount
--
-- Description:  Returns list of aggregate reports depending on case type.
--          
-- Revision History:
-- Name                Date       Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Stephen Long        07/01/2019 Initital release.
-- Stephen Long        07/09/2019 Updated gis string translation joins to match get list.
-- Stephen Long        08/05/2019 Added total count.
-- Stephen Long        08/08/2019 Added entered by person name.
-- Stephen Long        08/13/2019 Corrected administrative unit type id values.
-- Stephen Long        10/02/2019 Changed administrative where clause; reference TFS item
-- Stephen Long        01/22/2020 Added site list parameter for site filtration.
-- Stephen Long        02/18/2020 Added non-configurable site filtration rules.
--
-- Testing code:
--
-- Legends
/*
	Case Type
	AggregateCase = 10102001
	VetAggregateCase = 10102002
	VetAggregateAction = 10102003

Statistic period types
    None = 0
    Month = 10091001
    Day = 10091002
    Quarter = 10091003
    Week = 10091004
    Year = 10091005

StatisticAreaType
    None = 0
    Country = 10089001
    Rayon = 10089002
    Region = 10089003
    Settlement = 10089004
Aggregate Case Type
    HumanAggregateCase = 10102001
    VetAggregateCase = 10102002
    VetAggregateAction = 10102003
	exec USP_AGG_CASE_GETLIST 'en', @idfsAggrCaseType=10102001
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_AGG_REPORT_GETCount] (
	@LanguageID AS NVARCHAR(50),
	@AggregateReportTypeID AS BIGINT = NULL,
	@EIDSSReportID AS NVARCHAR(400) = NULL,
	@TimeIntervalTypeID AS BIGINT = NULL,
	@StartDate AS DATETIME = NULL,
	@EndDate AS DATETIME = NULL,
	@AdministrativeUnitID AS BIGINT = NULL,
	@OrganizationID BIGINT = NULL,
	@SiteList VARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS',
		@ReturnCode BIGINT = 0;
	DECLARE @IDs TABLE (ID BIGINT NOT NULL);

	BEGIN TRY
		-- =======================================================================================
		-- Apply non-configurable/default filtration rules.
		-- =======================================================================================
		--
		-- Aggregate disease report data shall be available to all sites' organizations 
		-- connected to the particular report.
		--
		DECLARE @SiteOrganizationList VARCHAR(MAX) = '';

		SELECT @SiteOrganizationList = @SiteOrganizationList + ',' + CAST(o.idfOffice AS VARCHAR)
		FROM dbo.tlbOffice o
		WHERE (
				o.idfsSite IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
					)
				OR (@SiteList IS NULL)
				);

		SET @SiteOrganizationList = SUBSTRING(@SiteOrganizationList, 2, LEN(@SiteOrganizationList));

		-- Entered by and notification received by and sent to organizations
		INSERT INTO @IDs
		SELECT a.idfAggrCase
		FROM dbo.tlbAggrCase a
		WHERE (a.intRowStatus = 0)
			AND (
				a.idfEnteredByOffice IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')
					)
				OR a.idfReceivedByOffice IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')
					)
				OR a.idfSentByOffice IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')
					)
				);

		--
		-- Aggregate disease report data shall be available to all sites of the same 
		-- administrative rayon.
		--
		-- Rayon of the report administrative unit.
		DECLARE @SiteRayonList VARCHAR(MAX) = '';

		SELECT @SiteRayonList = @SiteRayonList + ',' + CAST(l.idfsRayon AS VARCHAR)
		FROM dbo.tstSite s
		INNER JOIN dbo.tlbOffice AS o
			ON o.idfOffice = s.idfOffice
		INNER JOIN dbo.tlbGeoLocationShared AS l
			ON l.idfGeoLocationShared = o.idfLocation
		WHERE (
				s.idfsSite IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
					)
				OR (@SiteList IS NULL)
				);

		SET @SiteRayonList = SUBSTRING(@SiteRayonList, 2, LEN(@SiteRayonList));

		INSERT INTO @IDs
		SELECT a.idfAggrCase
		FROM dbo.tlbAggrCase a
		INNER JOIN dbo.gisRayon r
			ON r.idfsRayon = a.idfsAdministrativeUnit
		WHERE (a.intRowStatus = 0)
			AND (
				r.idfsRayon IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')
					)
				);

		-- Rayon of the settlement of the report administrative unit.
		INSERT INTO @IDs
		SELECT a.idfAggrCase
		FROM dbo.tlbAggrCase a
		INNER JOIN dbo.gisSettlement s
			ON s.idfsSettlement = a.idfsAdministrativeUnit
		WHERE (a.intRowStatus = 0)
			AND (
				s.idfsRayon IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')
					)
				);

		SELECT COUNT(ac.idfAggrCase) AS RecordCount,
			(
				SELECT COUNT(*)
				FROM dbo.tlbAggrCase
				WHERE intRowStatus = 0
					AND idfsAggrCaseType = @AggregateReportTypeID
				) AS TotalCount
		FROM @IDs a
		INNER JOIN dbo.tlbAggrCase ac
			ON ac.idfAggrCase = a.ID
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS ReceivedByOffice
			ON ac.idfReceivedByOffice = ReceivedByOffice.idfOffice
		INNER JOIN dbo.FN_GBL_Institution(@LanguageID) AS EnteredByOffice
			ON ac.idfEnteredByOffice = EnteredByOffice.idfOffice
		INNER JOIN dbo.tlbPerson AS EnteredByPerson
			ON ac.idfEnteredByPerson = EnteredByPerson.idfPerson
		INNER JOIN dbo.FN_GBL_Institution(@LanguageID) AS SentByOffice
			ON ac.idfSentByOffice = SentByOffice.idfOffice
		LEFT JOIN dbo.gisCountry AS Country
			ON ac.idfsAdministrativeUnit = Country.idfsCountry
		LEFT JOIN dbo.VW_GBL_REGIONS_GET AS Region
			ON ac.idfsAdministrativeUnit = Region.idfsRegion
				AND Region.idfsLanguage = dbo.fnGetLanguageCode(@LanguageID)
		LEFT JOIN dbo.VW_GBL_RAYONS_GET AS Rayon
			ON ac.idfsAdministrativeUnit = Rayon.idfsRayon
				AND Rayon.idfsLanguage = dbo.fnGetLanguageCode(@LanguageID)
		LEFT JOIN dbo.gisSettlement AS Settlement
			ON ac.idfsAdministrativeUnit = Settlement.idfsSettlement
		LEFT JOIN dbo.trtBaseReference AS AdminUnit
			ON AdminUnit.idfsBaseReference = CASE 
					WHEN NOT Country.idfsCountry IS NULL
						THEN 10089001
					WHEN NOT Region.idfsRegion IS NULL
						THEN 10089003
					WHEN NOT Rayon.idfsRayon IS NULL
						THEN 10089002
					WHEN NOT Settlement.idfsSettlement IS NULL
						THEN 10089004
					END
		LEFT JOIN dbo.trtStringNameTranslation AS per
			ON per.idfsBaseReference = CASE 
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091002 /*day*/
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6
						THEN 10091004 /*week - use datediff with day because datediff with week will return incorrect result if first day of week in country differ from sunday*/
					WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091001 /*month*/
					WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091003 /*quarter*/
					WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091005 /*year*/
					END
				AND per.idfsLanguage = dbo.fnGetLanguageCode(@LanguageID)
		LEFT OUTER JOIN dbo.tlbObservation AS CaseObs
			ON ac.idfCaseObservation = CaseObs.idfObservation
		LEFT OUTER JOIN dbo.tlbObservation AS DiagnosticObs
			ON ac.idfDiagnosticObservation = DiagnosticObs.idfObservation
		LEFT OUTER JOIN dbo.tlbObservation AS ProphylacticObs
			ON ac.idfProphylacticObservation = ProphylacticObs.idfObservation
		LEFT OUTER JOIN dbo.tlbObservation AS SanitaryObs
			ON ac.idfSanitaryObservation = SanitaryObs.idfObservation
		WHERE ac.intRowStatus = 0
			AND (
				ac.idfsSite IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
					)
				OR (@SiteList IS NULL)
				)
			AND (
				(ac.idfsAggrCaseType = @AggregateReportTypeID)
				OR (@AggregateReportTypeID IS NULL)
				)
			AND (
				(ac.idfSentByOffice = @OrganizationID)
				OR (@OrganizationID IS NULL)
				)
			AND (
				(per.idfsBaseReference = @TimeIntervalTypeID)
				OR (@TimeIntervalTypeID IS NULL)
				)
			AND (
				(ac.datStartDate >= @StartDate)
				OR (@StartDate IS NULL)
				)
			AND (
				(ac.datFinishDate >= @EndDate)
				OR (@EndDate IS NULL)
				)
			AND (
				CASE 
					WHEN @AdministrativeUnitID IS NULL
						THEN 1
					WHEN (
							Country.idfsCountry = @AdministrativeUnitID
							OR Region.idfsCountry = @AdministrativeUnitID
							OR Rayon.idfsCountry = @AdministrativeUnitID
							OR Settlement.idfsCountry = @AdministrativeUnitID
							)
						OR (
							Region.idfsRegion = @AdministrativeUnitID
							OR Rayon.idfsRegion = @AdministrativeUnitID
							OR Settlement.idfsRegion = @AdministrativeUnitID
							)
						OR (
							Rayon.idfsRayon = @AdministrativeUnitID
							OR Settlement.idfsRayon = @AdministrativeUnitID
							)
						OR Settlement.idfsSettlement = @AdministrativeUnitID
						THEN 1
					ELSE 0
					END = 1
				)
			AND (
				(ac.strCaseID LIKE '%' + @EIDSSReportID + '%')
				OR (@EIDSSReportID IS NULL)
				);

		SELECT @ReturnCode,
			@ReturnMessage;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();
		SET @ReturnMessage = ERROR_MESSAGE();

		SELECT @ReturnCode,
			@ReturnMessage;

		THROW;
	END CATCH;
END
