
--*************************************************************************
-- Name 				: dbo.USP_REP_SpeciesType_GetList
-- Description			: Used in Summary Veterinary Report to populate Species Type
--          
-- Author               : Srini Goli
-- Revision History
--		Name       Date       Change Detail
--
-- Testing code:
/*
--Example of a call of procedure:
--Select * from FN_GBL_DiagnosisRepair ('en', 32, 10020001)
--Select * from FN_GBL_DiagnosisRepair ('en', 96, 10020001)
EXEC  dbo.USP_REP_SpeciesType_GetList 'en', 7718160000000 --African Horse Sickness,32
EXEC  dbo.USP_REP_SpeciesType_GetList 'en', 7718090000000 --Acute viral enteritis,64
EXEC  dbo.USP_REP_SpeciesType_GetList 'en', 7718390000000 --Ascariasis,96
EXEC  dbo.USP_REP_SpeciesType_GetList 'en', 7718570000000 --Botulism,98
*/


CREATE PROCEDURE [dbo].[USP_REP_SpeciesType_GetList] (
	@LangID AS NVARCHAR(50), --##PARAM @LangID - language ID
	@idfsDiagnosis AS BIGINT = NULL  --##PARAM @HACode - bit mask that defines Area where species type are used (LiveStock or avian)
)
AS

	DECLARE @HACode AS BIGINT

	SELECT @HACode=	DT.intHACode
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000019) DT --Function to translate reference data
	WHERE DT.idfsReference=@idfsDiagnosis
	
	SELECT 
		sl.idfsReference
		, sl.name
		, sl.intHACode
		, sl.intOrder
		, sl.intRowStatus
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000086 /*Species List*/) sl
	JOIN trtSpeciesType tst ON
		tst.idfsSpeciesType = sl.idfsReference
	WHERE (ISNULL(@HACode,0)=0 OR intHACode in (SELECT * FROM dbo.FN_GBL_SplitHACode(@HACode,510)))
		AND sl.intRowStatus=0
	ORDER BY sl.intOrder
		, sl.name  


