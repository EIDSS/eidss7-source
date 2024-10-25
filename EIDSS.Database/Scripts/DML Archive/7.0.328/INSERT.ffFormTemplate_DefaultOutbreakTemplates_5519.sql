/*
	This script MUST be applied to the base line db, so that migration will have these items when a new install is pushed.

	Additionally, run this script ONLY on Regression. DO NOT RUN on any other enviornment, as this might cause problems for the app.
*/

DECLARE @idfsFormTemplate BIGINT

EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034501, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034502, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034503, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034504, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034505, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034506, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034507, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034508, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'ffFormTemplate', @idfsKey = @idfsFormTemplate OUTPUT;
INSERT INTO ffFormTemplate (idfsFormTemplate, idfsFormType, blnUNI, strNote, intRowStatus, rowguid, AuditCreateUser, AuditCreateDTM) VALUES(@idfsFormTemplate, 10034509, 0, 'Default Template For Outbreak Use', 0, NEWID(), 'system', GETDATE())

