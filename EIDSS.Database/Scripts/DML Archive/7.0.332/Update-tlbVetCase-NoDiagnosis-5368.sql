/*
	Mike Kornegay
	2/2/2023
	This script updates the disease reports that were created
	from veterinary surveillance sessions but were created with aggregate
	diseases instead of standard diseases.  This should not have been
	permitted.  This script deactivates those reports if any.

*/

--set the disease reports with aggregate diseases to inactive
UPDATE vc 
SET vc.intRowStatus = 1
FROM tlbVetCase vc
INNER JOIN trtDiagnosis d
ON d.idfsDiagnosis = vc.idfsFinalDiagnosis
WHERE d.idfsUsingType = 10020002