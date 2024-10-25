CREATE FUNCTION [dbo].[FN_GBL_HumanGenderNames_ToCSV]
(
	@LangID	NVARCHAR(50),
	@DisgnosisGroupID BIGINT
)
RETURNS NVARCHAR(4000)
AS
BEGIN

DECLARE
@CSV NVARCHAR(4000) = N''; -- size string returned by STRING_AGG

	WITH cteOrderedResults([name]) as
	(
		
		SELECT [name] FROM DiagnosisGroupToGender dgg 
		join FN_GBL_Reference_GETList('en', 19000043) hg ON dgg.GenderID = hg.idfsReference
		WHERE DisgnosisGroupID = @DisgnosisGroupID AND DGG.intRowStatus = 0
	)

	SELECT @CSV = STRING_AGG(CAST([name] as NVARCHAR(100)), N',')
	FROM cteOrderedResults;	-- needed CTE to get ordered result set due to AGGREGATE function

	-- if passed an invalid HACode that doesn't match any of the bitmap masks, then return 0 which is 'none'.
	IF (@CSV IS NULL OR LEN(@CSV) = 0)
		SET @CSV = N'0';

RETURN @CSV;

END
