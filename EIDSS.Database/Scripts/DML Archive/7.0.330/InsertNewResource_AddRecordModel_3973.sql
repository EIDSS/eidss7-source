Insert into dbo.trtResource values (4747, 'Add Record', 0, NEWID(), 'Add', 'EIDSS7 Resources', 10519001, '[{"idfsResource":4747}]', 'System', GETDATE(), 'System', GETDATE(), 10540004)
Insert into dbo.trtResourceSetToResource values (446,4747,0,0,0,NEWID(),'Add','EIDSS7 Resources',10519001,'[{"idfsResourceSet":446,"idfsResource":4747}]'
	,'System',GETDATE(),'System',GETDATE(),1,0)
Insert into dbo.trtResourceTranslation values (4747,'10049001','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4747,"idfsLanguage":10049001}]'
	,'System',GETDATE(),NULL,NULL)
Insert into dbo.trtResourceTranslation values (4747,'10049004','[TBD]',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4747,"idfsLanguage":10049004}]'
	,'System',GETDATE(),NULL,NULL)