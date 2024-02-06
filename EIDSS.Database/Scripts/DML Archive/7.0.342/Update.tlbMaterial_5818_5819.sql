/*Author:        Stephen Long
Date:            03/29/2023
Description:     Set test completed and unassigned indicators for laboratory module.
*/

-- Un-accessioned samples
UPDATE dbo.tlbMaterial 
SET TestUnassignedIndicator = 0, 
    TestCompletedIndicator = 0
WHERE blnAccessioned = 0
      AND idfsAccessionCondition IS NULL
      AND idfsSampleStatus IS NULL;

-- Rejected samples
UPDATE dbo.tlbMaterial 
SET TestUnassignedIndicator = 0, 
    TestCompletedIndicator = 0
WHERE idfsAccessionCondition = 10108003;

-- Transferred out samples
UPDATE dbo.tlbMaterial 
SET TestUnassignedIndicator = 0
WHERE idfsSampleStatus = 10015010 -- Transferred Out
      AND
      (
          SELECT COUNT(tr.idfTransferOut)
          FROM dbo.tlbTransferOutMaterial tom
              INNER JOIN dbo.tlbTransferOUT tr
                  ON tr.idfTransferOut = tom.idfTransferOut
          WHERE tom.idfMaterial = idfMaterial
                AND tr.intRowStatus = 0
                AND tr.idfsTransferStatus = 10001003 -- Final
      ) = 0;

UPDATE dbo.tlbMaterial 
SET TestUnassignedIndicator = 0
WHERE idfsSampleStatus IN ( 10015002, 10015003, 10015008, 10015009 ); -- Marked for Deletion, Marked for Routine Destruction, Destroyed and Deleted

-- Accessioned in with no tests currently assigned and no tests finalized or amended
UPDATE dbo.tlbMaterial
SET TestUnassignedIndicator = 1, 
    TestCompletedIndicator = 0
WHERE blnAccessioned = 1
      AND datAccession IS NOT NULL
      AND idfsAccessionCondition IS NOT NULL
      AND strBarcode IS NOT NULL
      AND idfsSampleStatus = 10015007 -- In Repository
      AND
      (
          SELECT COUNT(*)
          FROM dbo.tlbTesting t
          WHERE t.idfMaterial = idfMaterial
                AND t.intRowStatus = 0
                AND t.blnNonLaboratoryTest = 0
                AND t.idfsTestStatus IN ( 10001003, 10001004, 10001005 ) -- In Progress, Preliminary and Not Started
      ) = 0
      AND
      (
          SELECT COUNT(*)
          FROM dbo.tlbTesting t
          WHERE t.idfMaterial = idfMaterial
                AND t.intRowStatus = 0
                AND t.blnNonLaboratoryTest = 0
                AND t.idfsTestStatus IN ( 10001001, 10001006 ) -- Final and Amended
      ) = 0;

-- Accessioned in with at least one test currently assigned and no tests finalized or amended
UPDATE dbo.tlbMaterial
SET TestUnassignedIndicator = 0, 
    TestCompletedIndicator = 0
WHERE blnAccessioned = 1
      AND datAccession IS NOT NULL
      AND idfsAccessionCondition IS NOT NULL
      AND strBarcode IS NOT NULL
      AND idfsSampleStatus = 10015007 -- In Repository
      AND
      (
          SELECT COUNT(*)
          FROM dbo.tlbTesting t
          WHERE t.idfMaterial = idfMaterial
                AND t.intRowStatus = 0
                AND t.blnNonLaboratoryTest = 0
                AND t.idfsTestStatus IN ( 10001003, 10001004, 10001005 ) -- In Progress, Preliminary and Not Started
      ) > 0
      AND
      (
          SELECT COUNT(*)
          FROM dbo.tlbTesting t
          WHERE t.idfMaterial = idfMaterial
                AND t.intRowStatus = 0
                AND t.blnNonLaboratoryTest = 0
                AND t.idfsTestStatus IN ( 10001001, 10001006 ) -- Final and Amended
      ) = 0;

-- Accessioned in with at least one test finalized or amended
UPDATE dbo.tlbMaterial
SET TestUnassignedIndicator = 0, 
    TestCompletedIndicator = 1
WHERE blnAccessioned = 1
      AND datAccession IS NOT NULL
      AND idfsAccessionCondition IS NOT NULL
      AND strBarcode IS NOT NULL
      AND idfsSampleStatus = 10015007 -- In Repository
      AND
      (
          SELECT COUNT(*)
          FROM dbo.tlbTesting t
          WHERE t.idfMaterial = idfMaterial
                AND t.intRowStatus = 0
                AND t.blnNonLaboratoryTest = 0
                AND t.idfsTestStatus IN ( 10001001, 10001006 ) -- Final and Amended
      ) > 0;