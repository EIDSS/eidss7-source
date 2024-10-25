

--*************************************************************
-- Name 				: USP_GBL_MonthNames_GETList
-- Description			: SELECTs Months for a given languate
--          
-- Author               : Lamont Mitchell
-- Revision History
--		Name		Date		Change Detail
--		LAMONT M	08/17/2020	ORIGINAL
-- Testing code:
--*************************************************************
CREATE PROCEDURE [dbo].[USP_GBL_MonthNames_GETList]
(  

 	@LangID						NVARCHAR(50)	--##PARAM @LangID - language ID  
)  
AS  

DECLARE @returnMsg				VARCHAR(MAX) = 'Success';
DECLARE @returnCode				BIGINT = 0;

BEGIN
	BEGIN TRY  	
		Select idfsReference,name,idfsReferenceType,strDefault,LongName, intOrder from dbo.FN_GBL_ReferenceRepair(@LangID,19000132)
		where intOrder between 1 AND 12 and intRowStatus = 0
		order by intOrder
	END TRY  
	BEGIN CATCH 

	Throw;

	END CATCH
END


