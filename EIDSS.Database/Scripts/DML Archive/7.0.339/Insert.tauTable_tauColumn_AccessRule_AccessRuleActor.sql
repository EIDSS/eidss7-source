/*Author:        Stephen Long
Date:            03/14/2023
Description:     Creation of a new table entry for AccessRule and AccessRuleActor for SAUC30 and 31 in tauTable and tauColumn
*/
IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000010)
BEGIN
    INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)    
VALUES (53577790000010, 'AccessRule', NULL, 10519002, '[{"idfTable":53577790000010}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000011)
BEGIN
    INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)    
VALUES (53577790000011, 'AccessRuleActor', NULL, 10519002, '[{"idfTable":53577790000011}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000099)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000099, 53577790000010, 'GrantingActorSiteGroupID', 'GrantingActorSiteGroupID', 10519002, '[{"idfColumn":51586990000099}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000100)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000100, 53577790000010, 'GrantingActorSiteID', 'GrantingActorSiteID', 10519002, '[{"idfColumn":51586990000100}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000101)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000101, 53577790000010, 'intRowStatus', 'intRowStatus', 10519002, '[{"idfColumn":51586990000101}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000102)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000102, 53577790000010, 'ReadPermissionIndicator', 'ReadPermissionIndicator', 10519002, '[{"idfColumn":51586990000102}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000103)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000103, 53577790000010, 'AccessToPersonalDataPermissionIndicator', 'AccessToPersonalDataPermissionIndicator', 10519002, '[{"idfColumn":51586990000103}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000104)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000104, 53577790000010, 'AccessToGenderAndAgeDataPermissionIndicator', 'AccessToGenderAndAgeDataPermissionIndicator', 10519002, '[{"idfColumn":51586990000104}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000105)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000105, 53577790000010, 'WritePermissionIndicator', 'WritePermissionIndicator', 10519002, '[{"idfColumn":51586990000105}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000106)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000106, 53577790000010, 'DeletePermissionIndicator', 'DeletePermissionIndicator', 10519002, '[{"idfColumn":51586990000106}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000107)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000107, 53577790000010, 'BorderingAreaRuleIndicator', 'BorderingAreaRuleIndicator', 10519002, '[{"idfColumn":51586990000107}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000108)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000108, 53577790000010, 'ReciprocalRuleIndicator', 'ReciprocalRuleIndicator', 10519002, '[{"idfColumn":51586990000108}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000109)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000109, 53577790000010, 'DefaultRuleIndicator', 'DefaultRuleIndicator', 10519002, '[{"idfColumn":51586990000109}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000110)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000110, 53577790000010, 'AdministrativeLevelTypeID', 'AdministrativeLevelTypeID', 10519002, '[{"idfColumn":51586990000110}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000111)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000111, 53577790000010, 'CreatePermissionIndicator', 'CreatePermissionIndicator', 10519002, '[{"idfColumn":51586990000111}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000112)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000112, 53577790000011, 'ActorSiteGroupID', 'ActorSiteGroupID', 10519002, '[{"idfColumn":51586990000112}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000113)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000113, 53577790000011, 'ActorSiteID', 'ActorSiteID', 10519002, '[{"idfColumn":51586990000113}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000114)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000114, 53577790000011, 'ActorEmployeeGroupID', 'ActorEmployeeGroupID', 10519002, '[{"idfColumn":51586990000114}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000115)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000115, 53577790000011, 'ActorUserID', 'ActorUserID', 10519002, '[{"idfColumn":51586990000115}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000116)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000116, 53577790000011, 'intRowStatus', 'intRowStatus', 10519002, '[{"idfColumn":51586990000116}]', 'System', GETDATE(), NULL, NULL)
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000117)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000117, 53577790000011, 'GrantingActorIndicator', 'GrantingActorIndicator', 10519002, '[{"idfColumn":51586990000117}]', 'System', GETDATE(), NULL, NULL)
END
GO