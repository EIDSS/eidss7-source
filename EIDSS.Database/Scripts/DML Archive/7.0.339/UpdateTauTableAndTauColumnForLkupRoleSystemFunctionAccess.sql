/*Author:        Ann Xiong
Date:            03/13/2023
Description:     Creation of a new table entry for LkupRoleSystemFunctionAccess for SAUC30 and 31 in TauTable and TauColumn
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000006)
BEGIN
    INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)    
VALUES (53577790000006, 'LkupRoleSystemFunctionAccess', NULL, 10519002, '[{"idfTable":53577790000006}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000066)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000066, 53577790000006, 'idfEmployee', 'idfEmployee', 10519002, '[{"idfColumn":51586990000066}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000067)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000067, 53577790000006, 'SystemFunctionID', 'SystemFunctionID', 10519002, '[{"idfColumn":51586990000067}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000068)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000068, 53577790000006, 'SystemFunctionOperationID', 'SystemFunctionOperationID', 10519002, '[{"idfColumn":51586990000068}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000069)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000069, 53577790000006, 'AccessPermissionID', 'AccessPermissionID', 10519002, '[{"idfColumn":51586990000069}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000070)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000070, 53577790000006, 'intRowStatus', 'intRowStatus', 10519002, '[{"idfColumn":51586990000070}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000071)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000071, 53577790000006, 'intRowStatusForSystemFunction', 'intRowStatusForSystemFunction', 10519002, '[{"idfColumn":51586990000071}]', 'System', GETDATE(), NULL, NULL)
END
GO
