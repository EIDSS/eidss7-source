/*
Author:			Stephen Long
Date:			10/07/2022
Description:	Update record in trtBaseReference and trtEventType for laboratory test result rejected site alert.
Note:           -Be sure the record exists in table.  TODO - Need to check on trtStringNameTranslation.
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10056062)
BEGIN
    UPDATE trtBaseReference 
    SET idfsReferenceType = 19000025, AuditUpdateDTM = GETDATE() 
    WHERE idfsBaseReference = 10056062
END
GO

IF NOT EXISTS (SELECT 1 FROM trtBaseReference WHERE idfsBaseReference = 10155559)
BEGIN
    INSERT INTO trtBaseReference
    (
        idfsBaseReference, 
        idfsReferenceType, 
        strDefault, 
        blnSystem, 
        intRowStatus, 
        SourceSystemNameID, 
        SourceSystemKeyValue, 
        AuditCreateDTM, 
        AuditCreateUser, 
        AuditUpdateDTM, 
        AuditUpdateUser
    )
    VALUES
    (
        10155559,
        19000155, 
        'Laboratory test result rejected', 
        0, 
        0, 
        10519002,
        '[{"idfsBaseReference":10155559}]', 
        GETDATE(), 
        'system',
        GETDATE(), 
        'system'
    )
END
GO

IF NOT EXISTS (SELECT 1 FROM trtEventType WHERE idfsEventTypeID = 10056062)
BEGIN
    INSERT INTO trtEventType
    (
        idfsEventTypeID, 
        intRowStatus, 
        blnSubscription, 
        blnDisplayInLog, 
        idfsEventSubscription, 
        AuditCreateDTM, 
        AuditCreateUser, 
        AuditUpdateDTM, 
        AuditUpdateUser
    )
    VALUES 
    (
        10056062, 
        0, 
        1, 
        1, 
        10155559, 
        GETDATE(), 
        'System', 
        GETDATE(), 
        'System'
    )
END
GO