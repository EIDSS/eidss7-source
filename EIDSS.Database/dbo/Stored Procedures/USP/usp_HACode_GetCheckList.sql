--=================================================================================================
-- Created by:				Joan Li
-- Last modified date:		06/19/2017
-- Last modified by:		Joan Li
-- Description:				06/19/2017: Created based on V6 spHACode_SelectCheckList :  V7 USP67
--                          select list of records from the following tables:trtHACodeListand 
--                          fnReference.
--
--                          Type id 19000040: Accessory List Type
--                          Type id 19000041: Patient Location Type
-- 
-- Name                    Date                 Change
-- ----------------------- ---------- ------------------------------------------------------------
-- Stephen Long            08/02/2021 Changed function from v6 to v7, and added order and order by 
--                                    order, then national name.
-- Stephen Long            08/23/2021 Changed function call to FN_GBL_Reference_GETList instead of
--                                    FN_GBL_Reference_List_GET.  Latter uses old v6.1 language 
--                                    get code.
/*
----testing code:
exec usp_HACode_GetCheckList 'en-US', 128  ---64 avian
----related fact data from
select * from trtHACodeList  
select * from trtBaseReference where idfsreferencetype in (19000040,19000041)
*/
--=================================================================================================
CREATE PROCEDURE [dbo].[usp_HACode_GetCheckList] @LangID AS NVARCHAR(50)
	,@intHACodeMask INT = 226 --Human, Livestock, Avian, Vector
AS
SELECT ha.intHACode
	,HACodeName.[name] AS CodeName
	,ha.intRowStatus
FROM dbo.trtHACodeList ha
LEFT JOIN dbo.FN_GBL_Reference_GETList(@LangID, 19000040) AS HACodeName ON HACodeName.idfsReference = ha.idfsCodeName
WHERE ha.intHACode & @intHACodeMask > 0
	AND ha.idfsCodeName <> 10040001 --All
ORDER BY HACodeName.intOrder
	,HACodeName.name;
