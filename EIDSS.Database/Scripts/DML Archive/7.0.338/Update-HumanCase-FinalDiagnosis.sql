/*
Mike Kornegay (from Mark Wilson)
3/8/2023
Update fimal diagnosis date for migrated HDR's.

*/

UPDATE T
SET T.datFinalDiagnosisDate = 
	CASE 
		WHEN S.datChangedDate > T.datFinalDiagnosisDate 
		THEN S.datChangedDate 
		ELSE T.datFinalDiagnosisDate 
	END
FROM dbo.tlbHumanCase T
INNER JOIN dbo.tlbChangeDiagnosisHistory S ON S.idfHumanCase = T.idfHumanCase