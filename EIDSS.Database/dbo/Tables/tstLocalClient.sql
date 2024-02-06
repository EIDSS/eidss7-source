CREATE TABLE [dbo].[tstLocalClient] (
    [strClient]            NVARCHAR (200)   NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tstLocalClient_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tstLocalClient_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtstLocalClient] PRIMARY KEY CLUSTERED ([strClient] ASC),
    CONSTRAINT [FK_tstLocalClient_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_tstLocalClient_A_Update] ON [dbo].[tstLocalClient]
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([strClient]))  -- update to Primary Key is not allowed.
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1);
		ROLLBACK TRANSACTION;
	END

END
