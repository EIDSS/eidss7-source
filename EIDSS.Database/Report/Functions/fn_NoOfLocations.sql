

--Select Char(2 + 64)

--select sqrt(25)
--DROP FUNCTION  dbo.fn_NoOfLocations;

--SELECT Report.fn_NoOfLocations(25)
-- Name             Date		Change Detail
-- Srini Goli		09/19/2022	Updated row and column heading as per application
CREATE FUNCTION [Report].[fn_NoOfLocations] (@BoxSize int)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @count INT,
			@Loop INT,
			@StringRow varchar(MAX)='  ',
			@FinalStringRow varchar(MAX)='';
	--DECLARE @TablenameList table(StringRow varchar(MAX));
	SET @Loop=sqrt(@BoxSize);
	SET @count = 1;
    
	WHILE @count<= @Loop
	BEGIN
	   SET @StringRow= @StringRow +' ' +Char(@count + 64);
	   SET @count = @count + 1;
	END;
	--INSERT INTO @TablenameList SELECT @StringRow

	SET @count = 1;
	WHILE @count<= @Loop
	BEGIN
	   SET @FinalStringRow= @FinalStringRow + CAST(@count as Varchar(15) ) + ' ' +REPLICATE('0 ',@Loop) +IIF(@count<>@Loop,CHAR(10)+CHAR(13),'');
	   SET @count = @count + 1;
	   --INSERT INTO @TablenameList SELECT @FinalStringRow
	END;

 RETURN @StringRow+CHAR(10)+CHAR(13)+@FinalStringRow;

END;


