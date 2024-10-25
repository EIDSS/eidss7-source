--##SUMMARY Gets the last index of presence of the specified substring in the specified original string
--##SUMMARY with optional right-to-left direction of the text.
--##SUMMARY If an original string doesn't contain specifed substring, the returns -1.

--##REMARKS Author: 
--##REMARKS Create date: 24.02.2014

--##RETURNS int


/*
declare	@s nvarchar(2000) = N'  ascvn .lklokj lk   '

select dbo.fnGetLastCharIndexOfSubstringInNonTrimString(@s, N'lk', 0)
*/	

CREATE function [dbo].[fnGetLastCharIndexOfSubstringInNonTrimString]
(
	@SourceStr nvarchar(4000),	--##PARAM @SourceStr - string value to find the last presence of substring
	@SubStr nvarchar(4000),		--##PARAM @SubStr - string value to find as substring in source string
	@IsRTL bit = 0				--##PARAM @IsRTL - indicator whether the string is right to left or regular
)
returns int
as 
begin

declare @str nvarchar(4000) = ltrim(rtrim(@SourceStr))
declare	@CurPos int = -1
declare	@LastPos int = -1

if	@IsRTL = 1
begin
	set	@LastPos = CHARINDEX(@SubStr, @str, 0)
end
else begin
	declare	@len int = len(@str)


	while @CurPos < @len
	begin
		set @CurPos = CHARINDEX(@SubStr, @str, @CurPos + 1)
		if @CurPos <= 0
			set @CurPos = @len + 1
		else
			set	@LastPos = @CurPos
	end
end

return @LastPos

end

GO
