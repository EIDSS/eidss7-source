/*
	Author:	Mark Wilson (added to project by Mike Kornegay)
	Date:	1/9/2023
	Description: Update the outbreak status values and remove old values.  
*/

INSERT INTO dbo.trtBaseReference
(    idfsBaseReference,    idfsReferenceType,    strBaseReferenceCode,    strDefault,    intHACode,    intOrder,    intRowStatus,    rowguid,    strReservedAttribute,    SourceSystemNameID,    SourceSystemKeyValue,    AuditCreateUser,    AuditCreateDTM
)
VALUES
(    
	10063503,    19000063,    N'otsNotOutbreak',    N'Not an Outbreak',    226,    0,    0,    NEWID(),    N'V7 Reference Data',    10519001,    N'[{"idfsBaseReference":10063503}]',    N'System',    GETDATE()
)

ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_A_Update]

UPDATE dbo.tlbOutbreak
SET idfsOutbreakStatus = 10063503
WHERE idfsOutbreakStatus = 55459240000000

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_A_Update]

ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_I_Delete]

DELETE FROM dbo.trtBaseReference WHERE idfsBaseReference = 55459240000000

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_I_Delete]

INSERT INTO dbo.trtBaseReference
(    idfsBaseReference,    idfsReferenceType,    strBaseReferenceCode,    strDefault,    intHACode,    intOrder,    intRowStatus,    rowguid,    strReservedAttribute,    SourceSystemNameID,    SourceSystemKeyValue,    AuditCreateUser,    AuditCreateDTM
)
VALUES
(    
	10063503,    19000063,    N'otsNotOutbreak',    N'Not an Outbreak',    226,    0,    0,    NEWID(),    N'V7 Reference Data',    10519001,    N'[{"idfsBaseReference":10063503}]',    N'System',    GETDATE()
)

ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_A_Update]

UPDATE dbo.tlbOutbreak
SET idfsOutbreakStatus = 10063503
WHERE idfsOutbreakStatus = 55459240000000

UPDATE dbo.trtStringNameTranslation
SET idfsBaseReference = 10063503
WHERE idfsBaseReference = 55459240000000

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_A_Update]

ALTER TABLE [dbo].[trtBaseReference] DISABLE TRIGGER [TR_trtBaseReference_I_Delete]

DELETE FROM dbo.trtBaseReference WHERE idfsBaseReference = 55459240000000

ALTER TABLE [dbo].[trtBaseReference] ENABLE TRIGGER [TR_trtBaseReference_I_Delete]

