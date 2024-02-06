CREATE TABLE [dbo].[LkupRoleMenuAccess] (
    [idfEmployee]          BIGINT           NOT NULL,
    [EIDSSMenuID]          BIGINT           NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_LkupRoleMenuAccess_intRowStatus] DEFAULT ((0)) NULL,
    [AuditCreateUser]      VARCHAR (100)    CONSTRAINT [DF__LkupRoleM__Audit__357FF5ED] DEFAULT ('SYSTEM') NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF__LkupRoleM__Audit__36741A26] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_LkupRoleMenuAccess_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKLkupRoleMenuAccess] PRIMARY KEY CLUSTERED ([idfEmployee] ASC, [EIDSSMenuID] ASC),
    CONSTRAINT [FK_LkupRoleMenuAccess_idfEmployee] FOREIGN KEY ([idfEmployee]) REFERENCES [dbo].[tlbEmployee] ([idfEmployee]),
    CONSTRAINT [FK_LkupRoleMenuAccess_LkupEIDSSMenu_MenuID] FOREIGN KEY ([EIDSSMenuID]) REFERENCES [dbo].[LkupEIDSSMenu] ([EIDSSMenuID]),
    CONSTRAINT [FK_LkupRoleMenuAccess_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_LkupRoleMenuAccess_A_Update] ON [dbo].[LkupRoleMenuAccess]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(EIDSSMenuID) AND UPDATE(idfEmployee)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_LkupRoleMenuAccess_I_Delete] on [dbo].[LkupRoleMenuAccess]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfEmployee], [EIDSSMenuID]) as
		(
			SELECT [idfEmployee], [EIDSSMenuID] FROM deleted
			EXCEPT
			SELECT [idfEmployee], [EIDSSMenuID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.[LkupRoleMenuAccess] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[idfEmployee] = b.[idfEmployee]
			AND a.[EIDSSMenuID] = b.[EIDSSMenuID];

	END

END
