CREATE TABLE [dbo].[trtResourceSetTranslation] (
    [idfsResourceSet]      BIGINT           NOT NULL,
    [idfsLanguage]         BIGINT           NOT NULL,
    [strTextString]        NVARCHAR (2000)  NULL,
    [intRowStatus]         INT              CONSTRAINT [DF_trtResourceSetTranslation_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [[trtResourceSetTranslation_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_trtResourceSetTranslation_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtrtResourceSetTranslation] PRIMARY KEY CLUSTERED ([idfsResourceSet] ASC, [idfsLanguage] ASC),
    CONSTRAINT [FK_trtResourceSetTranslation__idfsLanguage] FOREIGN KEY ([idfsLanguage]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_trtResourceSetTranslation_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_trtResourceSetTranslation_trtResourceSet] FOREIGN KEY ([idfsResourceSet]) REFERENCES [dbo].[trtResourceSet] ([idfsResourceSet]) NOT FOR REPLICATION
);


GO


CREATE TRIGGER [dbo].[TR_trtResourceSetTranslation_A_Update] ON [dbo].[trtResourceSetTranslation]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsResourceSet) AND UPDATE(idfsLanguage)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO




CREATE TRIGGER [dbo].[TR_trtResourceSetTranslation_I_Delete] ON [dbo].[trtResourceSetTranslation]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfsResourceSet], [idfsLanguage]) AS
		(
			SELECT [idfsResourceSet], [idfsLanguage] FROM deleted
			EXCEPT
			SELECT [idfsResourceSet], [idfsLanguage] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.trtResourceSetTranslation AS a 
		INNER JOIN cteOnlyDeletedRows AS b 
			ON a.idfsResourceSet = b.idfsResourceSet
			AND a.idfsLanguage = b.idfsLanguage;

	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resource Set translated values', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceSetTranslation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resource Set identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceSetTranslation', @level2type = N'COLUMN', @level2name = N'idfsResourceSet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Language identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceSetTranslation', @level2type = N'COLUMN', @level2name = N'idfsLanguage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Translated value in specified language ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceSetTranslation', @level2type = N'COLUMN', @level2name = N'strTextString';

