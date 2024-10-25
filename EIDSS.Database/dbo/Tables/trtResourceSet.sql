CREATE TABLE [dbo].[trtResourceSet] (
    [idfsResourceSet]      BIGINT           NOT NULL,
    [strResourceSet]       NVARCHAR (512)   NOT NULL,
    [strResourceSetUnique] NVARCHAR (512)   NULL,
    [intRowStatus]         INT              CONSTRAINT [DF__trtResour__intRo__23CB985D] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [trtResourceSet_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      VARCHAR (100)    CONSTRAINT [DF__trtResour__Audit__25B3E0CF] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF__trtResour__Audit__26A80508] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    CONSTRAINT [DF__trtResour__Audit__279C2941] DEFAULT (user_name()) NOT NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF__trtResour__Audit__28904D7A] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__trtResou__A2B290779DE0F25B] PRIMARY KEY CLUSTERED ([idfsResourceSet] ASC),
    CONSTRAINT [FK_trtResourceSet_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_trtResourceSet_I_Delete] ON [dbo].[trtResourceSet]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfsResourceSet]) AS
		(
			SELECT [idfsResourceSet] FROM deleted
			EXCEPT
			SELECT [idfsResourceSet] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.trtResourceSet AS a 
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfsResourceSet = b.idfsResourceSet;

	END

END

GO



CREATE TRIGGER [dbo].[TR_trtResourceSet_A_Update] ON [dbo].[trtResourceSet]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsResourceSet))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
