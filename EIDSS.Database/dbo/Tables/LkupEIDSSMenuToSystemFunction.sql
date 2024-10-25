CREATE TABLE [dbo].[LkupEIDSSMenuToSystemFunction] (
    [EIDSSMenuID]          BIGINT           NOT NULL,
    [SystemFunctionID]     BIGINT           NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_LkupEIDSSMenuToSystemFunction_intRowStatus] DEFAULT ((0)) NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_LkupEIDSSMenuToSystemFunction_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]       DATETIME         NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    CONSTRAINT [DF__LkupEIDSS__AuditUpdateUser] DEFAULT ('SYSTEM') NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF__LkupEIDSS__AuditUpdateDTM] DEFAULT (getdate()) NULL,
    CONSTRAINT [XPKLkupEIDSSMenuToSystemFunction] PRIMARY KEY CLUSTERED ([EIDSSMenuID] ASC, [SystemFunctionID] ASC),
    CONSTRAINT [FK_LkupEIDSSMenuToSystemFunction_BaseRef_MenuID] FOREIGN KEY ([EIDSSMenuID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupEIDSSMenuToSystemFunction_BaseRef_SystemFunctionID] FOREIGN KEY ([SystemFunctionID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupEIDSSMenuToSystemFunction_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO


CREATE TRIGGER [dbo].[TR_LkupEIDSSMenuToSystemFunction_A_Update] ON [dbo].[LkupEIDSSMenuToSystemFunction]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork () = 1 AND (UPDATE(EIDSSMenuID) AND UPDATE(SystemFunctionID)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO



CREATE TRIGGER [dbo].[TR_LkupEIDSSMenuToSystemFunction_I_Delete] ON [dbo].[LkupEIDSSMenuToSystemFunction]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([EIDSSMenuID], [SystemFunctionID]) AS
		(
			SELECT [EIDSSMenuID], [SystemFunctionID] FROM deleted
			EXCEPT
			SELECT [EIDSSMenuID], [SystemFunctionID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.[LkupEIDSSMenuToSystemFunction] AS a 
		INNER JOIN cteOnlyDeletedRows AS b 
			ON a.[EIDSSMenuID] = b.[EIDSSMenuID]
			AND a.[SystemFunctionID] = b.[SystemFunctionID];

	END

END
