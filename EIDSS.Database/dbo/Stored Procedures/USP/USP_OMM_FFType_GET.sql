

--=====================================================================================================
-- Author:					Mark Wilson
-- Description:				04/09/2020  
--							
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -----------------------------------------------
-- 
--
-- Test Code:
-- EXEC dbo.USP_OMM_FFType_GET 'en' -- List the FF Types for Outbreak
-- 
--
--=====================================================================================================
CREATE PROCEDURE [dbo].[USP_OMM_FFType_GET] 
(
	@LangID NVARCHAR(20) = 'en'

)
AS
BEGIN
	SELECT 
		idfsReference AS idfsFFType,
		[name] AS strFFType
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000034) 
	WHERE idfsReference IN (10034501,10034502,10034503,10034504,10034505,10034506,10034507,10034508,10034509,10034015,10034011,10034007)

	ORDER BY intOrder

END

