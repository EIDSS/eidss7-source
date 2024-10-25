/*Author:        Stephen Long
Date:            03/18/2023
Description:     Create tooltip resource for assign test modal.
*/
INSERT INTO dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
VALUES (4756,N'Click to approve the selected records.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4756}]','System', GETDATE(), 'System', GETDATE(), 10540001)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES (23,4756,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":23,"idfsResource":4756}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4756,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4756,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4756,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4756,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4756,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4756,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
VALUES (4757,N'Click to update.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4757}]','System', GETDATE(), 'System', GETDATE(), 10540001)

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
VALUES (4758,N'Click to edit the record.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4758}]','System', GETDATE(), 'System', GETDATE(), 10540001)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES (126,4757,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4757}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES (126,4758,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4758}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4757,10049011,N'انقر للتحديث.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4757,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4757,10049001,N'Yeniləmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4757,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4757,10049004,N'დააწკაპუნეთ განახლებისათვის ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4757,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4758,10049011,N'انقر لتحرير\لتعديل السجل.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4758,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4758,10049001,N'Yazını redaktə etmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4758,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4758,10049004,N'დააწკაპუნეთ ჩანაწერის რედაქტირებისათვის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4758,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4759,N'Click to display the aliquot popup.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4759}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4760,N'Click to display the transfer popup.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4760}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4761,N'Click to display the accession in popup.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4761}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4762,N'Click to display the assign test popup.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4762}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (5,4759,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":5,"idfsResource":4759}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (5,4760,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":5,"idfsResource":4760}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (5,4761,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":5,"idfsResource":4761}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (5,4762,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":5,"idfsResource":4762}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4759,10049011,N'انقر لعرض النافذة المنبثقة للقسامات', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4759,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4759,10049001,N'Alikvot popup pəncərəsinin açılması üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4759,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4759,10049004,N'დააწკაპუნეთ ალიკვოტის გამოსახვისათვის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4759,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4760,10049011,N'انقر لعرض نافذة التحويل إلى الخارج المنبثقة.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4760,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4760,10049001,N'Ötürülmə popup pəncərəsinin açılması üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4760,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4760,10049004,N'დააწკაპუნეთ ტრანსფერის გამოსახვისათვის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4760,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4761,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4761,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4761,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4761,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4761,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4761,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4762,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4762,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4762,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4762,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4762,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4762,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

     INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4763,N'Click to display the batch popup.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4763}]','System', GETDATE(), 'System', GETDATE(), 10540001)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (5,4763,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":5,"idfsResource":4763}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4763,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4763,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4763,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4763,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4763,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4763,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
VALUES (4764,N'Click to close the batch.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4764}]','System', GETDATE(), 'System', GETDATE(), 10540001)

INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES (25,4764,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":25,"idfsResource":4764}]', N'System', GETDATE(), N'System', GETDATE())

INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4764,10049011,N'انقر لإغلاق الدفعة', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4764,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4764,10049001,N'Qrupşəkilli testi bağlamaq üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4764,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
VALUES(4764,10049004,N'დააწკაპუნეთ იმისათვის რომ დახუროთ პარტია.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4764,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4765,N'Click to show the record on the My Favorites tab.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4765}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (5,4765,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":5,"idfsResource":4765}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4765,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4765,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4765,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4765,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4765,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4765,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

     INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4766,N'Click to select.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4766}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4767,N'Click to select all records.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4767}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4768,N'Click to unselect all.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4768}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4769,N'Click to accept.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4769}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4770,N'Click to clear the form.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4770}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4771,N'Click to confirm no.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4771}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4772,N'Click to confirm yes.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4772}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4773,N'Click to copy.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4773}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4774,N'Click to paste.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4774}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4766,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4766}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4767,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4767}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4768,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4768}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4769,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4769}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4770,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4770}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4771,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4771}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4772,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4772}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4773,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4773}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (126,4774,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":126,"idfsResource":4774}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4766,10049011,N'انقر لتحديد', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4766,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4766,10049001,N'Seçmək üçün klikləyin', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4766,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4766,10049004,N'დააწკაპუნეთ შერჩევისათვის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4766,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4767,10049011,N'انقر لتحديد كافة السجلات', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4767,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4767,10049001,N'Bütün yazıları seçmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4767,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4767,10049004,N'დააწკაპუნეთ ყველა ჩანაწერის შესარჩევად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4767,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4768,10049011,N'انقر لإلغاء تحديد الكل', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4768,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4768,10049001,N'Bütün seçimləri ləğv etmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4768,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4768,10049004,N' დააწკაპუნეთ ყველა მონიშნულის გასაუქმებლად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4768,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4769,10049011,N'أنقر للموافقة \ للقبول', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4769,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4769,10049001,N'Qəbul etmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4769,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4769,10049004,N'დააწკაპუნეთ მისაღებად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4769,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4770,10049011,N'انقر لمسح النموذج', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4770,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4770,10049001,N'Formanı təmizləmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4770,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4770,10049004,N'დააწკაპუნეთ ფორმის გასუფთავებისათვის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4770,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4771,10049011,N'انقر لتأكيد "كلا"', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4771,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4771,10049001,N'"Xeyr" təsdiqləmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4771,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4771,10049004,N'დააწკაპუნეთ არას დასადასტურებლად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4771,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4772,10049011,N'انقر لتأكيد "نعم"', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4772,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4772,10049001,N'"Bəli" təsdiqləmək üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4772,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4772,10049004,N'დააწკაპუნეთ, რომ დაადასტუროთ დიახ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4772,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4773,10049011,N'انقر للنسخ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4773,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4773,10049001,N'Surətini çıxarmaq üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4773,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4773,10049004,N'დააწკაპუნეთ კოპირებისთვის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4773,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4774,10049011,N'أنقر للصق', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4774,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4774,10049001,N'Yapışdırmaq üçün klikləyin.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4774,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4774,10049004,N'პეისტისათვის დააწკაპუნეთ ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4774,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

     INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4775,N'Click to reject the selected records.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4775}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (23,4775,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":23,"idfsResource":4775}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4775,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4775,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4775,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4775,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4775,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4775,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

     INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4776,N'Click to remove the selected samples from the batch.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4776}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4777,N'Click to add a test result to the selected records.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4777}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (25,4776,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":25,"idfsResource":4776}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (25,4777,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":25,"idfsResource":4777}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4776,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4776,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4776,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4776,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4776,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4776,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4777,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4777,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4777,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4777,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4777,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4777,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

     INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4778,N'Click to cancel the selected transfers.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4778}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4779,N'Click to display the selected transfers report for printing.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4779}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (82,4778,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":82,"idfsResource":4778}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (82,4779,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":82,"idfsResource":4779}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4778,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4778,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4778,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4778,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4778,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4778,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4779,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4779,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4779,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4779,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4779,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4779,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())

     INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4787,N'Click to mark the alert as read.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4787}]','System', GETDATE(), 'System', GETDATE(), 10540001)
INSERT into dbo.trtResource (idfsResource,strResourceName,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4788,N'Click to delete all alerts.',0,NEWID(),N'Add',N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4788}]','System', GETDATE(), 'System', GETDATE(), 10540001)



INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (75,4787,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":75,"idfsResource":4787}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (75,4788,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":75,"idfsResource":4788}]', N'System', GETDATE(), N'System', GETDATE())



INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4787,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4787,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4787,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4787,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4787,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4787,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4788,10049011,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4788,"idfsLanguage":10049011}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4788,10049001,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4788,"idfsLanguage":10049001}]', N'System', GETDATE(), N'System', GETDATE())
INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
     VALUES(4788,10049004,NULL, 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4788,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())