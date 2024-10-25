

--*************************************************************************
-- Name 				: dbo.USP_REP_ILI_AgeGroups_GETList
-- Description			: List of Age Groups for ILI Aberration Analysis
--						 
--          
-- Author               : Mark Wilson
-- Revision History
--		Name			Date       Change Detail
--
-- Testing code:
--
-- EXEC dbo.USP_REP_ILI_AgeGroups_GETList 'ka'
-- EXEC dbo.USP_REP_ILI_AgeGroups_GETList 'en'
--*************************************************************************
CREATE PROCEDURE [dbo].[USP_REP_ILI_AgeGroups_GETList] 
(
	@LangID NVARCHAR(12) = 'en'

)
AS 
BEGIN

	DECLARE @AgeGroup TABLE
	(
		idfsAgeGroup NVARCHAR(100),
		strAgeGroup VARCHAR(20)

	)


	INSERT INTO @AgeGroup
	(
		idfsAgeGroup,
		strAgeGroup
	)


	SELECT
		CAST(idfsReference AS NVARCHAR(100)),
		[name]
	
	FROM dbo.FN_GBL_ReferenceRepair(@LangID, 19000163)
	WHERE strDefault IN ('   0-4','   5-14','  15-29','  30-64',' >= 65',' Total ILI')

	SELECT * FROM @AgeGroup

END
