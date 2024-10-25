
--=================================================================================================
-- Name: usp_HumanAggregateCaseParameter_GetLookup
--
-- Description: Created based on V6 spHumanAggregateCaseParameter_SelectLookup: V7 USP76
-- Selects lookup list of human aggregate case parameters for AVR module from these tables: 
-- ffParameter.
--
-- Author: Joan Li
--
-- Revision History:
-- Name                 Date       Change Detail
-- -------------------- ---------- ---------------------------------------------------------------
-- Joan Li              06/21/2017 Initial release.
-- Stephen Long         12/26/2019 Replaced with v7 function calls.
--
-- Testing Code:
-- EXEC usp_HumanAggregateCaseParameter_GetLookup 'en'
-- Related fact data from
-- select * from tlbActivityParameters
-- select * from tflObservationFiltered
--=================================================================================================
CREATE PROCEDURE [dbo].[usp_HumanAggregateCaseParameter_GetLookup] @LangID NVARCHAR(50)
AS
SELECT p.idfsParameter,
	r_p.[name]
FROM dbo.ffParameter p
INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000034) ft -- Form Type
	ON ft.idfsReference = p.idfsFormType
		AND ft.idfsReference = 10034012 -- Human Aggregate Case
INNER JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000066) r_p -- Flexible Form Parameter
	ON r_p.idfsReference = p.idfsParameter
WHERE p.intRowStatus = 0

RETURN 0
