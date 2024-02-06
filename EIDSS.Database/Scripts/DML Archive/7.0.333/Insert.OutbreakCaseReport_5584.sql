/*
Author:			Stephen Long
Date:			02/10/2023
Description:	Add outbreak case records for migrated records; bug 5584.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/
DECLARE @Identifiers TABLE
(
    ID BIGINT NOT NULL,
    OutbreakID BIGINT NOT NULL
);

DECLARE @Id BIGINT,
        @OutbreakID BIGINT,
        @OutBreakCaseReportUID BIGINT;

INSERT INTO @Identifiers
SELECT idfHumanCase,
       idfOutbreak
FROM dbo.tlbHumanCase
WHERE idfOutbreak IS NOT NULL;

WHILE EXISTS (SELECT * FROM @Identifiers)
BEGIN
    SELECT TOP 1
        @Id = ID,
        @OutbreakID = OutbreakID
    FROM @Identifiers;

    IF NOT EXISTS (SELECT * FROM OutbreakCaseReport WHERE idfHumanCase = @Id)
    BEGIN
        EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
                                       @OutBreakCaseReportUID OUTPUT;

        DECLARE @strOutbreakCaseID NVARCHAR(200);

        EXEC dbo.USP_GBL_NextNumber_GET 'Human Outbreak Case',
                                        @strOutbreakCaseID OUTPUT,
                                        NULL;

        --Generate a shell record in the case table to denote the item from the human case being imported
        --Below is the minimal amount of fields needed to create the case. All other information will be entered
        --during the editing phase
        INSERT INTO dbo.OutbreakCaseReport
        (
            OutBreakCaseReportUID,
            idfOutbreak,
            strOutbreakCaseID,
            idfHumanCase,
            intRowStatus,
            AuditCreateUser,
            AuditCreateDTM,
            AuditUpdateUser,
            AuditUpdateDTM
        )
        VALUES
        (@OutBreakCaseReportUID, @OutbreakID, @strOutbreakCaseID, @Id, 0, 'System', GETDATE(), NULL, NULL);
    END

    DELETE FROM @Identifiers
    WHERE ID = @ID;
END

INSERT INTO @Identifiers
SELECT idfVetCase,
       idfOutbreak
FROM dbo.tlbVetCase
WHERE idfOutbreak IS NOT NULL;

WHILE EXISTS (SELECT * FROM @Identifiers)
BEGIN
    SELECT TOP 1
        @Id = ID,
        @OutbreakID = OutbreakID
    FROM @Identifiers;

    IF NOT EXISTS (SELECT * FROM OutbreakCaseReport WHERE idfVetCase = @Id)
    BEGIN
        EXEC dbo.USP_GBL_NEXTKEYID_GET 'OutbreakCaseReport',
                                       @OutBreakCaseReportUID OUTPUT;

        --DECLARE @strOutbreakCaseID NVARCHAR(200);

        EXEC dbo.USP_GBL_NextNumber_GET 'Vet Outbreak Case',
                                        @strOutbreakCaseID OUTPUT,
                                        NULL;

        --Generate a shell record in the case table to denote the item from the human case being imported
        --Below is the minimal amount of fields needed to create the case. All other information will be entered
        --during the editing phase
        INSERT INTO dbo.OutbreakCaseReport
        (
            OutBreakCaseReportUID,
            idfOutbreak,
            strOutbreakCaseID,
            idfVetCase,
            intRowStatus,
            AuditCreateUser,
            AuditCreateDTM,
            AuditUpdateUser,
            AuditUpdateDTM
        )
        VALUES
        (@OutBreakCaseReportUID, @OutbreakID, @strOutbreakCaseID, @Id, 0, 'System', GETDATE(), NULL, NULL);
    END

    DELETE FROM @Identifiers
    WHERE ID = @ID;
END