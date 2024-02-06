CREATE TABLE [dbo].[trtResource] (
    [idfsResource]         BIGINT           NOT NULL,
    [strResourceName]      NVARCHAR (512)   NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [DF_trtResource_intRow] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [trtResource__newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    CONSTRAINT [DF_trtResource_strMaintenanceFlag] DEFAULT ('Add') NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      VARCHAR (100)    CONSTRAINT [DF_trtResource_AuditCreateUser] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [[DF_trtResource_AuditCreateDTM] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    CONSTRAINT [DF_trtResource_AuditUpdateUser] DEFAULT (user_name()) NOT NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF_trtResourc_AuditUpdateDTM] DEFAULT (getdate()) NOT NULL,
    [idfsResourceType]     BIGINT           NULL,
    CONSTRAINT [PK_trtResource] PRIMARY KEY CLUSTERED ([idfsResource] ASC),
    CONSTRAINT [FK_trtResource_idfsResourceType] FOREIGN KEY ([idfsResourceType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_trtResource_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO



CREATE TRIGGER [dbo].[TR_trtResource_I_Delete] ON [dbo].[trtResource]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfsResource]) AS
		(
			SELECT [idfsResource] FROM deleted
			EXCEPT
			SELECT [idfsResource] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.trtResource AS a 
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfsResource = b.idfsResource;

	END

END

GO


CREATE TRIGGER [dbo].[TR_trtResource_A_Update] ON [dbo].[trtResource]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsResource))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
