/*Author:        Ann Xiong
Date:            03/16/2023
Description:     Creation of Column intRowStatus for tlbEmployeeGroupMember for SAUC30 and 31 in TauColumn
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000122)
BEGIN
    INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
    VALUES (51586990000122, 75540000000, 'intRowStatus', 'intRowStatus', 10519002, '[{"idfColumn":51586990000122}]', 'System', GETDATE(), NULL, NULL)
END
GO