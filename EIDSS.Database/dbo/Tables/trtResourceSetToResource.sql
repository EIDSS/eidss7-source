CREATE TABLE [dbo].[trtResourceSetToResource] (
    [idfsResourceSet]      BIGINT           NOT NULL,
    [idfsResource]         BIGINT           NOT NULL,
    [isHidden]             BIT              CONSTRAINT [DF_trtResourceSetToResource_isHidden] DEFAULT ('FALSE') NULL,
    [isRequired]           BIT              CONSTRAINT [DF_trtResourceSetToResource_isRequired] DEFAULT ('FALSE') NULL,
    [intRowStatus]         INT              CONSTRAINT [DF_trtResourceSetToResource_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [[trtResourceSetToResource_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_trtResourceSetToResource_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [canEdit]              BIT              CONSTRAINT [DF_trtResourceSetToResource_canEdit] DEFAULT ('TRUE') NOT NULL,
    [idfsReportTextID]     BIGINT           CONSTRAINT [DF__trtResour__idfsR__1118B69C] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_trtResourceSetToResource] PRIMARY KEY CLUSTERED ([idfsResourceSet] ASC, [idfsResource] ASC),
    CONSTRAINT [FK_trtResourceSetToResource_idfsResourceSet] FOREIGN KEY ([idfsResourceSet]) REFERENCES [dbo].[trtResourceSet] ([idfsResourceSet]) NOT FOR REPLICATION,
    CONSTRAINT [FK_trtResourceSetToResource_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_trtResourceSetToResource_trtResource] FOREIGN KEY ([idfsResource]) REFERENCES [dbo].[trtResource] ([idfsResource]) NOT FOR REPLICATION
);


GO





CREATE TRIGGER [dbo].[TR_trtResourceSetToResource_I_Delete] ON [dbo].[trtResourceSetToResource]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfsResourceSet], [idfsResource]) AS
		(
			SELECT [idfsResourceSet], [idfsResource] FROM deleted
			EXCEPT
			SELECT [idfsResourceSet], [idfsResource] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.trtResourceSetToResource AS a 
		INNER JOIN cteOnlyDeletedRows AS b ON a.idfsResourceSet = b.idfsResourceSet	AND a.idfsResource = b.idfsResource;

	END

END

GO



CREATE TRIGGER [dbo].[TR_trtResourceSetToResource_A_Update] ON [dbo].[trtResourceSetToResource]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfsResourceSet) AND UPDATE(idfsResource)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resource Set identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceSetToResource', @level2type = N'COLUMN', @level2name = N'idfsResourceSet';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Resource identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'trtResourceSetToResource', @level2type = N'COLUMN', @level2name = N'idfsResource';

