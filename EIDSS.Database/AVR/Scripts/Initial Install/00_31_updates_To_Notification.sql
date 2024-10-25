---- Updates run on DBs 4/25/2023 for notification services ----
-- Need to add 10025132 and 10025133 for all users to table EventSubscription (Steven Long will do that for all users)

-- Fix to enable 'New AVR layout was unpublished at your site' and 'New AVR layout was unpublished at third-party site'
update trtBaseReference set intRowStatus = 0 where idfsBaseReference in (10025132,10025133,51523490000000,51523500000000)

-- Add missing event types records to [trtEventType] from Mark.
if exists(select * from [dbo].[trtEventType] where [idfsEventTypeID] = 10025132)
	update trtEventType set intRowStatus = 0 where  idfsEventTypeID = 10025132
else
	INSERT INTO [dbo].[trtEventType] ([idfsEventTypeID], [rowguid], [intRowStatus], [blnSubscription], [blnDisplayInLog], [idfsEventSubscription], [strMaintenanceFlag], [strReservedAttribute], [SourceSystemNameID], [SourceSystemKeyValue], [AuditCreateUser], [AuditCreateDTM], [AuditUpdateUser], [AuditUpdateDTM]) VALUES (10025132, 'a6b5df03-9475-4f3c-a266-0b76e47456c5', 0, 0, 0, 51523490000000, NULL, NULL, 10519001, N'[{"idfsEventTypeID":10025132}]', NULL, '2022-12-02 19:03:05.707', N'SYETEM', '2022-12-02 19:03:14.177')

if exists(select * from [dbo].[trtEventType] where [idfsEventTypeID] = 10025133)
	update trtEventType set intRowStatus = 0 where  idfsEventTypeID = 10025133
else
	INSERT INTO [dbo].[trtEventType] ([idfsEventTypeID], [rowguid], [intRowStatus], [blnSubscription], [blnDisplayInLog], [idfsEventSubscription], [strMaintenanceFlag], [strReservedAttribute], [SourceSystemNameID], [SourceSystemKeyValue], [AuditCreateUser], [AuditCreateDTM], [AuditUpdateUser], [AuditUpdateDTM]) VALUES (10025133, '4591077b-0833-4ab4-a8ba-20f45d7c2913', 0, 0, 0, 51523500000000, NULL, NULL, 10519001, N'[{"idfsEventTypeID":10025133}]', NULL, '2022-12-02 19:03:05.707', N'SYETEM', '2022-12-02 19:03:14.177')
