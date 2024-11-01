SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [dbo].[fnSplitString2](
	@listOne    nvarchar(MAX),
	@delimiter	char(1) = N','
)

RETURNS @tbl TABLE (
	listpos int IDENTITY(1, 1) NOT NULL,
	strOne nvarchar(MAX)
) AS BEGIN

	DECLARE @pos      int,
			@tmpstr   nvarchar(max),
			@tmpval   nvarchar(MAX)

	SET @tmpstr = @listOne
	SET @pos = charindex(@delimiter, @tmpstr)

	WHILE (@pos > 0)
	BEGIN

		SET @tmpval = ltrim(rtrim(left(@tmpstr, @pos - 1)))
		INSERT @tbl (strOne) VALUES(@tmpval)

		SET @tmpstr = substring(@tmpstr, @pos + 1, len(@tmpstr))
		SET @pos = charindex(@delimiter, @tmpstr)

	END
	INSERT @tbl(strOne)	VALUES (ltrim(rtrim(@tmpstr)))

	RETURN

END

