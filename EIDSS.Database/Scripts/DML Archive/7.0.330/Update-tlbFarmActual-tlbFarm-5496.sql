/*
    Mike Kornegay
    2/1/2023
    Post migration script for farm email address.

*/

--correct tlbFarm records
DECLARE @EmailTable TABLE
(
    idfFarm BIGINT,
    strEmail NVARCHAR(200)
)

INSERT INTO @EmailTable
(
    idfFarm,
    strEmail
)
SELECT
    idfFarm,
    CAST(strEmail COLLATE Latin1_General_CS_AS AS NVARCHAR(200))
FROM EIDSS_GG_DeId.dbo.tlbFarm
WHERE strEmail IS NOT NULL AND strEmail <> ''


UPDATE T
SET T.strEmail = CAST(S.strEmail COLLATE Latin1_General_CS_AS AS NVARCHAR(200))
FROM dbo.tlbFarm T
INNER JOIN @EmailTable S ON S.idfFarm = T.idfFarm
GO

--correct tlbFarmActual records
DECLARE @EmailTableActual TABLE
(
    idfFarmActual BIGINT,
    strEmail NVARCHAR(200)
)

INSERT INTO @EmailTableActual
(
    idfFarmActual,
    strEmail
)
SELECT
    idfFarmActual,
    CAST(strEmail COLLATE Latin1_General_CS_AS AS NVARCHAR(200))
FROM EIDSS_GG_DeId.dbo.tlbFarmActual
WHERE strEmail IS NOT NULL AND strEmail <> ''


UPDATE T
SET T.strEmail = CAST(S.strEmail COLLATE Latin1_General_CS_AS AS NVARCHAR(200))
FROM dbo.tlbFarmActual T
INNER JOIN @EmailTableActual S ON S.idfFarmActual = T.idfFarmActual
GO
