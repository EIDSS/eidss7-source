


UPDATE dbo.tlbOutbreak
SET idfsOutbreakStatus = 10063502,
	AuditUpdateDTM = GETDATE(),
	AuditUpdateUser = 'System'
WHERE SourceSystemNameID = 10519002


