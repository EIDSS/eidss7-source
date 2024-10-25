CREATE TABLE [dbo].[tstEventSubscription] (
    [idfsEventTypeID]      BIGINT           NOT NULL,
    [strClient]            NVARCHAR (200)   NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tstEventSubscription_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tstEventSubscription_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [idfUserID] BIGINT NULL, 
    CONSTRAINT [XPKtstEventSubscription] PRIMARY KEY CLUSTERED ([idfsEventTypeID] ASC, [strClient] ASC),
    CONSTRAINT [FK_tstEventSubscription_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tstEventSubscription_trtEventType__idfsEventTypeID_R_676] FOREIGN KEY ([idfsEventTypeID]) REFERENCES [dbo].[trtEventType] ([idfsEventTypeID]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tstEventSubscription_A_Update] ON [dbo].[tstEventSubscription]
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1 AND (UPDATE([idfsEventTypeID]) OR UPDATE([strClient])))  -- update to Primary Key is not allowed.
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1);
		ROLLBACK TRANSACTION;
	END

END
