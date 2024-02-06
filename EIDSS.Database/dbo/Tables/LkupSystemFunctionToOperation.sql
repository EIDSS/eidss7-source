CREATE TABLE [dbo].[LkupSystemFunctionToOperation] (
    [SystemFunctionID]          BIGINT           NOT NULL,
    [SystemFunctionOperationID] BIGINT           NOT NULL,
    [intRowStatus]              INT              CONSTRAINT [DF__LkupSyste__intRo__3910CE06] DEFAULT ((0)) NOT NULL,
    [rowguid]                   UNIQUEIDENTIFIER CONSTRAINT [DF_LkupSystemFunctionToOperation_rowguid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]        BIGINT           NULL,
    [SourceSystemKeyValue]      NVARCHAR (MAX)   NULL,
    [AuditCreateUser]           VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]            DATETIME         CONSTRAINT [DF__LkupSyste__Audit__3A04F23F] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]           VARCHAR (100)    NULL,
    [AuditUpdateDTM]            DATETIME         NULL,
    [idfsModuleName]            BIGINT           NULL,
    CONSTRAINT [XPKSystemFunctionToOperation] PRIMARY KEY CLUSTERED ([SystemFunctionID] ASC, [SystemFunctionOperationID] ASC),
    CONSTRAINT [FK_LkupSystemFunctionToOperation_BaseReference_idfsModule] FOREIGN KEY ([idfsModuleName]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupSystemFunctionToOperation_BaseReference_SysFunctionOperationID] FOREIGN KEY ([SystemFunctionOperationID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupSystemFunctionToOperation_BaseReference_SystemFunction] FOREIGN KEY ([SystemFunctionID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupSystemFunctionToOperation_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_LkupSystemFunctionToOperation_A_Update] ON [dbo].[LkupSystemFunctionToOperation]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(SystemFunctionID) AND UPDATE(SystemFunctionOperationID)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

	-- Added 07 Dec 2020 to update the AuditUpdateDTM when the record is updated
	IF (dbo.FN_GBL_TriggersWork ()=1)
	BEGIN

		UPDATE a
		SET a.AuditUpdateDTM = GETDATE()
		FROM dbo.LkupSystemFunctionToOperation AS a 
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID

		UPDATE a
		SET a.AuditUpdateUser = SUSER_NAME()
		FROM dbo.LkupSystemFunctionToOperation AS a 
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID
		WHERE NOT UPDATE(AuditUpdateUser)

	END

END

GO


CREATE TRIGGER [dbo].[TR_LkupSystemFunctionToOperation_I_Delete] on [dbo].[LkupSystemFunctionToOperation]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([SystemFunctionID], [SystemFunctionOperationID]) as
		(
			SELECT [SystemFunctionID], [SystemFunctionOperationID] FROM deleted
			EXCEPT
			SELECT [SystemFunctionID], [SystemFunctionOperationID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.[LkupSystemFunctionToOperation] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[SystemFunctionID] = b.[SystemFunctionID]
			AND a.[SystemFunctionOperationID] = b.[SystemFunctionOperationID];

	END

END

ALTER TABLE [dbo].[LkupSystemFunctionToOperation] ENABLE TRIGGER [TR_LkupSystemFunctionToOperation_I_Delete]
