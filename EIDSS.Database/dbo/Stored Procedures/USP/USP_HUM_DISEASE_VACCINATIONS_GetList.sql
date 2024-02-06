--*************************************************************
-- Name 				: USP_HUM_DISEASE_VACCINATIONS_GetList
-- Description			: List Human Disease Report Vaccinations by HDID
--          
-- Author               : HAP
-- Revision History
--		Name		Date       Change Detail
-- ---------------- ---------- --------------------------------
--     Minal Shah	10/14/2021	Removed additional return statement
--
-- Testing code:
-- EXEC USP_HUM_DISEASE_VACCINATIONS_GetList @LangID = 'en', @idfHumanCase  = 19 
-- Updated fields to Proper Case
--*************************************************************
CREATE PROCEDURE [dbo].[USP_HUM_DISEASE_VACCINATIONS_GetList] 
@idfHumanCase 	bigint,		
@LangID			nvarchar(50)
AS
Begin
	DECLARE @returnMsg				VARCHAR(MAX) = 'Success';
	DECLARE @returnCode				BIGINT = 0;

BEGIN TRY  
		select  
		   drv.HumanDiseaseReportVaccinationUID,
		   drv.idfHumanCase,		
		   drv.VaccinationName as vaccinationName,
		   drv.VaccinationDate	as vaccinationDate
        
		from  HumanDiseaseReportVaccination  drv
		inner join tlbHumanCase  hc
			on   hc.idfHumanCase = drv.idfHumanCase  		
		where  
			drv.idfHumanCase = @idfHumanCase  
			and 
			drv.intRowStatus = 0 

		--SELECT @returnCode 'ReturnCode', @returnMsg 'ResturnMessage';
	END TRY  

	BEGIN CATCH 
		THROW;

	END CATCH
END
