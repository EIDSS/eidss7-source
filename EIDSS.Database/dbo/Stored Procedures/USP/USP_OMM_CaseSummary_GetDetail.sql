

--*************************************************************
-- Name: [USP_OMM_CaseSummary_GetDetail]
-- Description: Get Summary Detail for a person
--          
-- Author: Doug Albanese
-- Revision History
--		Name       Date       Change Detail
--    Doug Albanese 6-13-2019 Added the capabilities for an Outbreak Case Id to be used for retrieving case details
--*************************************************************
CREATE PROCEDURE [dbo].[USP_OMM_CaseSummary_GetDetail]
(    
	@LangID									nvarchar(50),
	@OutbreakCaseReportUID					BIGINT = -1,
	@idfHumanActual							BIGINT = -1,
	@idfFarmActual							BIGINT = -1
)
AS

BEGIN    

	DECLARE	@returnCode						INT = 0;
	DECLARE @returnMsg						NVARCHAR(MAX) = 'SUCCESS';
	DECLARE @DateEntered					DATETIME = NULL
	DECLARE @DateLastUpdated				DATETIME = NULL
	DECLARE @OutbreakCaseClassification		NVARCHAR(200) = NULL
	
	BEGIN TRY

		
		IF @OutbreakCaseReportUID > -1
			BEGIN
				SELECT
						@idfHumanActual =				COALESCE(H.idfHumanActual, -1),
						@idfFarmActual =				COALESCE(F.idfFarmActual, -1),
						@DateEntered =					OCR.AuditCreateDTM,
						@DateLastUpdated =				OCR.AuditUpdateDTM,
						@OutbreakCaseClassification =	COALESCE(D.name,'')

				FROM
												OutbreakCaseReport OCR

				LEFT JOIN						tlbHumanCase HC
				ON								HC.idfHumanCase = OCR.idfHumanCase
				LEFT JOIN						tlbHuman H
				ON								H.idfHuman = HC.idfHuman
				LEFT JOIN						tlbVetCase VC
				ON								VC.idfVetCase = OCR.idfVetCase
				LEFT JOIN						tlbFarm F
				ON								F.idfFarm = VC.idfFarm
				LEFT JOIN						dbo.FN_GBL_Reference_GETList(@LangID, 19000011) D
				ON								D.idfsReference = OCR.OutbreakCaseClassificationID
				WHERE
					OCR.OutBreakCaseReportUID = @OutbreakCaseReportUID

			END
		ELSE
			BEGIN
				SET @DateEntered = GETDATE()
			END

		IF @idfHumanActual > -1
			BEGIN
				SELECT	
						ISNULL(ha.strFirstName, '') + ' ' + ISNULL(ha.strLastName, '') as Person,
						haai.EIDSSPersonId AS EIDSSID,
						@DateEntered AS DateEntered,
						@DateLastUpdated As DateLastUpated,
						@OutbreakCaseClassification AS CaseClassification
				FROM	dbo.tlbHumanActual ha
				LEFT JOIN	dbo.HumanActualAddlinfo haai 
				ON		ha.idfHumanActual = haai.HumanActualAddlinfoUID
		
				WHERE ha.idfHumanActual = @idfHumanActual;
			END

		IF @idfFarmActual > -1
			BEGIN
				SELECT	ISNULL(ha.strFirstName, '') + ' ' + ISNULL(ha.strLastName, '') as Person,
						fa.strFarmCode AS EIDSSID,
						@DateEntered AS DateEntered,
						@DateLastUpdated As DateLastUpated,
						@OutbreakCaseClassification AS CaseClassification
				FROM	dbo.tlbFarmActual fa
				LEFT JOIN tlbHumanActual ha
				ON		ha.idfHumanActual = fa.idfHumanActual
				LEFT JOIN HumanActualAddlinfo haai 
				ON		fa.idfHumanActual = haai.HumanActualAddlinfoUID
		
				WHERE fa.idfFarmActual = @idfFarmActual;
			END

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT = 1 
			ROLLBACK;
		throw;
	END CATCH

	SELECT	@returnCode, @returnMsg;

END
