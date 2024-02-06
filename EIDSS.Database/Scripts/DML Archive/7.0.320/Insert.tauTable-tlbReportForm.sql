IF NOT EXISTS (SELECT 1 FROM dbo.tauTable WHERE idfTable = 53577790000001)
BEGIN
	INSERT INTO dbo.tauTable (idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (53577790000001, 'tlbReportForm', NULL, 10519002, '[{"idfTable":53577790000001}]', 'System', GETDATE(), NULL, NULL)
END
GO


