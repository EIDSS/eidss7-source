/*
	Mike Kornegay (developed by Mark Wilson)
	01/31/2023
	Copies legacy contact information from the tlbHumanCase table
	to the HumanAddlinfo table so contact info is presented in
	the HDR.
*/

INSERT INTO dbo.HumanAddlInfo
(    
	HumanAdditionalInfo,    
	IsEmployedID,    
	EmployerPhoneNbr,    
	ContactPhoneNbr,    
	intRowStatus,    
	AuditCreateUser,    
	AuditCreateDTM,    
	rowguid,    
	SourceSystemNameID,    
	SourceSystemKeyValue
)
SELECT    
	idfHuman,    
	NULL,    
	strWorkPhone,    
	strHomePhone,    
	intRowStatus,    
	'System',    
	datModificationForArchiveDate,    
	NEWID(),    
	10519002,    
	'[{"HumanAdditionalInfo":' + CAST(idfHuman AS NVARCHAR(24)) + '}]'
FROM 
	dbo.tlbHuman
WHERE 
	SourceSystemNameID = 10519002