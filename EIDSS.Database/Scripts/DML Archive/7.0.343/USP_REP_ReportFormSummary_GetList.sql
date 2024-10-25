DROP PROCEDURE IF EXISTS [dbo].[USP_REP_ReportFormSummary_GetList]
GO

/****** Object:  StoredProcedure [dbo].[USP_REP_ReportFormSummary_GetList]    Script Date: 3/29/2023 4:00:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--*************************************************************
-- Name 				: USP_REP_ReportFormSummary_GetList
-- Description			: Get List of Weekly Reports that fit
--						  search criteria entered
--          
-- Author               : Mark Wilson
-- Revision History
--		Name       Date       Change Detail
--	Mark Wilson	   29Mar2023  Added SET DATEFIRST 1; -- SET MONDAY AS First day of week.

--
-- Testing code:
--
/*[]

EXECUTE [dbo].[USP_REP_ReportFormSummary_GetList] 
	@LanguageID = 'ka-GE',
	@Year = 2020,
	@Month = 11

EXECUTE [dbo].[USP_REP_ReportFormSummary_GetList] 
	@LanguageID = 'ru-RU',
	@Year = 2020,
	@Month = 11,
	@RegionID = '37020000000',
	@RayonID='3260000000'

*/
CREATE PROCEDURE [dbo].[USP_REP_ReportFormSummary_GetList](
	@LanguageID AS NVARCHAR(50),
	@Year INT = NULL,
	@Month INT = NULL,
	@RegionID AS VARCHAR(50) = NULL,
	@RayonID AS VARCHAR(50) = NULL,
	@ReportFormTypeID AS BIGINT = NULL,
	@TimeIntervalTypeID AS BIGINT = NULL,
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

	DECLARE @StartDate DATETIME
	DECLARE @EndDate DATETIME

	SELECT 
		@StartDate = DATEADD(YEAR, @Year - 2000, DATEADD(MONTH, @Month - 1, '20000101')),
		@EndDate = DATEADD(YEAR, @Year - 2000, DATEADD(MONTH, @Month, '20000101'))

	-- Set Fist day of week to Monday
	IF (dbo.FN_GBL_CURRENTCOUNTRY_GET() = 780000000) -- Georgia first day of week = Monday
	BEGIN
		SET DATEFIRST 1; -- SET MONDAY AS First day of week.
	END


	BEGIN TRY

		DECLARE @WeeksPerMonth TABLE
		(
			WeekOfMonth INT,
			WeekStart DATE,
			WeekEnd DATE

		)

		INSERT INTO @WeeksPerMonth
		(
		    WeekOfMonth,
		    WeekStart,
		    WeekEnd
		)
		SELECT 
			WeekOfMonth,
			WeekStart,
			WeekEnd

		FROM dbo.FN_GBL_WeeksOfMonth(@StartDate)

-----------------------------------------------------------
		DECLARE @FinalResultSet TABLE
		(
			RegionID VARCHAR(50),
			RayonID VARCHAR(50),
			RegionName NVARCHAR(300),
			RayonName NVARCHAR(300),
			WeekOfMonth INT,
			StartDate DATE,
			EndDate DATE,
			total INT,
			notified INT

		)

		INSERT INTO @FinalResultSet
		(
			RegionID,
			RayonID,
		    RegionName,
		    RayonName,
			WeekOfMonth,
			StartDate,
			EndDate,
			total,
			notified
		)
		SELECT 
			CAST(L.Level2ID AS VARCHAR)AS RegionID,
			CAST(L.Level3ID AS VARCHAR)AS RayonID,
			L.Level2Name AS RegionName,
			L.Level3Name AS RayonName,
			W.WeekOfMonth,
			W.WeekStart,
			W.WeekEnd,
			0,
			0
		FROM dbo.gisLocationDenormalized L
		LEFT JOIN @WeeksPerMonth W ON 1 = 1
		WHERE idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID) 
		AND level1ID = dbo.FN_GBL_CURRENTCOUNTRY_GET() AND Level = 3

		DECLARE @PopulatedRayons TABLE
		(
			RegionID VARCHAR(50),
			RayonID VARCHAR(50),
			RegionName NVARCHAR(300),
			RayonName NVARCHAR(300),
			StartDate DATE,
			EndDate DATE,
			total INT,
			notified INT

		)

---------------------------------------------------------------
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
		SELECT 
			a.idfReportForm
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
		-- Weekly Report data shall be available to all sites of the same 
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
		SELECT 
			a.idfReportForm
		FROM dbo.tlbReportForm a
		INNER JOIN dbo.gisLocation L ON L.idfsLocation = a.idfsAdministrativeUnit AND L.intRowStatus = 0
		INNER JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) LF ON LF.AdminLevel1ID = L.idfsLocation OR LF.AdminLevel2ID = LF.idfsLocation  OR LF.AdminLevel4ID = L.idfsLocation

/*		INNER JOIN dbo.gisRayon r
			ON r.idfsRayon = a.idfsAdministrativeUnit
				AND r.intRowStatus = 0
*/
		WHERE (a.intRowStatus = 0)


			AND (
					LF.AdminLevel2ID IN 
					(
						SELECT CAST([Value] AS BIGINT)
						FROM dbo.FN_GBL_SYS_SplitList(@SiteRayonList, NULL, ',')
					)

					OR LF.AdminLevel3ID IN 
					(
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
		SELECT 
			a.idfReportForm
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
		INSERT INTO @PopulatedRayons
		(
			RegionID,
			RayonID,
		    RegionName,
		    RayonName,
		    StartDate,
		    EndDate,
			total,
			notified
		)

		SELECT 
			CAST(summary.RegionID AS VARCHAR),
			CAST(summary.RayonID AS VARCHAR),
			summary.RegionName,
			summary.RayonName,  
			summary.StartDate, 
			summary.finishdate,
			SUM(summary.total) total,
			SUM(summary.notified) notified 
		FROM
		(SELECT RfID.ID AS ReportFormID,
			dbo.FN_GBL_FormatDate(ac.datStartDate, 'mm/dd/yyyy') AS StartDate,
			dbo.FN_GBL_FormatDate(ac.datFinishDate, 'mm/dd/yyyy') AS FinishDate,
			br.strDefault AS diseaseDefaultName,
			ac.Total,
			ac.Notified,
			L.AdminLevel2ID AS RegionID,
			L.AdminLevel3ID AS RayonID,
			L.AdminLevel2Name AS RegionName,
			L.AdminLevel3Name AS RayonName,
			L.AdminLevel4Name AS SettlementName

		FROM @IDs RfID
		INNER JOIN dbo.tlbReportForm AS ac ON ac.idfReportForm = RfID.ID
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS EnteredByOffice ON ac.idfEnteredByOffice = EnteredByOffice.idfOffice
		LEFT JOIN dbo.tlbPerson AS EnteredByPerson ON ac.idfEnteredByPerson = EnteredByPerson.idfPerson
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) AS SentByOffice ON ac.idfSentByOffice = SentByOffice.idfOffice
		LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LanguageID) L ON L.idfsLocation = ac.idfsAdministrativeUnit
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
		JOIN dbo.trtBaseReference br ON br.idfsBaseReference = ac.idfsDiagnosis 
		LEFT JOIN dbo.trtStringNameTranslation AS Diagnosis ON Diagnosis.idfsBaseReference = ac.idfsDiagnosis AND Diagnosis.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageID)
		WHERE (ac.intRowStatus = 0)
			AND (
				(ac.idfsReportFormType = @ReportFormTypeID)
				OR (@ReportFormTypeID IS NULL)
				)
			AND (
				(ac.idfSentByOffice = @OrganizationID)
				OR (@OrganizationID IS NULL)
				)
			--AND (
			--	(L.LevelType = @AdministrativeUnitTypeID)
			--	OR (@AdministrativeUnitTypeID IS NULL)
			--)
			AND (
				(per.idfsBaseReference = @TimeIntervalTypeID)
				OR (@TimeIntervalTypeID IS NULL)
				)
			AND (
				(ac.datStartDate >= @StartDate)
				OR (@StartDate IS NULL)
				)
			AND (
				(ac.datFinishDate < @EndDate)
				OR (@EndDate IS NULL)
				)
			AND (
				CASE 
					WHEN @AdministrativeUnitID IS NULL
						THEN 1
					WHEN (
							L.AdminLevel1ID = @AdministrativeUnitID
							OR L.AdminLevel2ID = @AdministrativeUnitID
							OR L.AdminLevel3ID = @AdministrativeUnitID
							OR L.AdminLevel4ID = @AdministrativeUnitID
						)
					THEN 1
					ELSE 0
					END = 1
				)
		) summary

		GROUP BY Summary.RegionID,Summary.RayonID,summary.RegionName,summary.RayonName,summary.StartDate,summary.FinishDate

	UPDATE F
	SET F.total = P.total,
		F.notified = P.notified
	FROM @FinalResultSet F
	INNER JOIN @PopulatedRayons P ON P.RegionID = F.RegionID AND P.RayonID = F.RayonID AND P.StartDate = F.StartDate AND P.EndDate = F.EndDate


	SELECT 
		summary.RegionName,
		summary.RayonName,
		summary.WeekOfMonth,
		Summary.StartDate,
		Summary.EndDate,
		--CONVERT(VARCHAR, Summary.StartDate,103) + ' - ' + CONVERT(VARCHAR, Summary.EndDate,103) AS WeekSpan,
		summary.total,
		summary.notified,
		summary.RegionID,
		summary.RayonID,
		@RegionID,
		@RayonID
		
	FROM @FinalResultSet summary
	WHERE  ((summary.RegionID = @RegionID) OR (ISNULL(@RegionID,'0') = '0'))
			AND ((summary.RayonID = @RayonID) OR (ISNULL(@RayonID,'0')= '0'))
	ORDER BY summary.RegionName,summary.RayonName,summary.WeekOfMonth


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
GO


