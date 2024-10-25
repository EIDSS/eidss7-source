/*Author:        Ann Xiong
Date:            03/15/2023
Description:     Creation of two Columns for tstNextNumbers for SAUC30 and 31 in TauColumn
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000097)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000097, 76130000000, 'strSpecialChar', 'strSpecialChar', 10519002, '[{"idfColumn":51586990000097}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000098)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000098, 76130000000, 'intPreviousNumberValue', 'intPreviousNumberValue', 10519002, '[{"idfColumn":51586990000098}]', 'System', GETDATE(), NULL, NULL)
END
GO