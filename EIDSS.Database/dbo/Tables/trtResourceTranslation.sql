CREATE TABLE [dbo].[trtResourceTranslation] (
    [idfsResource]         BIGINT           NOT NULL,
    [idfsLanguage]         BIGINT           NOT NULL,
    [strResourceString]    NVARCHAR (2000)  NULL,
    [intRowStatus]         INT              CONSTRAINT [DF_trtResourceTranslation_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [[trtResourceTranslation_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_trtResourceTranslation_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtrtResourceTranslation] PRIMARY KEY CLUSTERED ([idfsResource] ASC, [idfsLanguage] ASC),
    CONSTRAINT [FK_trtResourceTranslation_idfsLanguage] FOREIGN KEY ([idfsLanguage]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_trtResourceTranslation_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_trtResourceTranslation_trtResource] FOREIGN KEY ([idfsResource]) REFERENCES [dbo].[trtResource] ([idfsResource]) NOT FOR REPLICATION
);


GO


CREATE TRIGGER [dbo].[TR_trtResourceTranslation_I_Delete] ON [dbo].[trtResourceTranslation]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfsResource], [idfsLanguage]) AS
		(
			SELECT [idfsResource], [idfsLanguage] FROM deleted
			EXCEPT
			SELECT [idfsResource], [idfsLanguage] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.trtResourceTranslation AS a 
		INNER JOIN cteOnlyDeletedRows AS b 
			ON a.idfsResource = b.idfsResource
			AND a.idfsLanguage = b.idfsLanguage;

	END

END

GO


CREATE TRIGGER [dbo].[TR_trtResourceTranslation_A_Update] ON [dbo].[trtResourceTranslation]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsResource) AND UPDATE(idfsLanguage)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resource Set translated values', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceTranslation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resource Set identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceTranslation', @level2type = N'COLUMN', @level2name = N'idfsResource';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Language identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceTranslation', @level2type = N'COLUMN', @level2name = N'idfsLanguage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Translated value in specified language ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceTranslation', @level2type = N'COLUMN', @level2name = N'strResourceString';

