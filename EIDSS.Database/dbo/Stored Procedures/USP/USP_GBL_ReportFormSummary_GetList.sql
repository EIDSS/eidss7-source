
--*************************************************************
-- Name 				: USP_GBL_ReportFormSummary_GetList
-- Description			: Get List of Weekly Reports that fit
--						  search criteria entered
--          
-- Author               : Mani
-- Revision History
--		Name       Date       Change Detail
--
--
-- Testing code:
--
/*

EXECUTE [dbo].[USP_GBL_ReportFormSummary_GetList] 
	'ru',
	NULL,
	'HWR'
--*/
CREATE PROCEDURE [dbo].[USP_GBL_ReportFormSummary_GetList](
	@LanguageID AS NVARCHAR(50),
	@ReportFormTypeID AS BIGINT = NULL,
	@AdministrativeUnitTypeID AS BIGINT = NULL, 
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
		SELECT a.idfReportForm
		FROM dbo.tlbReportForm a
		WHERE (a.intRowStatus = 0)
			AND (
				a.idfEnteredByOffice IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')
					)
				OR a.idfSentByOffice IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteOrganizationList, NULL, ',')
					)
				);

		--
		-- Weekly Report report data shall be available to all sites of the same 
		-- administrative rayon.
		--
		-- Rayon of the report administrative unit.
		DECLARE @SiteRayonList VARCHAR(MAX) = '';

		SELECT @SiteRayonList = @SiteRayonList + ',' + CAST(l.idfsRayon AS VARCHAR)
		FROM dbo.tstSite s
		INNER JOIN dbo.tlbOffice AS o
			ON o.idfOffice = s.idfOffice
				AND o.intRowStatus = 0
		INNER JOIN dbo.tlbGeoLocationShared AS l
			ON l.idfGeoLocationShared = o.idfLocation
				AND l.intRowStatus = 0
		WHERE (
				s.idfsSite IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
					)
				OR (@SiteList IS NULL)
				);

		SET @SiteRayonList = SUBSTRING(@SiteRayonList, 2, LEN(@SiteRayonList));

		INSERT INTO @IDs
		SELECT a.idfReportForm
		FROM dbo.tlbReportForm a
		INNER JOIN dbo.gisRayon r
			ON r.idfsRayon = a.idfsAdministrativeUnit
				AND r.intRowStatus = 0
		WHERE (a.intRowStatus = 0)
			AND (
				r.idfsRayon IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')
					)
				)
			AND a.idfReportForm NOT IN (
				SELECT *
				FROM @IDs
				);

		---- Rayon of the settlement of the report administrative unit.
		INSERT INTO @IDs
		SELECT a.idfReportForm
		FROM dbo.tlbReportForm a
		INNER JOIN dbo.gisSettlement s
			ON s.idfsSettlement = a.idfsAdministrativeUnit
				AND s.intRowStatus = 0
		WHERE (a.intRowStatus = 0)
			AND (
				s.idfsRayon IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')
					)
				)
			AND a.idfReportForm NOT IN (
				SELECT *
				FROM @IDs
				);

		select summary.RegionName,summary.RayonName,  summary.StartDate, summary.finishdate,sum(summary.total) total,sum(summary.notified) notified from
		(SELECT RfID.ID AS ReportFormID,
			dbo.FN_GBL_FormatDate(ac.datStartDate, 'mm/dd/yyyy') AS StartDate,
			dbo.FN_GBL_FormatDate(ac.datFinishDate, 'mm/dd/yyyy') AS FinishDate,
			br.strDefault as diseaseDefaultName,
			ac.Total,
			ac.Notified,
			(
				SELECT strTextString
				FROM dbo.gisStringNameTranslation
				WHERE idfsGISBaseReference = CASE 
						WHEN NOT Settlement.idfsSettlement IS NULL
							THEN Settlement.idfsRegion
						WHEN NOT Rayon.idfsRayon IS NULL
							THEN Rayon.idfsRegion
						ELSE Region.idfsRegion
						END
					AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
				) AS RegionName,
			(
				SELECT strTextString
				FROM dbo.gisStringNameTranslation
				WHERE idfsGISBaseReference = CASE 
						WHEN NOT Settlement.idfsSettlement IS NULL
							THEN Settlement.idfsRayon
						ELSE Rayon.idfsRayon
						END
					AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
				) AS RayonName,
		
			(
				SELECT strTextString
				FROM dbo.gisStringNameTranslation
				WHERE idfsGISBaseReference = Settlement.idfsSettlement
					AND idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
				) AS SettlementName--
		FROM @IDs RfID
		INNER JOIN dbo.tlbReportForm AS ac
			ON ac.idfReportForm = RfID.ID
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS EnteredByOffice
			ON ac.idfEnteredByOffice = EnteredByOffice.idfOffice
		LEFT JOIN dbo.tlbPerson AS EnteredByPerson
			ON ac.idfEnteredByPerson = EnteredByPerson.idfPerson
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS SentByOffice
			ON ac.idfSentByOffice = SentByOffice.idfOffice
		LEFT JOIN dbo.gisCountry AS Country
			ON ac.idfsAdministrativeUnit = Country.idfsCountry
		LEFT JOIN dbo.VW_GBL_REGIONS_GET AS Region
			ON ac.idfsAdministrativeUnit = Region.idfsRegion
				AND Region.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		LEFT JOIN dbo.VW_GBL_RAYONS_GET AS Rayon
			ON ac.idfsAdministrativeUnit = Rayon.idfsRayon
				AND Rayon.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
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
						THEN 10091002 /* Day */
					WHEN DATEDIFF(DAY, ac.datStartDate, ac.datFinishDate) = 6
						THEN 10091004 /* Week - use datediff with day because datediff with week will return incorrect result if first day of the week in country differs from Sunday */
					WHEN DATEDIFF(MONTH, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091001 /* Month */
					WHEN DATEDIFF(QUARTER, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091003 /* Quarter */
					WHEN DATEDIFF(YEAR, ac.datStartDate, ac.datFinishDate) = 0
						THEN 10091005 /* Year */
					END
				AND per.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		JOIN trtBaseReference br
		on br.idfsBaseReference = ac.idfsDiagnosis 
		LEFT JOIN dbo.trtStringNameTranslation AS  Diagnosis
			ON Diagnosis.idfsBaseReference = ac.idfsDiagnosis
				AND Diagnosis.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		WHERE (ac.intRowStatus = 0)
			AND (
				(ac.idfsReportFormType = @ReportFormTypeID)
				OR (@ReportFormTypeID IS NULL)
				)
			AND (
				(ac.idfSentByOffice = @OrganizationID)
				OR (@OrganizationID IS NULL)
				)
			AND (
				(AdminUnit.idfsBaseReference = @AdministrativeUnitTypeID)
				OR (@AdministrativeUnitTypeID IS NULL)
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
				(ac.datFinishDate <= @EndDate)
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
		) summary

		group by summary.RegionName,summary.RayonName,summary.StartDate,summary.FinishDate
		order by summary.RegionName,summary.RayonName,summary.StartDate,summary.FinishDate


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
