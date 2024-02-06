/*Author:        Stephen Long
Date:            04/12/2023
Description:     Add translations for laboratory and site alert tooltips.
*/

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4756 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ შერჩეული ჩანაწერების დასამტკიცებლად.' WHERE idfsResource = 4756 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4756,10049004,N'დააწკაპუნეთ შერჩეული ჩანაწერების დასამტკიცებლად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4756,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4756 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы подтвердить выбранные записи' WHERE idfsResource = 4756 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4756,10049006,N'нажмите,чтобы подтвердить выбранные записи', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4756,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4761 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ ნიმუშის მიღება გამოისახოს პოპ აპ ფანჯარაში.' WHERE idfsResource = 4761 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4761,10049004,N'დააწკაპუნეთ იმისათვის, რომ ნიმუშის მიღება გამოისახოს პოპ აპ ფანჯარაში.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4761,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4761 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы отобразить образцы в поп ап окне' WHERE idfsResource = 4761 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4761,10049006,N'нажмите,чтобы отобразить образцы в поп ап окне', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4761,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4762 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს დანიშნულის ტესტის პოპ აპ ფანჯარა.' WHERE idfsResource = 4762 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4762,10049004,N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს დანიშნულის ტესტის პოპ აპ ფანჯარა.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4762,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4762 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы отобразить назначенное тестовое окно' WHERE idfsResource = 4762 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4762,10049006,N'нажмите,чтобы отобразить назначенное тестовое окно', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4762,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4763 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს პარტიის პოპ აპ ფანჯარა.' WHERE idfsResource = 4763 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4763,10049004,N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს პარტიის პოპ აპ ფანჯარა.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4763,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4763 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы отобразить поп ап окно партии' WHERE idfsResource = 4763 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4763,10049006,N'нажмите,чтобы отобразить поп ап окно партии', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4763,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4765 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის. რომ ჩანაწერი გამოჩნდეს ჩემი ფავორიტების ჩანართში.' WHERE idfsResource = 4765 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4765,10049004,N'დააწკაპუნეთ იმისათვის. რომ ჩანაწერი გამოჩნდეს ჩემი ფავორიტების ჩანართში.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4765,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4765 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы отобразить запись в списке моих фаворитов во вкладке' WHERE idfsResource = 4765 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4765,10049006,N'нажмите,чтобы отобразить запись в списке моих фаворитов во вкладке', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4765,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4775 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ მოხდეს შერჩეული ჩანაწერების უკუგდება.' WHERE idfsResource = 4775 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4775,10049004,N'დააწკაპუნეთ იმისათვის, რომ მოხდეს შერჩეული ჩანაწერების უკუგდება.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4775,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4775 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы обеспечить отмену выбранной записи' WHERE idfsResource = 4775 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4775,10049006,N'нажмите,чтобы обеспечить отмену выбранной записи', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4775,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4776 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ პარტიიდან ამოშალოთ  შერჩეული ნიმუშები.' WHERE idfsResource = 4776 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4776,10049004,N'დააწკაპუნეთ იმისათვის, რომ პარტიიდან ამოშალოთ  შერჩეული ნიმუშები.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4776,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4776 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы удалить выбранные образцы из партии' WHERE idfsResource = 4776 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4776,10049006,N'нажмите,чтобы удалить выбранные образцы из партии', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4776,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4777 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ შერჩეულ ჩანაწერებს დაუმატოთ ტესტის შედეგი.' WHERE idfsResource = 4777 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4777,10049004,N'დააწკაპუნეთ იმისათვის, რომ შერჩეულ ჩანაწერებს დაუმატოთ ტესტის შედეგი.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4777,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4777 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы добавить в выбранные записи результаты теста' WHERE idfsResource = 4777 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4777,10049006,N'нажмите,чтобы добавить в выбранные записи результаты теста', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4777,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4778 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ გააუქმოთ შერჩეული ტრანსფერი.' WHERE idfsResource = 4778 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4778,10049004,N'დააწკაპუნეთ იმისათვის, რომ გააუქმოთ შერჩეული ტრანსფერი.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4778,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4778 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы отменить выбранный трансфер' WHERE idfsResource = 4778 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4778,10049006,N'нажмите,чтобы отменить выбранный трансфер', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4778,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4779 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს შერჩეული ტრანსფერის დასაბეჭდი ანგარიში.' WHERE idfsResource = 4779 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4779,10049004,N'დააწკაპუნეთ იმისათვის, რომ გამოისახოს შერჩეული ტრანსფერის დასაბეჭდი ანგარიში.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4779,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4779 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы отобразить отчет для печати соответствующего трансфера' WHERE idfsResource = 4779 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4779,10049006,N'нажмите,чтобы отобразить отчет для печати соответствующего трансфера', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4779,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4787 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ იმისათვის, რომ გართხილება მოინიშნოს წაკითხულად.' WHERE idfsResource = 4787 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4787,10049004,N'დააწკაპუნეთ იმისათვის, რომ გართხილება მოინიშნოს წაკითხულად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4787,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4787 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы прудупреждение отметить как прочитанное' WHERE idfsResource = 4787 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4787,10049006,N'нажмите,чтобы прудупреждение отметить как прочитанное', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4787,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4788 AND idfsLanguage = 10049004)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'დააწკაპუნეთ ყველა გაფრთხილების წასაშლელად.' WHERE idfsResource = 4788 AND idfsLanguage = 10049004
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4788,10049004,N'დააწკაპუნეთ ყველა გაფრთხილების წასაშლელად.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4788,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF EXISTS (SELECT * FROM dbo.trtResourceTranslation WHERE idfsResource = 4788 AND idfsLanguage = 10049006)
BEGIN
	UPDATE dbo.trtResourceTranslation SET strResourceString = N'нажмите,чтобы удалить все предупреждения' WHERE idfsResource = 4788 AND idfsLanguage = 10049006
END
ELSE
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4788,10049006,N'нажмите,чтобы удалить все предупреждения', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4788,"idfsLanguage":10049006}]', N'System', GETDATE(), N'System', GETDATE())
END