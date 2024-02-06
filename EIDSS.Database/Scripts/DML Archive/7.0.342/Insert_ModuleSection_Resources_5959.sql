/*
Mike Kornegay
03/29/2023
Defect #5959 - Translations missing for 'Section' and 'Module' field labels in interface editor.

*/

--Defect 5959 - "Module"
If Not Exists (Select * from dbo.trtResource Where idfsResource = 4797 and idfsResourceType = 10540003)
Begin
	Insert into dbo.trtResource values (4797, 'Module', 0, NEWID(), 'Add', 'EIDSS7 Resources', 10519001, '[{"idfsResource":4797}]', 'System', GETDATE(), 'System', GETDATE(), 10540003)
End 
If Not Exists (Select * from dbo.trtResourceSetToResource Where idfsResourceSet = 51 and idfsResource = 4797)
Begin
	Insert into dbo.trtResourceSetToResource values (51,4797,0,0,0,NEWID(),'Add','EIDSS7 Resources',10519001,'[{"idfsResourceSet":51,"idfsResource":4797}]'
	,'System',GETDATE(),'System',GETDATE(),1,0)
End 
--Georgian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 4797 and idfsLanguage = 10049004)
Begin
	Insert into dbo.trtResourceTranslation values (4797,10049004,N'მოდული',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4797,"idfsLanguage":10049004}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'მოდული' where idfsResource = 4797 and idfsLanguage = 10049004
End


--Defect 5959 - "Section"
If Not Exists (Select * from dbo.trtResource Where idfsResource = 245 and idfsResourceType = 10540003)
Begin
	Insert into dbo.trtResource values (245, 'Section', 0, NEWID(), 'Add', 'EIDSS7 Resources', 1051901, '[{"idfsResource":245}]', 'System', GETDATE(), 'System', GETDATE(), 10540003)
End 
If Not Exists (Select * from dbo.trtResourceSetToResource Where idfsResourceSet = 51 and idfsResource = 245)
Begin
	Insert into dbo.trtResourceSetToResource values (51,245,0,0,0,NEWID(),'Add','EIDSS7 Resources',10519001,'[{"idfsResourceSet":51,"idfsResource":245}]'
	,'System',GETDATE(),'System',GETDATE(),1,0)
End 
--Georgian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 245 and idfsLanguage = 10049004)
Begin
	Insert into dbo.trtResourceTranslation values (4747,10049004,N'სექცია',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4747,"idfsLanguage":10049004}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'სექცია' where idfsResource = 245 and idfsLanguage = 10049004
End
