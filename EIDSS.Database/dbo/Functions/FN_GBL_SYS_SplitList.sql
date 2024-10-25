--*************************************************************
-- Name 				: dbo.FN_GBL_SYS_SplitList
-- Description			: Returns table of two columns containing 
--						  an index and the list of values
--						
-- Author               : Mark Wilson
-- Revision History
--
--		Name       Date       Change Detail
--
-- Testing code:
--
-- SELECT * FROM dbo.FN_GBL_SYS_SplitList('a,b,c,d,e,f,g,h', 0, ',')
--
--*************************************************************

CREATE FUNCTION [dbo].[FN_GBL_SYS_SplitList]
(
	@List NVARCHAR(MAX),
	@ShowEmpty BIT = 1,
	@DelimiterSymbol NVARCHAR(1) = ';' -- default delimiter
)
RETURNS @ResTable TABLE
(
    num INT PRIMARY KEY,
    Value SQL_VARIANT
)
AS 
BEGIN
    DECLARE	
        @StartIndex				BIGINT,
		@Index 					BIGINT,
		@num					INT,
		@Value 					NVARCHAR(100)
	SELECT
        @StartIndex	= 1,
		@num = 1	
	IF (@DelimiterSymbol IS NULL) SET @DelimiterSymbol = ';'

    --Add a Delimiter symbol to the end of the list if it does not exist
    IF LEN(ISNULL(@List,'')) > 0
        IF (right(@List, 1) <> @DelimiterSymbol)
            SET @List = @List + @DelimiterSymbol

    WHILE(1=1)
    BEGIN
        SET @Index = CHARINDEX(@DelimiterSymbol, @List, @StartIndex)

        IF @Index <= 0 OR @Index IS NULL
            BREAK;
		SET @Value = LTRIM(RTRIM(SUBSTRING(@List, @StartIndex, @Index-@StartIndex)))
		IF @ShowEmpty = 1 OR @Value <> ''
		BEGIN 
			INSERT INTO @ResTable
			VALUES (@num, @Value)
		END
		
		SELECT
			@num = @num + 1,
			@StartIndex = @Index + 1
    END;

	RETURN
END

