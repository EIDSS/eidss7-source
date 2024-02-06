/*Author:        Stephen Long
Date:            05/26/2023
Description:     Update basic syndromic surveillance records converted to human disease reports status to closed.
*/

IF EXISTS(SELECT * FROM dbo.tlbHumanCase WHERE idfsCaseProgressStatus = 19000111)
BEGIN
	UPDATE dbo.tlbHumanCase
	SET idfsCaseProgressStatus = 10109002
	WHERE idfsCaseProgressStatus = 19000111
END