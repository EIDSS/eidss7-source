-- ===========================================================================
-- Author:		Steven Verner
-- Create date: 12/1/2021
-- Description:	Returns the complete location hierarchy for the given location 
-- ===========================================================================
CREATE FUNCTION [dbo].[FN_GBL_LocationHierarchy](@idfsLocation BIGINT, @languageId nvarchar(20))
RETURNS @returnTable TABLE 
(
	 idfsLocation BIGINT
	,Level INT
	,AdminLevelName NVARCHAR(200)
	,AdminLevelType NVARCHAR(100)
	,Node HIERARCHYID
)
AS
BEGIN
	DECLARE @hi HIERARCHYID 
	
	SELECT @hi = Node FROM gisLocation l WHERE l.idfsLocation = @idfsLocation

	INSERT INTO @returnTable
    SELECT 
		 l.idfsLocation
        ,l.Node.GetLevel() 
		,COALESCE(snt.strTextString, b.strDefault) 
		,t.strGISReferenceTypeName
        ,Node
    FROM gisLocation l
    JOIN gisBaseReference b on b.idfsGISBaseReference = l.idfsLocation
	JOIN gisReferenceType t on t.idfsGISReferenceType = b.idfsGISReferenceType
	LEFT JOIN trtBaseReference br ON br.strBaseReferenceCode = @LanguageID AND b.idfsGISReferenceType = 19000049
    LEFT JOIN dbo.gisStringNameTranslation snt ON snt.idfsGISBaseReference = b.idfsGISBaseReference AND snt.idfsLanguage = dbo.FN_GBL_LanguageCode_GET(@LanguageId)
    WHERE @hi.IsDescendantOf(node) = 1
   
   RETURN
END
