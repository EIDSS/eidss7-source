/*Author:        Stephen Long
Date:            03/17/2023
Description:     Set test unassigned indicator for laboratory module.
*/
UPDATE dbo.tlbMaterial SET TestUnassignedIndicator = 0
WHERE blnAccessioned = 0
      OR idfsSampleStatus <> 10015007; -- In Repository