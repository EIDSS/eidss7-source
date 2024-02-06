-- ================================================================================================
-- Name: report.USP_REP_Lim_AliquotBarCodes_GET
--
-- Description:	Select data for transfer report, aliquots/derivatives and print bar codes in 
-- general for the laboratory module.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Mark Wilson		12/13/2021 Initial Version, converted to E7 standards
-- Stephen Long     03/31/2023 Changed date to the current date to match the use case (#4964).
-- Stephen Long     04/10/2023 Added format for localization of date.

/*
--Example of a call of procedure:

exec report.USP_REP_Lim_AliquotBarCodes_GET 
	@LangID=N'en-US',
	@SamplesList='42306380001294,8959170001183'
*/
-- ================================================================================================
CREATE PROCEDURE [Report].[USP_REP_Lim_AliquotBarCodes_GET]
(
    @LangID AS NVARCHAR(20),
    @SamplesList AS NVARCHAR(MAX)
)
AS
BEGIN

    SELECT (ROW_NUMBER() OVER (ORDER BY m.strCalculatedHumanName, GETDATE()) + 1)
           - ((ROW_NUMBER() OVER (ORDER BY m.strCalculatedHumanName, GETDATE()) - 1) % 4) AS RowGroup,
           1 + ((ROW_NUMBER() OVER (ORDER BY m.strCalculatedHumanName, GETDATE()) - 1) % 4) AS ColumGroup,
           m.idfMaterial,
           FORMAT(GETDATE(), 'd', @LangID) datEnteringDate,
           m.strBarcode,
           m.strCalculatedHumanName AS FullName
    FROM dbo.tlbMaterial m
    WHERE m.strBarcode IS NOT NULL
          AND m.idfMaterial IN (
                                   SELECT VALUE FROM STRING_SPLIT(@SamplesList, ',')
                               )
          AND m.intRowStatus = 0;

END
