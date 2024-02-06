/*Author:        Stephen Long
Date:            04/13/2023
Description:     Update resource set to resource for 824.  Resource set should be 115 not 70.
*/
IF EXISTS (SELECT * FROM dbo.trtResourceSetToResource WHERE idfsResourceSet = 70 AND idfsResource = 824)
BEGIN
    UPDATE dbo.trtResourceSetToResource SET idfsResourceSet = 115 WHERE idfsResource = 824 AND idfsResourceSet = 70
END