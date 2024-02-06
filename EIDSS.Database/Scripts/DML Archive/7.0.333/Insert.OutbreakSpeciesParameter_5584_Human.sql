/*
Author:			Stephen Long
Date:			02/10/2023
Description:	Add outbreak species parameter records for migrated records; bug 5584.
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