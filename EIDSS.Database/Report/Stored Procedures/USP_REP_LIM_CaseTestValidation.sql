-- ================================================================================================
-- Name: report.USP_REP_LIM_CaseTestValidation
--
-- Description: Select Disease Report Test validation details
--						
-- Author: Mark Wilson
--
-- Revision History:
--		Name       Date       Change Detail
-- --------------- ---------- --------------------------------------------------------------------
-- Mark Wilson    07/07/2022  Initial version, Converted to E7 standards.
-- Sri Goli       01/16/2023  Added Column strRuleStatus
-- Testing code:

/*
--Example of a call of procedure:

select * FROM dbo.tlbVetCase where introwstatus = 0
select * FROM dbo.tlbHumanCase where introwstatus = 0

exec report.USP_REP_LIM_CaseTestValidation @LangID=N'en-US',@ObjID=5587
exec report.USP_REP_LIM_CaseTestValidation @LangID=N'en-US',@ObjID=80643


*/

CREATE PROCEDURE [Report].[USP_REP_LIM_CaseTestValidation]
(
    @ObjID	AS BIGINT,
    @LangID AS NVARCHAR(10)
)
AS
BEGIN

	DECLARE @cYes AS NVARCHAR(20)
	DECLARE @cNo AS NVARCHAR(20)
	
	SELECT
		@cYes=[name] 
	FROM dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000100)
	WHERE idfsReference=10100001 /*'ynvYes'*/

	SELECT
		@cNo=[name] 
	FROM dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000100) where idfsReference=10100002 /*'ynvNo'*/

	SELECT  
		D.[name] AS Diagnosis,
		TT.[name] AS TestName,
		TD.[name] AS TestType,
		TV.idfsInterpretedStatus AS intRuleStatus,
		interpretedStatusType.name AS strRuleStatus,
		TV.strInterpretedComment AS strRuleComment,
		TV.datInterpretationDate AS interpretedDate,
		dbo.FN_GBL_ConcatFullName(tInterpretedBy.strFamilyName, tInterpretedBy.strFirstName, tInterpretedBy.strSecondName) AS InterpretedBy,
		CASE TV.blnValidateStatus 
			WHEN 0 THEN @cNo
			WHEN 1 THEN @cYes
			ELSE @cNo
		END AS intValidateStatus,
		--dbo.FN_GBL_ConcatFullName(tInterpretedBy.strFamilyName, tInterpretedBy.strFirstName, tInterpretedBy.strSecondName) AS InterpretedBy,
		TV.strValidateComment AS strValidateComment,
		dbo.FN_GBL_ConcatFullName(tValidatedBy.strFamilyName, tValidatedBy.strFirstName, tValidatedBy.strSecondName) AS ValidatedBy,
		TV.datValidationDate AS validatedDate
		
	FROM dbo.tlbTesting T
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000097) TT ON TT.idfsReference = T.idfsTestName
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID,19000095) AS TD ON T.idfsTestCategory = TD.idfsReference
	INNER JOIN dbo.tlbTestValidation AS TV ON T.idfTesting = TV.idfTesting AND T.intRowStatus = 0 AND TV.intRowStatus = 0
	LEFT JOIN dbo.tlbPerson AS tValidatedBy ON TV.idfValidatedByPerson = tValidatedBy.idfPerson
	LEFT JOIN dbo.tlbPerson AS tInterpretedBy ON TV.idfInterpretedByPerson = tInterpretedBy.idfPerson
	LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) AS D ON D.idfsReference = TV.idfsDiagnosis
	INNER JOIN dbo.tlbMaterial M ON	M.idfMaterial = T.idfMaterial AND M.intRowStatus = 0 AND (M.idfHumanCase = @ObjID OR M.idfVetCase = @ObjID OR M.idfMonitoringSession = @ObjID)
	LEFT JOIN dbo.FN_GBL_Repair(@LangID, 19000106) interpretedStatusType ON interpretedStatusType.idfsReference = tv.idfsInterpretedStatus
	WHERE	T.intRowStatus = 0
			
END

GO

