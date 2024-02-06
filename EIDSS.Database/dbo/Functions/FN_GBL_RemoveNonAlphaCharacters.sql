-- =============================================
-- Author:		Doug Albanese
-- Create date: 9/15/2020
-- Description:	Function needed to strip out anything that is not numeric or alpha
-- =============================================
CREATE Function [dbo].[FN_GBL_RemoveNonAlphaCharacters](@Temp NVarChar(MAX), @function INT = 0, @clearSpaces BIT = 0)
Returns NVarChar(MAX)
AS
Begin

	--Flag Legend
	--1 = Alphabetic Only
	--2 = Numeric Only
	--3 = Alphanumeric Only
	--4 = Non-Alphanumeric Only

	IF @function = 1
		BEGIN
			While PatIndex('%[^a-z]%', @Temp) > 0
				Set @Temp = Stuff(@Temp, PatIndex('%[^a-z]%', @Temp), 1, '')	
		END

	IF @function = 2
		BEGIN
			While PatIndex('%[^0-9]%', @Temp) > 0
				Set @Temp = Stuff(@Temp, PatIndex('%[^0-9]%', @Temp), 1, '')	
		END
		
	IF @function = 3
		BEGIN
			While PatIndex('%[^a-z0-9]%', @Temp) > 0
				Set @Temp = Stuff(@Temp, PatIndex('%[^a-z0-9]%', @Temp), 1, '')	
		END


	IF @function = 4
		BEGIN
			While PatIndex('%[a-z0-9]%', @Temp) > 0
				Set @Temp = Stuff(@Temp, PatIndex('%[a-z0-9]%', @Temp), 1, '')	
		END

	IF @clearSpaces = 1
		BEGIN
			SET @Temp = REPLACE(@Temp, ' ', '')
		END

    Return @Temp
End
