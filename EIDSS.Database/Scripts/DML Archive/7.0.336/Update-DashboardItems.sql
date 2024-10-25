/*
	Mike Kornegay (from Mark Wilson)
	2/28/2023
	Update dashboard item wording.

*/


UPDATE dbo.trtBaseReference
SET strDefault = N'Veterinary Aggregate Actions',    AuditUpdateDTM = GETDATE(),    AuditUpdateUser = 'System'
WHERE idfsBaseReference = 10506120  
UPDATE dbo.trtBaseReference
SET strDefault = N'Human Aggregate Disease Report',    AuditUpdateDTM = GETDATE(),    AuditUpdateUser = 'System'
WHERE idfsBaseReference = 10506110 UPDATE dbo.trtBaseReference
SET strDefault = N'Avian Disease Report',    AuditUpdateDTM = GETDATE(),    AuditUpdateUser = 'System'
WHERE idfsBaseReference = 10506116 UPDATE dbo.trtBaseReference
SET strDefault = N'Livestock Disease Report',    AuditUpdateDTM = GETDATE(),    AuditUpdateUser = 'System'
WHERE idfsBaseReference = 10506117  UPDATE dbo.trtBaseReference 
SET strDefault = N'Veterinary Aggregate Disease Report',    AuditUpdateDTM = GETDATE(),    AuditUpdateUser = 'System'
WHERE idfsBaseReference = 10506119