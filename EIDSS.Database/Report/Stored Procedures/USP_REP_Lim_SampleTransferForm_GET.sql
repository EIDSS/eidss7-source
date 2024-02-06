-- ================================================================================================
-- Name: report.USP_REP_Lim_SampleTransferForm_GET
--
-- Description:	Select data for Container Transfer report.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		12132021	Initial Version, converted to E7 standards
-- Stephen Long     05/08/2023 Changed from institution repair to min.

/*
--Example of a call of procedure:

exec report.USP_REP_Lim_SampleTransferForm_GET 
	@ObjID=181450001100,
	@LangID=N'en-US'

*/
CREATE  PROCEDURE [Report].[USP_REP_Lim_SampleTransferForm_GET]
    (
		@ObjID BIGINT,
		@LangID AS NVARCHAR(20)
    )
AS
BEGIN 
	SELECT	
		O.strBarcode AS TransferOutBarcode,
		O.strBarcode AS TransferOutLabel,
		O.strNote AS PurposeOfTransfer,
		InstFromName.AbbreviatedName AS TransferredFrom,
		InstToName.AbbreviatedName AS SampleTrasnferredTo,
		dbo.FN_GBL_ConcatFullName(SentByPerson.strFamilyName, SentByPerson.strFirstName, SentByPerson.strSecondName) AS SentBy,
		O.datSendDate AS DateSent,
		M.strBarcode AS SourceLabID,
		M.strBarcode AS SourceLabIDBarcode,
		ST.[name] AS SampleType,
		PM.datAccession AS DateSampleReceived,
		dbo.FN_GBL_ConcatFullName(ReceivedByPerson.strFamilyName, ReceivedByPerson.strFirstName, ReceivedByPerson.strSecondName)	AS ReceivedBy,
		M.strFieldBarcode AS SampleID,
		PM.strBarcode AS LabSampleID,
		rfCondition.name AS Condition,				
		RF.[Path] AS StorageLocation,				
		PM.strCondition AS Comment,
		rfFuncArea.name AS FunctionalArea				

	FROM dbo.tlbTransferOUT O
	LEFT JOIN dbo.tlbTransferOutMaterial OM ON OM.idfTransferOut=O.idfTransferOut
	LEFT JOIN dbo.tlbMaterial M ON M.idfMaterial = OM.idfMaterial AND M.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000087) ST ON ST.idfsReference = M.idfsSampleType
	LEFT JOIN dbo.tlbMaterial PM ON PM.idfParentMaterial=M.idfMaterial AND PM.idfsSampleKind = 12675430000000 /* TransferredIn */ AND PM.intRowStatus = 0
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000110) rfCondition ON rfCondition.idfsReference = PM.idfsAccessionCondition
   	LEFT JOIN report.FN_SAMPLE_RepositorySchema_GET(@LangID,NULL,NULL) RF ON RF.idfSubdivision = PM.idfSubdivision
	LEFT JOIN dbo.FN_GBL_Department(@LangID) rfFuncArea ON rfFuncArea.idfDepartment = PM.idfInDepartment
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS InstFromName ON O.idfSendFromOffice = InstFromName.idfOffice
	LEFT JOIN dbo.FN_GBL_Institution_Min(@LangID) AS InstToName ON O.idfSendToOffice = InstToName.idfOffice
	LEFT JOIN dbo.tlbPerson AS SentByPerson ON O.idfSendByPerson = SentByPerson.idfPerson
	LEFT JOIN dbo.tlbPerson AS ReceivedByPerson ON PM.idfAccesionByPerson = ReceivedByPerson.idfPerson

	WHERE	O.idfTransferOut = @ObjID

END	
			

