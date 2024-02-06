--Select Char(2 + 64)

--select sqrt(25)
--SELECT Report.FN_REP_NoOfLocationsWithFreezerLocations(25)
-- Name             Date		Change Detail
-- Srini Goli		09/27/2022	Created to display Occupied Freezers
-- SELECT [Report].[FN_REP_NoOfLocationsWithFreezerLocations] (25,12429860001232)
CREATE FUNCTION [Report].[FN_REP_NoOfLocationsWithFreezerLocations] (@BoxSize int,@idfSubdivision BIGINT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @tmp varchar(250),
			@count INT,
			@Loop INT,
			@StringRow varchar(MAX)='  ',
			@FinalStringRow varchar(MAX)='';
	DECLARE  @BoxDetails TABLE(BoxColumn NVARCHAR(5),BoxRow INT,AvailabilityIndicator NVARCHAR(2))
	SET @Loop=sqrt(@BoxSize)
	SET @count = 1

	WHILE @count<= @Loop
	BEGIN
	   SET @StringRow= @StringRow +' ' +Char(@count + 64)
	   SET @count = @count + 1
	END;


	SET @count = 1
	INSERT INTO @BoxDetails(BoxColumn,BoxRow,AvailabilityIndicator)
	SELECT 
		LEFT(BOX.[BoxLocation],1) AS BoxColumn,
		SUBSTRING(BOX.[BoxLocation],2,LEN(BOX.[BoxLocation])) AS BoxRow,
		IIF(BOX.[AvailabilityIndicator]='true','0','X') As AvailabilityIndicator
	FROM dbo.tlbFreezerSubdivision 
	CROSS APPLY OPENJSON(BoxPlaceAvailability) 
	WITH ( [BoxLocation] NVARCHAR(50),
	[AvailabilityIndicator] NVARCHAR(50)
	) As BOX
	WHERE idfSubdivision=@idfSubdivision


	WHILE @count<= @Loop
	BEGIN
	SET @tmp = ''
	select @tmp = @tmp + AvailabilityIndicator + ' ' 
	from @BoxDetails where BoxRow=@count order by BoxColumn

	   SET @FinalStringRow= @FinalStringRow + CAST(@count as Varchar(15) ) + ' ' +@tmp +IIF(@count<>@Loop,CHAR(10)+CHAR(13),'');
	   SET @count = @count + 1;
	   --INSERT INTO @TablenameList SELECT @FinalStringRow
	END;

 RETURN @StringRow+CHAR(10)+CHAR(13)+@FinalStringRow;

END;


GO


