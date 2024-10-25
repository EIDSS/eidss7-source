/*
Author:			Stephen Long
Date:			03/10/2023
Description:	Update strCalculatedCaseID to get the values from HDR, VDR and monitoring sessions for #43.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/
DECLARE @Identifiers TABLE (OutbreakID BIGINT NOT NULL);

DECLARE @OutbreakID BIGINT,
        @OutbreakSpeciesParameterUID BIGINT;

INSERT INTO @Identifiers
SELECT idfOutbreak
FROM dbo.tlbOutbreak
WHERE OutbreakTypeID = 10513001;

WHILE EXISTS (SELECT * FROM @Identifiers)
BEGIN
    SELECT TOP 1
        @OutbreakID = OutbreakID
    FROM @Identifiers;

    IF NOT EXISTS
    (
        SELECT *
        FROM OutbreakSpeciesParameter
        WHERE idfOutbreak = @OutbreakID
    )
    BEGIN
        EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'OutbreakSpeciesParameter',
                                       @idfsKey = @OutbreakSpeciesParameterUID OUTPUT;

        INSERT INTO dbo.OutbreakSpeciesParameter
        (
            OutbreakSpeciesParameterUID,
            idfOutbreak,
            OutbreakSpeciesTypeID,
            CaseMonitoringDuration,
            CaseMonitoringFrequency,
            ContactTracingDuration,
            ContactTracingFrequency,
            intRowStatus,
            rowguid,
            SourceSystemNameID,
            SourceSystemKeyValue,
            AuditCreateUser,
            AuditCreateDTM
        )
        VALUES
        (@OutbreakSpeciesParameterUID,
         @OutbreakID,
         10514001,
         NULL,
         NULL,
         NULL,
         NULL,
         0  ,
         NEWID(),
         10519001,
         '[{"OutbreakSpeciesParameterUID":' + CAST(@OutbreakSpeciesParameterUID AS NVARCHAR(300)) + '}]',
         'System',
         GETDATE()
        );
    END

    DELETE FROM @Identifiers
    WHERE OutbreakID = @OutbreakID;
END

DECLARE @CaseIdentifiers TABLE
(
    ID BIGINT NOT NULL,
    OutbreakID BIGINT NOT NULL
);

DECLARE @Id BIGINT,
        @OutBreakCaseReportUID BIGINT;

INSERT INTO @CaseIdentifiers
SELECT idfHumanCase,
       idfOutbreak
FROM dbo.tlbHumanCase
WHERE idfOutbreak IS NOT NULL;

WHILE EXISTS (SELECT * FROM @CaseIdentifiers)
BEGIN
    SELECT TOP 1
        @Id = ID,
        @OutbreakID = OutbreakID
    FROM @CaseIdentifiers;

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

    DELETE FROM @CaseIdentifiers
    WHERE ID = @ID;
END

INSERT INTO @CaseIdentifiers
SELECT idfVetCase,
       idfOutbreak
FROM dbo.tlbVetCase
WHERE idfOutbreak IS NOT NULL;

WHILE EXISTS (SELECT * FROM @CaseIdentifiers)
BEGIN
    SELECT TOP 1
        @Id = ID,
        @OutbreakID = OutbreakID
    FROM @CaseIdentifiers;

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

    DELETE FROM @CaseIdentifiers
    WHERE ID = @ID;
END

UPDATE a
SET strCalculatedCaseID = CASE
                              WHEN a.idfMonitoringSession IS NOT NULL THEN
                                  dbo.tlbMonitoringSession.strMonitoringSessionID
                              WHEN a.idfVectorSurveillanceSession IS NOT NULL THEN
                                  dbo.tlbVectorSurveillanceSession.strSessionID
                              WHEN a.idfHumanCase IS NOT NULL THEN
                                  CASE
                                      WHEN dbo.tlbHumanCase.idfOutbreak IS NULL THEN
                                          dbo.tlbHumanCase.strCaseID
                                      ELSE
                                          humOCR.strOutbreakCaseID
                                  END
                              WHEN a.idfVetCase IS NOT NULL THEN
                                  CASE
                                      WHEN dbo.tlbVetCase.idfOutbreak IS NULL THEN
                                          dbo.tlbVetCase.strCaseID
                                      ELSE
                                          vetOCR.strOutbreakCaseID
                                  END
                          END
FROM dbo.tlbMaterial a
    LEFT JOIN dbo.tlbHumanCase
        ON tlbHumanCase.idfHumanCase = a.idfHumanCase
    LEFT JOIN dbo.OutbreakCaseReport humOCR
        ON humOCR.idfHumanCase = dbo.tlbHumanCase.idfHumanCase
    LEFT JOIN dbo.tlbVetCase
        ON tlbVetCase.idfVetCase = a.idfVetCase
    LEFT JOIN dbo.OutbreakCaseReport vetOCR
        ON vetOCR.idfVetCase = dbo.tlbVetCase.idfVetCase
    LEFT JOIN dbo.tlbMonitoringSession
        ON dbo.tlbMonitoringSession.idfMonitoringSession = a.idfMonitoringSession
    LEFT JOIN dbo.tlbVectorSurveillanceSession
        ON dbo.tlbVectorSurveillanceSession.idfVectorSurveillanceSession = a.idfVectorSurveillanceSession
WHERE (
              a.idfHumanCase IS NOT NULL
              OR a.idfVetCase IS NOT NULL
              OR a.idfMonitoringSession IS NOT NULL
              OR a.idfVectorSurveillanceSession IS NOT NULL
          )

GO
