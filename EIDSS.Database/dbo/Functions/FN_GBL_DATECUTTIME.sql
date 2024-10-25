

--*************************************************************************
-- Name 				: report.FN_GBL_DATECUTTIME
--
-- Description			: Cuts the time portion from the date time 
-- 
-- Author               : Mandar Kulkarni
-- Revision History
--		Name			DATE       Change Detail

-- Testing code:

--Example of function call:

--SELECT dbo.FN_GBL_DATECUTTIME(GetDate())
--*************************************************************************

CREATE FUNCTION [dbo].[FN_GBL_DATECUTTIME](
	@Date DateTime --##PARAM @Date - date to convert
)
RETURNS DateTime 
AS
BEGIN
	RETURN CONVERT(datetime,CONVERT(varchar,@Date,1),1)
END	


