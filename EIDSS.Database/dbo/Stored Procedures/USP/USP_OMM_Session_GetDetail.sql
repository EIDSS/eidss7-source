-- ================================================================================================
-- Name: USP_OMM_Session_GetDetail
-- Description: Gets the details of an outbreak session.
--          
-- Author: Doug Albanese
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Doug Albanese        08/30/2021 Refactored to work with "AdminLevel" identifiers.
-- Doug Albanese        09/02/2021 Changed the output to match with the model used within the 
--                                 Location user control
-- Doug Albanese        09/10/2021 Change to correct a model property issue
-- Doug Albanese        09/14/2021 Refactored to use all location fields from hierarchy
-- Doug Albanese        09/27/2021 Cleaned up administration levels to reflect "Admin" instead of 
--                                 static name
-- Doug Albanese        10/21/2021 Corrected the return of the AdminLevel3 value
-- Doug Albanese        02/16/2022 Refactored to use function calls for "Repair"
-- Stephen Long         06/28/2022 Modified description and changed references types to use the 
--                                 national value instead of default.
-- Doug Albanese		03/15/2023 Change over from idfGeoLocation to idfsLocation
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_Session_GetDetail]
(    
	@LangID			NVARCHAR(50),
	@idfOutbreak	BIGINT
)
AS

BEGIN    

	DECLARE	@returnCode								INT = 0;
	DECLARE @returnMsg								NVARCHAR(MAX) = 'SUCCESS';

	BEGIN TRY
		SELECT
			idfOutbreak,
			idfsDiagnosisOrDiagnosisGroup,
			D.name AS [strDiagnosis],
			idfsOutbreakStatus,
			os.name AS strOutbreakStatus,
			OutbreakTypeId,
			ot.name AS strOutbreakType,
			lh.AdminLevel1ID AS AdminLevel0Value,
			lh.AdminLevel2ID AS AdminLevel1Value,
			lh.AdminLevel2Name AS AdminLevel1Text,
			lh.AdminLevel3ID AS AdminLevel2Value,
			lh.AdminLevel3Name AS AdminLevel2Text,
			lh.AdminLevel4ID AS AdminLevel3Value,
			lh.AdminLevel4Name AS AdminLevel3Text,
			datStartDate,
			datFinishDate AS datCloseDate,
			strOutbreakID,
			o.strDescription,
			o.intRowStatus,
			o.rowguid,
			o.datModificationForArchiveDate,
			idfPrimaryCaseOrSession,
			o.idfsSite,
			o.strMaintenanceFlag,
			o.strReservedAttribute
		FROM
			dbo.tlbOutbreak o
        LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(@LangID) lh				    ON lh.idfsLocation = o.idfsLocation
		INNER JOIN	dbo.FN_GBL_Repair(@LangID, 19000019) D								ON	D.idfsReference = o.idfsDiagnosisOrDiagnosisGroup
		INNER JOIN	dbo.FN_GBL_Repair(@LangID,19000063) os								ON	os.idfsReference = o.idfsOutbreakStatus
		INNER JOIN	dbo.FN_GBL_Repair(@LangID,19000513) ot								ON	ot.idfsReference = o.OutbreakTypeId
		WHERE
			idfOutbreak = @idfOutbreak;

	END TRY
	BEGIN CATCH
		SET		@returnCode = ERROR_NUMBER();
		SET		@returnMsg = 
					'ErrorNumber: ' + CONVERT(VARCHAR, ERROR_NUMBER()) 
					+ ' ErrorSeverity: ' + CONVERT(VARCHAR, ERROR_SEVERITY())
					+ ' ErrorState: ' + CONVERT(VARCHAR,ERROR_STATE())
					+ ' ErrorProcedure: ' + ISNULL(ERROR_PROCEDURE(), '')
					+ ' ErrorLine: ' +  CONVERT(VARCHAR, ISNULL(ERROR_LINE(), ''))
					+ ' ErrorMessage: '+ ERROR_MESSAGE();
	END CATCH
END
