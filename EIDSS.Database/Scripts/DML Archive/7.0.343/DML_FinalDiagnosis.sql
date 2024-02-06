DECLARE @DateTable TABLE
(
	idfHumanCase BIGINT,
	datFinalDiagnosis DATETIME,
	datChangedDate DATETIME

)

INSERT INTO @DateTable
(
    idfHumanCase,
    datFinalDiagnosis,
    datChangedDate
)
SELECT
	T.idfHumanCase,
	T.datFinalDiagnosisDate,
	MAX(S.datChangedDate)

FROM dbo.tlbHumanCase T
INNER JOIN dbo.tlbChangeDiagnosisHistory S ON S.idfHumanCase = T.idfHumanCase and S.intRowStatus = 0
WHERE S.datChangedDate > T.datFinalDiagnosisDate
GROUP BY 
	T.idfHumanCase,
	T.datFinalDiagnosisDate

UPDATE T
SET T.datFinalDiagnosisDate = S.datChangedDate
FROM dbo.tlbHumanCase T
INNER JOIN @DateTable S ON S.idfHumanCase = T.idfHumanCase 
