CREATE TABLE [dbo].[LkupRoleDashboardObject] (
    [idfEmployee]          BIGINT           NOT NULL,
    [DashboardObjectID]    BIGINT           NOT NULL,
    [DisplayName]          VARCHAR (200)    NULL,
    [DisplayOrder]         INT              NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_LkupRoleDashboardObject_intRowStatus] DEFAULT ((0)) NULL,
    [AuditCreateUser]      VARCHAR (100)    CONSTRAINT [DF__LkupRoleD__Audit__068FFCDA] DEFAULT ('SYSTEM') NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF__LkupRoleD__Audit__07842113] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_LkupRoleDashboardObject_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKLkupDefaultRoleDashboardObject] PRIMARY KEY CLUSTERED ([idfEmployee] ASC, [DashboardObjectID] ASC),
    CONSTRAINT [FK_LkupRoleDashboardObject_AppObject_SashboardObjectID] FOREIGN KEY ([DashboardObjectID]) REFERENCES [dbo].[LkupEIDSSAppObject] ([AppObjectNameID]),
    CONSTRAINT [FK_LkupRoleDashboardObject_idfEmployee] FOREIGN KEY ([idfEmployee]) REFERENCES [dbo].[tlbEmployee] ([idfEmployee]),
    CONSTRAINT [FK_LkupRoleDashboardObject_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO


CREATE TRIGGER [dbo].[TR_LkupRoleDashboardObject_I_Delete] on [dbo].[LkupRoleDashboardObject]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfEmployee], [DashboardObjectID]) as
		(
			SELECT [idfEmployee], [DashboardObjectID] FROM deleted
			EXCEPT
			SELECT [idfEmployee], [DashboardObjectID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.[LkupRoleDashboardObject] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[idfEmployee] = b.[idfEmployee]
			AND a.[DashboardObjectID] = b.[DashboardObjectID];

	END

END

GO

CREATE TRIGGER [dbo].[TR_LkupRoleDashboardObject_A_Update] ON [dbo].[LkupRoleDashboardObject]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(DashboardObjectID) AND UPDATE(idfEmployee)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
