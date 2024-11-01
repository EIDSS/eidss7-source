﻿CREATE TABLE [dbo].[tstUserTable] (
    [idfUserID]            BIGINT           NOT NULL,
    [idfPerson]            BIGINT           NULL,
    [idfsSite]             BIGINT           CONSTRAINT [DF_tstUserTable_idfsSite] DEFAULT ([dbo].[FN_GBL_SITEID_GET]()) NOT NULL,
    [datTryDate]           DATETIME         NULL,
    [datPasswordSet]       DATETIME         NULL,
    [strAccountName]       NVARCHAR (200)   NULL,
    [binPassword]          VARBINARY (50)   NULL,
    [intTry]               INT              NULL,
    [intRowStatus]         INT              CONSTRAINT [DF_tstUserTable_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tstUserTable_rowguid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [blnDisabled]          BIT              CONSTRAINT [DF_tstUserTable_blnDisabled] DEFAULT ((0)) NOT NULL,
    [PreferredLanguageID]  BIGINT           CONSTRAINT [DF_tstUserTablePreferredLanguage] DEFAULT ([dbo].[FN_GBL_LanguageCode_GET]('en-US')) NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [EmailAddress]         NVARCHAR (256)   NULL,
    [EmailConfirmedFlag]   BIT              NULL,
    [PasswordHash]         NVARCHAR (MAX)   NULL,
    [TwoFactorEnabledFlag] BIT              NULL,
    [LockoutEnabledFlag]   BIT              NULL,
    [LockoutEndDTM]        DATETIME         NULL,
    [AuditCreateUser]      VARCHAR (50)     CONSTRAINT [DF_tstusertable_AuditCreateUser] DEFAULT ('AppUser') NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tstusertable_AuditCreateDTM] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (50)     NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtstUserTable] PRIMARY KEY CLUSTERED ([idfUserID] ASC),
    CONSTRAINT [FK_tstUserTable_tlbPerson_idfPerson] FOREIGN KEY ([idfPerson]) REFERENCES [dbo].[tlbPerson] ([idfPerson]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstUserTable_trtBaseReference_idfsBaseReference] FOREIGN KEY ([PreferredLanguageID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tstUserTable_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tstUserTable_tstSite_idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO
CREATE NONCLUSTERED INDEX [IX_tstUserTable_idfPersonId]
    ON [dbo].[tstUserTable]([idfPerson] ASC);


GO



CREATE TRIGGER [dbo].[TR_tstUserTable_I_Delete] on [dbo].[tstUserTable]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfUserID]) as
		(
			SELECT [idfUserID] FROM deleted
			EXCEPT
			SELECT [idfUserID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.tstUserTable as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfUserID = b.idfUserID;

	END

END

GO

CREATE TRIGGER [dbo].[TR_tstUserTable_A_Update] ON [dbo].[tstUserTable]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF dbo.FN_GBL_TriggersWork ()=1 
	BEGIN
		IF UPDATE(idfUserID)
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN
			UPDATE dbo.tstUserTable
			SET AuditUpdateDTM = GETDATE()
			FROM dbo.tstUserTable UT
			INNER JOIN Inserted i ON UT.idfUserID = i.idfUserID
		END

	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Users', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstUserTable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstUserTable', @level2type = N'COLUMN', @level2name = N'idfUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Person identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstUserTable', @level2type = N'COLUMN', @level2name = N'idfPerson';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Site identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstUserTable', @level2type = N'COLUMN', @level2name = N'idfsSite';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tstUserTable', @level2type = N'COLUMN', @level2name = N'binPassword';

