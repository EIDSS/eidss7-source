-- ================================================================================================
-- Name: USP_LAB_SAMPLE_BAR_CODE_GETList
--
-- Description:	Get sample list for the laboratory module use case LUC01 and LUC02.
--                      
-- Revision History:
-- Name             Date       Change Detail
-- ---------------- ---------- -------------------------------------------------------------------
-- Stephen Long     01/15/2019 Initial release.
-- Stephen Long     03/01/2019 Added return code and return message.
-- Stephen Long     09/25/2021 Cleaned up formatting.
-- Stephen Long     02/11/2022 Changed where criteria to strBarcode.
-- ================================================================================================
CREATE PROCEDURE [dbo].[USP_LAB_SAMPLE_BAR_CODE_GETList]
(
    @LanguageID NVARCHAR(50),
    @SampleList NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @ReturnCode INT = 0,
            @ReturnMessage VARCHAR(MAX) = 'SUCCESS';

    BEGIN TRY
        SET NOCOUNT ON;

        SELECT idfMaterial AS SampleID,
               strBarcode AS EIDSSLaboratorySampleID,
               strCalculatedHumanName AS PatientOrFarmOwnerName
        FROM dbo.tlbMaterial
        WHERE strBarcode IN ( @SampleList )
        ORDER BY strBarcode;

        SELECT @ReturnCode,
               @ReturnMessage;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
