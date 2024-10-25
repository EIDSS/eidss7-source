CREATE TABLE [dbo].[tstNotification] (
    [idfNotification]               BIGINT           NOT NULL,
    [idfsNotificationObjectType]    BIGINT           NULL,
    [idfsNotificationType]          BIGINT           NULL,
    [idfsTargetSiteType]            BIGINT           NULL,
    [idfUserID]                     BIGINT           NULL,
    [idfNotificationObject]         BIGINT           NULL,
    [idfTargetUserID]               BIGINT           NULL,
    [idfsTargetSite]                BIGINT           NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [Def_fnSiteID_tstNotification] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [datCreationDate]               DATETIME         NOT NULL,
    [datEnteringDate]               DATETIME         NULL,
    [strPayload]                    TEXT             NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [newid__2031] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [tstNotification_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [SourceSystemNameID]            BIGINT           NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tstNotification_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    CONSTRAINT [XPKtstNotification] PRIMARY KEY CLUSTERED ([idfNotification] ASC),
    CONSTRAINT [FK_tstNotification_trtBaseReference__idfsNotificationObjectType_R_1307] FOREIGN KEY ([idfsNotificationObjectType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstNotification_trtBaseReference__idfsNotificationType_R_1306] FOREIGN KEY ([idfsNotificationType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstNotification_trtBaseReference__idfsTargetSiteType_R_1304] FOREIGN KEY ([idfsTargetSiteType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstNotification_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tstNotification_tstSite__idfsSite_R_1035] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstNotification_tstSite__idfsTargetSite_R_688] FOREIGN KEY ([idfsTargetSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstNotification_tstUserTable__idfTargetUserID_R_720] FOREIGN KEY ([idfTargetUserID]) REFERENCES [dbo].[tstUserTable] ([idfUserID]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstNotification_tstUserTable__idfUserID_R_793] FOREIGN KEY ([idfUserID]) REFERENCES [dbo].[tstUserTable] ([idfUserID]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tstNotification_A_Update] ON [dbo].[tstNotification]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1)
	BEGIN
		IF UPDATE(idfNotification)
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN
			UPDATE a
			SET datModificationForArchiveDate = GETDATE()
			FROM dbo.tstNotification AS a 
			INNER JOIN inserted AS b ON a.idfNotification = b.idfNotification
	
		END
	
	END

END


GO


CREATE TRIGGER [dbo].[TR_tstNotification_I_Delete] on [dbo].[tstNotification]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfNotification]) as
		(
			SELECT [idfNotification] FROM deleted
			EXCEPT
			SELECT [idfNotification] FROM inserted
		)

		UPDATE a
		SET datEnteringDate = GETDATE(),
			datModificationForArchiveDate = GETDATE()
		FROM dbo.tstNotification as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfNotification = b.idfNotification;

	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notifications', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfNotification';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification object type identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfsNotificationObjectType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'User identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification object identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfNotificationObject';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification target user identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfTargetUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification target site identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfsTargetSite';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Site identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'idfsSite';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification creation date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'datCreationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Notification entering date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstNotification', @level2type = N'COLUMN', @level2name = N'datEnteringDate';

