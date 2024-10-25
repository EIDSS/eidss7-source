CREATE TABLE [dbo].[trtResourceSetHierarchy] (
    [idfResourceHierarchy] BIGINT              NOT NULL,
    [idfsResourceSet]      BIGINT              NOT NULL,
    [ResourceSetNode]      [sys].[hierarchyid] NOT NULL,
    [intOrder]             INT                 NULL,
    [intRowStatus]         INT                 CONSTRAINT [DF__trtResour__intRo__00CC74E3] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER    CONSTRAINT [trtResourceSetHierarchy_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)       NULL,
    [strReservedAttribute] NVARCHAR (MAX)      NULL,
    [SourceSystemNameID]   BIGINT              NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)      NULL,
    [AuditCreateUser]      VARCHAR (100)       CONSTRAINT [DF__trtResour__Audit__02B4BD55] DEFAULT (user_name()) NULL,
    [AuditCreateDTM]       DATETIME            CONSTRAINT [DF__trtResour__Audit__03A8E18E] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      VARCHAR (100)       CONSTRAINT [DF__trtResour__Audit__049D05C7] DEFAULT (user_name()) NULL,
    [AuditUpdateDTM]       DATETIME            CONSTRAINT [DF__trtResour__Audit__05912A00] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_trtResourceSetHierarchy] PRIMARY KEY CLUSTERED ([idfResourceHierarchy] ASC),
    CONSTRAINT [FK_trtResourceSetHierarchy_idfsResourceSet] FOREIGN KEY ([idfsResourceSet]) REFERENCES [dbo].[trtResourceSet] ([idfsResourceSet]),
    CONSTRAINT [FK_trtResourceSetHierarchy_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO


CREATE TRIGGER [dbo].[TR_trtResourceSetHierarchy_A_Update] ON [dbo].[trtResourceSetHierarchy]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfResourceHierarchy))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO

CREATE TRIGGER [dbo].[TR_trtResourceSetHierarchy_I_Delete] ON [dbo].[trtResourceSetHierarchy]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfResourceHierarchy]) AS
		(
			SELECT [idfResourceHierarchy] FROM deleted
			EXCEPT
			SELECT [idfResourceHierarchy] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.trtResourceSetHierarchy AS a 
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfResourceHierarchy = b.idfResourceHierarchy;

	END

END
