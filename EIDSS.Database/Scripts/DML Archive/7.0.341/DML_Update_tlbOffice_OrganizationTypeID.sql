
UPDATE O
SET O.OrganizationTypeID = 10504001,
	O.AuditUpdateDTM = GETDATE(),
	O.AuditUpdateUser = 'System'

FROM dbo.tlbOffice O
INNER JOIN dbo.tlbMaterial M ON M.idfSendToOffice = O.idfOffice

