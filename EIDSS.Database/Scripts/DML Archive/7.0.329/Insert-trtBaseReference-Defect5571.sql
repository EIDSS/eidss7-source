/*
    Author:      Mark Wilson (added by Mike Kornegay)
    Description: Fix for defect 5571
*/
IF NOT EXISTS (SELECT * FROM dbo.trtBaseReference WHERE idfsBaseReference = 19000502)
BEGIN



   INSERT INTO dbo.trtBaseReference
    (
        idfsBaseReference,
        idfsReferenceType,
        strBaseReferenceCode,
        strDefault,
        intOrder,
        blnSystem,
        intRowStatus,
        rowguid,
        SourceSystemNameID,
        SourceSystemKeyValue,
        AuditCreateUser,
        AuditCreateDTM
    )
    VALUES
    (   
        19000502,
        19000076,
        N'rftRptSessType',
        N'Report/Session Type List',
        0,
        1,
        0,
        NEWID(),
        10519001,
        N'[{"idfsBaseReference":19000502}]',
        N'System',
        GETDATE()



   )



END