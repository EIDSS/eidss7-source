CREATE TABLE [dbo].[LkupRoleSystemFunctionAccess] (
    [idfEmployee]                   BIGINT           NOT NULL,
    [SystemFunctionID]              BIGINT           NOT NULL,
    [SystemFunctionOperationID]     BIGINT           NOT NULL,
    [AccessPermissionID]            BIGINT           NULL,
    [intRowStatus]                  INT              DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]               VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]                DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]               VARCHAR (100)    NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [DF_LkupRoleSystemFunctionAccess_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]            BIGINT           NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [intRowStatusForSystemFunction] INT              CONSTRAINT [DEF_LkupRoleSystemFunctionAccess_intRowStatusForSystemFunction] DEFAULT ((0)) NULL,
    CONSTRAINT [XPKDefaultRoleAccess] PRIMARY KEY CLUSTERED ([idfEmployee] ASC, [SystemFunctionID] ASC, [SystemFunctionOperationID] ASC),
    CONSTRAINT [FK_lkupRoleSysFunctionAccess_BaseReference_SysFunctionOperationID] FOREIGN KEY ([SystemFunctionOperationID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_lkupRoleSysFunctionAccess_BaseReference_SystemFunction] FOREIGN KEY ([SystemFunctionID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_lkupRoleSysFunctionAccess_trtBaseRef_AccessPermissionID] FOREIGN KEY ([AccessPermissionID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupRoleSystemFunctionAccess_idfEmployee] FOREIGN KEY ([idfEmployee]) REFERENCES [dbo].[tlbEmployee] ([idfEmployee]),
    CONSTRAINT [FK_LkupRoleSystemFunctionAccess_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [IX_LkupRoleSystemFunctionAccess]
    ON [dbo].[LkupRoleSystemFunctionAccess]([SystemFunctionID] ASC, [intRowStatusForSystemFunction] ASC);


GO

CREATE TRIGGER [dbo].[TR_LkupRoleSystemFunctionAccess_A_Update] ON [dbo].[LkupRoleSystemFunctionAccess]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(SystemFunctionID) OR UPDATE(SystemFunctionOperationID) OR UPDATE(idfEmployee)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

	-- Added 07 Dec 2020 to update the AuditUpdateDTM when the record is updated
	IF (dbo.FN_GBL_TriggersWork ()=1)
	BEGIN

		UPDATE a
		SET a.AuditUpdateDTM = GETDATE()
		FROM dbo.LkupRoleSystemFunctionAccess AS a 
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID AND a.idfEmployee = b.idfEmployee

		UPDATE a
		SET a.AuditUpdateUser = SUSER_NAME()
		FROM dbo.LkupRoleSystemFunctionAccess AS a 
		INNER JOIN inserted AS b ON a.SystemFunctionID = b.SystemFunctionID AND a.SystemFunctionOperationID = b.SystemFunctionOperationID AND a.idfEmployee = b.idfEmployee
		WHERE NOT UPDATE(AuditUpdateUser)

	END

END

GO


CREATE TRIGGER [dbo].[TR_LkupRoleSystemFunctionAccess_I_Delete] on [dbo].[LkupRoleSystemFunctionAccess]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfEmployee], [SystemFunctionID], [SystemFunctionOperationID]) as
		(
			SELECT Deleted.idfEmployee, [SystemFunctionID], [SystemFunctionOperationID] FROM deleted
			EXCEPT
			SELECT idfEmployee, [SystemFunctionID], [SystemFunctionOperationID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.[LkupRoleSystemFunctionAccess] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.idfEmployee = b.idfEmployee
			AND a.[SystemFunctionID] = b.[SystemFunctionID]
			AND a.[SystemFunctionOperationID] = b.[SystemFunctionOperationID];

	END

END
