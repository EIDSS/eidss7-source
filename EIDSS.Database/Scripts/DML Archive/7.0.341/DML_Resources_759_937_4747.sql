--Defect 3973 - Add Record
If Not Exists (Select * from dbo.trtResource Where idfsResource = 4747)
Begin
	Insert into dbo.trtResource values (4747, 'Add Record', 0, NEWID(), 'Add', 'EIDSS7 Resources', 10519001, '[{"idfsResource":4747}]', 'System', GETDATE(), 'System', GETDATE(), 10540004)
End 
If Not Exists (Select * from dbo.trtResourceSet Where idfsResourceSet = 446)
Begin
	Insert into dbo.trtResourceSet values (446,'Add Record Modal','Add Record Modal',0,NEWID(),'ADD','EIDSS7 Resource Sets',10519001,'[{"idfsResourceSet":446}]'
	,'System',GETDATE(),'System',GETDATE())
End 
If Not Exists (Select * from dbo.trtResourceSetToResource Where idfsResourceSet = 446 and idfsResource = 4747)
Begin
	Insert into dbo.trtResourceSetToResource values (446,4747,0,0,0,NEWID(),'Add','EIDSS7 Resources',10519001,'[{"idfsResourceSet":446,"idfsResource":4747}]'
	,'System',GETDATE(),'System',GETDATE(),1,0)
End 
--Georgian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 4747 and idfsLanguage = 10049004)
Begin
	Insert into dbo.trtResourceTranslation values (4747,10049004,N'ჩანაწერის დამატება',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4747,"idfsLanguage":10049004}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'ჩანაწერის დამატება' where idfsResource = 4747 and idfsLanguage = 10049004
End
--Russian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 4747 and idfsLanguage = 10049006)
Begin
	Insert into dbo.trtResourceTranslation values (4747,10049006,N'Добавить запись',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":4747,"idfsLanguage":10049006}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'Добавить запись' where idfsResource = 4747 and idfsLanguage = 10049006
End 

--Defect 4307 - Day
--Georgian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 937 and idfsLanguage = 10049004)
Begin
	Insert into dbo.trtResourceTranslation values (937,10049004,N'დღე',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":937,"idfsLanguage":10049004}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'დღე' where idfsResource = 937 and idfsLanguage = 10049004
End
--Russian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 937 and idfsLanguage = 10049006)
Begin
	Insert into dbo.trtResourceTranslation values (937,10049006,N'День',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":937,"idfsLanguage":10049006}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'День' where idfsResource = 937 and idfsLanguage = 10049006
End

--Defect 4312 - Disease Matrix
--Georgian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 759 and idfsLanguage = 10049004)
Begin
	Insert into dbo.trtResourceTranslation values (759,10049004,N'დაავადების მატრიცა',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":759,"idfsLanguage":10049004}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'დაავადების მატრიცა' where idfsLanguage = 10049004 and idfsResource = 759 
End
--Russian
If Not Exists (Select * from dbo.trtResourceTranslation Where idfsResource = 759 and idfsLanguage = 10049006)
Begin
	Insert into dbo.trtResourceTranslation values (759,10049006,N'Матрица болезни',0,NEWID(),'ADD','EIDSS7 Resource Translations',10519001,'[{"idfsResource":759,"idfsLanguage":10049006}]'
	,'System',GETDATE(),NULL,NULL)
End
Else
Begin
	Update dbo.trtResourceTranslation set strResourceString = N'Матрица болезни' where idfsLanguage = 10049006 and idfsResource = 759 
End

