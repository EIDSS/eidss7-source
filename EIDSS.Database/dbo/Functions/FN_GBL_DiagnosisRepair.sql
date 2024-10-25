



----------------------------------------------------------------------------
-- Name 				: dbo.FN_GBL_DiagnosisRepair
-- Description			: Get the translated diagnosis
--          
-- Author               : Mark Wilson
-- 
-- Revision History
-- Name				Date		Change Detail
-- Mark Wilson	  18-Nov-2019  Converted to E7 standards
-- Mark Wilson	  30-Jan-2021  Updated to use dbo function for use with application
-- Mark Wilson	  23-Aug-2021  Updated testing code and qualified all column and table names
--
-- usage
--

--Example of procedure call:
/*
Select * from dbo.FN_GBL_DiagnosisRepair ('en-US', 32, 10020001) -- 'StandartCase' --ActiveSurveillance
Select * from dbo.FN_GBL_DiagnosisRepair ('ru-RU', 96, 10020001) -- 'StandartCase' --PassiveSurveillance
Select * from dbo.FN_GBL_DiagnosisRepair ('az-Latn-AZ', 96, 10020002) -- 'AggregateCase' --AggregateActions
Select * from dbo.FN_GBL_DiagnosisRepair ('en-US', NULL, NULL) 
*/


CREATE FUNCTION [dbo].[FN_GBL_DiagnosisRepair] 
(
	@LangID AS NVARCHAR(50), --##PARAM @LangID - language ID
	@HACode AS INT = NULL,  --##PARAM @HACode - bit mask that defines Area where diagnosis are used (human, LiveStock or avian)
	@DiagnosisUsingType AS BIGINT = NULL --##PARAM @DiagnosisUsingType - diagnosis Type (standard or aggregate)
)
RETURNS TABLE

AS 
RETURN
(
	SELECT	
		D.idfsDiagnosis,
		DT.[name],
		D.strIDC10,
		D.strOIECode,
		DT.intHACode,
		DT.intRowStatus,
		DT.intOrder
	FROM dbo.FN_GBL_ReferenceRepair_GET(@LangID, 19000019) DT --Function to translate reference data
	INNER JOIN dbo.trtDiagnosis D ON D.idfsDiagnosis = DT.idfsReference
	WHERE (@HACode = 0 OR @HACode IS NULL OR DT.intHACode IS NULL OR 
				CASE --1=animal, 32=LiveStock , 64=avian
					--below we assume that client will never pass animal bit without livstock or avian bits
					WHEN (DT.intHACode & 97) > 1 THEN (~1 & DT.intHACode) & @HACode -- if avian or livstock bits are set, clear animal bit in  b.intHA_Code
					WHEN (DT.intHACode & 97) = 1 THEN (~1 & DT.intHACode | 96) & @HACode --if only animal bit is set, clear clear animal bit and set both avian and livstock bits in  b.intHA_Code
					ELSE DT.intHACode & @HACode  END >0)
	AND (@DiagnosisUsingType IS NULL OR D.idfsDiagnosis IS NULL OR D.idfsUsingType = @DiagnosisUsingType)

)

