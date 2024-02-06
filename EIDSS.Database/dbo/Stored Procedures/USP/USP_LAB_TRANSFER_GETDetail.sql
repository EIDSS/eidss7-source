-- ================================================================================================
-- Name: USP_LAB_TRANSFER_GETDetail
--
-- Description:	Get transfer details for a specific laboratory sample transfer.
--
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     09/26/2021 Initial release.
-- Stephen Long     07/27/2022 Changed where criteria to query off of sample id instead of 
--                             transfer id.
--
-- Testing Code:
/*
DECLARE	@return_value int

EXEC	@return_value = [dbo].[USP_LAB_TRANSFER_GETDetail]
		@LanguageID = N'en-US',
		@TransferID = 1,
		@UserID = 161287150000872 --rykermase

SELECT	'Return Value' = @return_value

GO
*/
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_TRANSFER_GETDetail] (
	@LanguageID NVARCHAR(50)
	,@TransferID BIGINT
	,@UserID BIGINT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnMessage VARCHAR(MAX) = 'SUCCESS'
		,@ReturnCode INT = 0;

	BEGIN TRY
		SELECT tr.idfTransferOut AS TransferID
			,tr.strBarcode AS EIDSSTransferID
			,m.idfMaterial AS TransferredOutSampleID
			,(
				SELECT TOP 1 idfMaterial
				FROM dbo.tlbMaterial
				WHERE idfRootMaterial = m.idfMaterial
					AND intRowStatus = 0
					AND idfsSampleKind = 12675430000000 --Transferred in
				) AS TransferredInSampleID
			,tr.idfSendToOffice AS TransferredToOrganizationID
			,transferredToOrganization.name AS TransferredToOrganizationName
			,tr.idfSendFromOffice AS TransferredFromOrganizationID
			,transferredFromOrganization.AbbreviatedName AS TransferredFromOrganizationName
			,ISNULL(sentByPerson.strFamilyName, N'') + ISNULL(' ' + sentByPerson.strFirstName, N'') + ISNULL(' ' + sentByPerson.strSecondName, N'') AS SentByPersonName
			,tr.datSendDate AS TransferDate
			,tr.TestRequested
			,t.idfTesting AS TestID
			,tr.strNote AS PurposeOfTransfer
			,tr.idfsSite AS SiteID
			,tr.idfSendByPerson AS SentByPersonID
			,tr.idfsTransferStatus AS TransferStatusTypeID
			,tr.intRowStatus AS RowStatus
			,(
				CASE 
					WHEN transferredToOrganization.idfsSite IS NULL
						THEN 1
					ELSE 0
					END
				) AS NonEIDSSLaboratoryIndicator
		FROM dbo.tlbTransferOUT tr
		INNER JOIN dbo.tlbTransferOutMaterial tom ON tom.idfTransferOut = tr.idfTransferOut
			AND tom.intRowStatus = 0
		INNER JOIN dbo.tlbMaterial m ON m.idfMaterial = tom.idfMaterial
			AND m.intRowStatus = 0
		LEFT JOIN dbo.tlbTesting t ON t.idfMaterial = m.idfMaterial
			AND t.intRowStatus = 0
			AND t.blnExternalTest = 1
		LEFT JOIN dbo.FN_GBL_Institution_Min(@LanguageID) transferredFromOrganization ON transferredFromOrganization.idfOffice = tr.idfSendFromOffice
		LEFT JOIN dbo.tlbPerson sentByPerson ON sentByPerson.idfPerson = tr.idfSendByPerson
			AND sentByPerson.intRowStatus = 0
		LEFT JOIN dbo.FN_GBL_Institution(@LanguageID) transferredToOrganization ON transferredToOrganization.idfOffice = tr.idfSendToOffice
		WHERE tom.idfMaterial = @TransferID;
	END TRY

	BEGIN CATCH
		THROW;
	END CATCH;
END;
