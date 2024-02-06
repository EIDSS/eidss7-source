-- ================================================================================================
-- Name: USP_DAS_NOTIFICATIONS_GETCOUNT
--
-- Description: Returns a count of human disease reports based on the language and site list.
--
-- Author: Ricky Moss
-- 
-- Revision History:
-- Name					Date      Change Detail
-- ------------------- ---------- ----------------------------------------------------------------
-- Ricky Moss          05/07/2019 Initial Release
-- Stephen Long        01/24/2020 Added the site list parameter for site filtration, and corrected 
--                                join on entered by person.
--
-- Testing Code:
-- exec USP_DAS_NOTIFICATIONS_GETCOUNT
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_DAS_NOTIFICATIONS_GETCOUNT] (@LanguageID NVARCHAR(50), @SiteList VARCHAR(MAX) = NULL)
AS
BEGIN
	BEGIN TRY
		SELECT COUNT(hc.idfHumanCase) AS RecordCount
		FROM dbo.tlbHumanCase hc
		LEFT JOIN dbo.tlbHuman AS h
			ON h.idfHuman = hc.idfHuman
				AND h.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) finalDiagnosis
			ON Finaldiagnosis.idfsReference = hc.idfsFinalDiagnosis
		LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LanguageID, 19000019) tentativeDiagnosis
			ON tentativeDiagnosis.idfsReference = hc.idfsTentativeDiagnosis
		LEFT JOIN dbo.tlbPerson AS personEnteredBy
			ON personEnteredBy.idfPerson = hc.idfPersonEnteredBy
				AND personEnteredBy.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_INSTITUTION(@LanguageID) hospital
			ON hospital.idfOffice = hc.idfHospital
		WHERE hc.intRowStatus = 0
			AND hc.datEnteredDate IS NOT NULL
			AND (
				hc.idfsSite IN (
					SELECT CAST([Value] AS BIGINT)
					FROM dbo.FN_GBL_SYS_SplitList(@SiteList, NULL, ',')
					)
				OR (@SiteList IS NULL)
				);
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH
END
