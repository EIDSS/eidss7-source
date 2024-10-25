/*
    Mike Kornegay
    3/8/2023
    Post migration script for basic syndromic age.

*/

--correct basic syndromic surveillance records by adding age and age type
DECLARE @BSS TABLE
(
    HumanId BIGINT,
    ReportAge INT,
	ReportAgeUOMId BIGINT,
	ReportDate DATETIME
)

BEGIN TRANSACTION

INSERT INTO @BSS
(
    HumanId,
    ReportAge,
	ReportAgeUOMId,
	ReportDate
)
SELECT
    idfHuman,
	intAgeYear,
	10042003,
	datReportDate
FROM 
	EIDSS_GG_DeId.dbo.tlbBasicSyndromicSurveillance

UPDATE HAI
SET 
	HAI.ReportedAge = B.ReportAge,
	HAI.ReportedAgeUOMID = B.ReportAgeUOMId,
	HAI.ReportedAgeDTM = B.ReportDate
FROM dbo.HumanAddlInfo HAI
INNER JOIN @BSS B ON B.HumanId = HAI.HumanAdditionalInfo

COMMIT TRANSACTION
GO
