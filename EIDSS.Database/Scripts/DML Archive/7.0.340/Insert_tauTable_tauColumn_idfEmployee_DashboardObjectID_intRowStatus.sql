/*Author:        Ann Xiong
Date:            03/16/2023
Description:     Creation of a new table entry for LkupRoleDashboardObject and its columns for SAUC30 and 31 in TauTable and TauColumn
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000012)
BEGIN
    INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)    
VALUES (53577790000012, 'LkupRoleDashboardObject', NULL, 10519002, '[{"idfTable":53577790000012}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000119)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000119, 53577790000012, 'idfEmployee', 'idfEmployee', 10519002, '[{"idfColumn":51586990000119}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000120)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000120, 53577790000012, 'DashboardObjectID', 'DashboardObjectID', 10519002, '[{"idfColumn":51586990000120}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000121)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000121, 53577790000012, 'intRowStatus', 'intRowStatus', 10519002, '[{"idfColumn":51586990000121}]', 'System', GETDATE(), NULL, NULL)
END
GO