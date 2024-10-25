/*
Author:			Stephen Long
Date:			11/16/2022
Description:	Insert missing Georgian translation records.

*/
DISABLE TRIGGER dbo.TR_trtResourceTranslation_I_Delete ON dbo.trtResourceTranslation; 
GO

DELETE FROM trtResourceTranslation WHERE idfsLanguage = 10049004 AND idfsResource IN (
27,
450,
593,
703,
780,
781,
1014,
2706,
2707,
2708,
2709,
2710,
2806,
2867,
2868,
2915,
3020,
3021,
3022,
3118,
3120,
3174,
3187,
3393,
3394,
3404,
3405,
3408,
3449,
3450,
3451,
3452,
3453,
3454,
3455,
3456,
3457,
3458,
3459,
3460,
3461,
3462,
3463,
3464,
3465,
3466,
3467,
3473,
3529,
3531,
3533,
3541,
3542,
3591,
3592,
3593,
3594,
3600,
3601,
3618,
3620,
3621,
3623,
3652,
3653,
3654,
3655,
3656,
3669,
3695,
3696,
3739,
3915,
3916,
3917,
3922,
3923,
4232,
4236,
4238,
4239,
4240,
4241,
4244,
4245,
4246,
4247,
4413,
4466,
4491
)
GO

ENABLE TRIGGER dbo.TR_trtResourceTranslation_I_Delete ON dbo.trtResourceTranslation
GO

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 450 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(450,10049004,N'თქვენ შეარჩიეთ მეტისმეტად ბევრი პუნქტი. ანგარიშში გამოჩნდება მხოლოდ პირველი 5.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":450,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 593 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(593,10049004,N'თქვენ ვერ წაშლით ორგანიზაციას რადგან ის დაკავშირებულია დზეის საიტთან.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":593,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 703 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(703,10049004,N'თქვენი ცვლილებები შენახულია წარმატებით.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":703,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 780 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(780,10049004,N'კვირა 5', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":780,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 781 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(781,10049004,N'კვირა 6', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":781,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1014 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1014,10049004,N'ზოონოზური დაავადების შედარებითი ანგარიში (თვეების მიხედვით)', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1014,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2806 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2806,10049004,N'სახეობის ტიპის ფილტრში არ შეგიძლიათ აღნიშნოთ სამ სახეობაზე მეტი.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2806,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2867 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2867,10049004,N'ფილტრი ტესტის დასახელების მიხედვით', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2867,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2868 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2868,10049004,N'ჩანაწერის  ID არის {0}.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2868,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3118 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3118,10049004,N'ეპიდემიოლოგიური კავშირები', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3118,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3344 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3344,10049004,N'ეპიდემიოლოგიური კავშირები', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3344,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3541 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3541,10049004,N'გსურთ მონაცემთა იმპორტირება?', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3541,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3542 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3542,10049004,N'შემდგომ რიგებთან დაკავშირებით დაშვეულია შეცდომა და მათი იმპორტირება შესაძლებელი არ არის.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3542,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3620 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3620,10049004,N'არქივთან დაკავსირება ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3620,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3621 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3621,10049004,N'გამოსვლა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3621,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3916 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3916,10049004,N'წინასწარ დაყენებული რეგიონი ძებნის პანელში', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3916,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3917 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3917,10049004,N'წინასწარ დაყენებული რაიონი ძებნის პანელში', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3917,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 486 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(486,10049004,N'აღწერა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":486,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 610 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(610,10049004,N'აღწერა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":610,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3629 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3629,10049004,N'აღწერა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3629,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4236 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4236,10049004,N'აღწერა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4236,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4136 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4136,10049004,N'დაავადებისა და სახეობის ჩამონათვალი აქტიური ზედამხედველობის სესიაში უნდა იყოს იგივე, რაც არჩეული აქტიური ზედამხედველობის კამპანიის ჩამონათვალში, ან შედიოდეს მის ქვეჯგუფში.', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4136,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4594 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4594,10049004,N'HASC კოდი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4594,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 708 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(708,10049004,N'პაროლის მინიმალური სიგრძე:', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":708,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 709 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(709,10049004,N'გააძლიერეთ პაროლის ისტორია', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":709,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 719 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(719,10049004,N'ანგარიშის ლოკაუტის ზღურბლი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":719,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 720 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(720,10049004,N'სესიის უმოქმედობის პერიოდი (წუთები)', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":720,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 928 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(928,10049004,N'რესურსების რედაქტორი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":928,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2804 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2804,10049004,N'შეცდომა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2804,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 663 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(663,10049004,N'ლაბორატორია', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":663,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2871 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2871,10049004,N'ლაბორატორია', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2871,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3186 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3186,10049004,N'ფერმაზე დაბრუნება', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3186,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2424 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2424,10049004,N'მეფრინველეობის ფერმის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2424,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3204 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3204,10049004,N'მეფრინველეობის ფერმის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3204,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2445 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2445,10049004,N'გამოკვლევის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2445,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3214 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3214,10049004,N'გამოკვლევის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3214,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3770 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3770,10049004,N'გამოკვლევის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3770,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3941 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3941,10049004,N'გამოკვლევის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3941,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3259 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3259,10049004,N'შინაური ცხოველის დამატება', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3259,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3260 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3260,10049004,N'ფრინველის დამატება', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3260,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3588 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3588,10049004,N'სტატისტიკური მონაცემების ჩამონათვალი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3588,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 992 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(992,10049004,N'აფეთქების შემთხვევის ID', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":992,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3661 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3661,10049004,N'აფეთქების შემთხვევის ID', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3661,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4507 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4507,10049004,N'აფეთქების შემთხვევის ID', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4507,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1087 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1087,10049004,N'შეტყობინების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1087,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1637 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1637,10049004,N'შეტყობინების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1637,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3663 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3663,10049004,N'შეტყობინების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3663,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4519 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4519,10049004,N'შეტყობინების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4519,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 389 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(389,10049004,N'შემთხვევის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":389,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1761 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1761,10049004,N'შემთხვევის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1761,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2824 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2824,10049004,N'შემთხვევის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2824,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3664 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3664,10049004,N'შემთხვევის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3664,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 996 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(996,10049004,N'სიმპტომების დაწყების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":996,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3666 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3666,10049004,N'სიმპტომების დაწყების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3666,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4539 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4539,10049004,N'სიმპტომების დაწყების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4539,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3447 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3447,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3447,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3525 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3525,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3525,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3667 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3667,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3667,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3749 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3749,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3749,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3762 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3762,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3762,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3933 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3933,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3933,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4188 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4188,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4188,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4201 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4201,10049004,N'შემთხვევის კლასიფიკაცია ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4201,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3205 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3205,10049004,N'შემთხვევის ადგილმდებარეობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3205,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3668 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3668,10049004,N'შემთხვევის ადგილმდებარეობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3668,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4590 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4590,10049004,N'შემთხვევის ადგილმდებარეობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4590,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4591 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4591,10049004,N'შემთხვევის ადგილმდებარეობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4591,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3536 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3536,10049004,N'კონტაქტის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3536,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3678 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3678,10049004,N'კონტაქტის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3678,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3690 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3690,10049004,N'კონტაქტის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3690,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4558 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4558,10049004,N'კონტაქტის ტიპი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4558,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2684 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2684,10049004,N'ბოლო დაკვირვების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2684,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3681 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3681,10049004,N'ბოლო დაკვირვების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3681,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3693 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3693,10049004,N'ბოლო დაკვირვების თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3693,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2685 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2685,10049004,N'ამჟამინდელი ადგილმდებარეობა ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2685,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3603 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3603,10049004,N'ამჟამინდელი ადგილმდებარეობა ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3603,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3682 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3682,10049004,N'ამჟამინდელი ადგილმდებარეობა ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3682,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3694 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3694,10049004,N'ამჟამინდელი ადგილმდებარეობა ', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3694,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1829 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1829,10049004,N'ოთახი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1829,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1831 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1831,10049004,N'ოთახი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1831,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3704 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3704,10049004,N'ოთახი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3704,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3718 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3718,10049004,N'ოთახი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3718,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3732 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3732,10049004,N'ოთახი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3732,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1837 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1837,10049004,N'ყუთის ზომა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1837,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3710 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3710,10049004,N'ყუთის ზომა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3710,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3724 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3724,10049004,N'ყუთის ზომა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3724,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 3738 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(3738,10049004,N'ყუთის ზომა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":3738,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 2906 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(2906,10049004,N'სესიის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":2906,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4145 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4145,10049004,N'სესიის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4145,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 4294 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(4294,10049004,N'სესიის თარიღი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":4294,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1732 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1732,10049004,N'დაავადებათა ანგარიშების რაოდენობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1732,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1754 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1754,10049004,N'დაავადებათა ანგარიშების რაოდენობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1754,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 1778 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(1778,10049004,N'დაავადებათა ანგარიშების რაოდენობა', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":1778,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

IF NOT EXISTS (SELECT 1 FROM trtResourceTranslation WHERE idfsResource = 164 and idfsLanguage = 10049004)
BEGIN
    INSERT INTO dbo.trtResourceTranslation (idfsResource,idfsLanguage,strResourceString,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
    VALUES(164,10049004,N'ფორმაცვალებადი ფილტრი', 0, NEWID(), N'ADD', N'Resource Translation',10519001, N'[{"idfsResource":164,"idfsLanguage":10049004}]', N'System', GETDATE(), N'System', GETDATE())
END

GO