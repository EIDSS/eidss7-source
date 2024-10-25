CREATE TABLE [dbo].[EmployeeToInstitution] (
    [EmployeeToInstitution] BIGINT           NOT NULL,
    [aspNetUserId]          NVARCHAR (128)   NOT NULL,
    [idfUserId]             BIGINT           NOT NULL,
    [idfInstitution]        BIGINT           NOT NULL,
    [IsDefault]             BIT              NOT NULL,
    [intRowStatus]          INT              CONSTRAINT [DF__EmployeeToInstitution_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]               UNIQUEIDENTIFIER CONSTRAINT [DF__EmployeeToInstitution__rowguid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]    NVARCHAR (20)    NULL,
    [strReservedAttribute]  NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]    BIGINT           CONSTRAINT [DEF_EmployeeToInstitution_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]  NVARCHAR (MAX)   NULL,
    [AuditCreateUser]       NVARCHAR (200)   CONSTRAINT [DF__EmployeeToInstitution__AuditCreateUser] DEFAULT (user_name()) NULL,
    [AuditCreateDTM]        DATETIME         CONSTRAINT [DF_EmployeeToInstitution_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]       NVARCHAR (200)   CONSTRAINT [DF__EmployeeToInstitution__AuditUpdateUser] DEFAULT (user_name()) NULL,
    [AuditUpdateDTM]        DATETIME         CONSTRAINT [DF__EmployeeToInstitution__AuditUpdateDTM] DEFAULT (getdate()) NULL,
    [Active]                BIT              CONSTRAINT [DF_EmployeeToInstitution_Active] DEFAULT ('FALSE') NOT NULL,
    CONSTRAINT [XPKEmployeeToInstitution] PRIMARY KEY CLUSTERED ([EmployeeToInstitution] ASC),
    CONSTRAINT [FK_EmployeeToInstitution_AspNetUserId] FOREIGN KEY ([aspNetUserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) NOT FOR REPLICATION,
    CONSTRAINT [FK_EmployeeToInstitution_Office] FOREIGN KEY ([idfInstitution]) REFERENCES [dbo].[tlbOffice] ([idfOffice]) NOT FOR REPLICATION,
    CONSTRAINT [FK_EmployeeToInstitution_UserId] FOREIGN KEY ([idfUserId]) REFERENCES [dbo].[tstUserTable] ([idfUserID]) NOT FOR REPLICATION,
    CONSTRAINT [UK_EmployeeToInstitution_aspNetUserId_idfUserId] UNIQUE NONCLUSTERED ([aspNetUserId] ASC, [idfUserId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_EmployeeToInstitution_idfUserId]
    ON [dbo].[EmployeeToInstitution]([idfUserId] ASC);


GO




CREATE TRIGGER [dbo].[TR_EmployeeToInstitution_I_Delete] on [dbo].[EmployeeToInstitution]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([EmployeeToInstitution]) as
		(
			SELECT [EmployeeToInstitution] FROM deleted
			EXCEPT
			SELECT [EmployeeToInstitution] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.EmployeeToInstitution as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[EmployeeToInstitution] = b.[EmployeeToInstitution];

	END

END

GO


CREATE TRIGGER [dbo].[TR_EmployeeToInstitution_A_Update] on [dbo].[EmployeeToInstitution]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(EmployeeToInstitution))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
