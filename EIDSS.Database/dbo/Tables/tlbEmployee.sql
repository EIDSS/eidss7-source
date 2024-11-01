﻿CREATE TABLE [dbo].[tlbEmployee] (
    [idfEmployee]          BIGINT           NOT NULL,
    [idfsEmployeeType]     BIGINT           NOT NULL,
    [idfsSite]             BIGINT           CONSTRAINT [Def_fnSiteID_tlbEmployee] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_0_1949] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [newid__1948] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tlbEmployee_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tlbEmployee_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [idfsEmployeeCategory] BIGINT           CONSTRAINT [DF__tlbEmploy__idfsE__75A4DAFA] DEFAULT ((10526002)) NOT NULL,
    CONSTRAINT [XPKtlbEmployee] PRIMARY KEY CLUSTERED ([idfEmployee] ASC),
    CONSTRAINT [FK_Employee_Site] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbEmployee_trtBaseReference__idfsEmployeeType_R_1250] FOREIGN KEY ([idfsEmployeeType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbEmployee_trtBaseReference_idfsEmployeeCategory] FOREIGN KEY ([idfsEmployeeCategory]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbEmployee_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [IX_tlbEmployee_intRowStatus_idfsEmployeeCategory]
    ON [dbo].[tlbEmployee]([intRowStatus] ASC, [idfsEmployeeCategory] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbEmployee_idfsEmployeeType]
    ON [dbo].[tlbEmployee]([idfsEmployeeType] ASC, [intRowStatus] ASC, [idfsSite] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbEmployee_intRowStatus_idfsEmployeeType]
    ON [dbo].[tlbEmployee]([intRowStatus] ASC, [idfsEmployeeType] ASC)
    INCLUDE([idfsSite]);


GO

CREATE TRIGGER [dbo].[TR_tlbEmployee_A_Update] ON [dbo].[tlbEmployee]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfEmployee))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_tlbEmployee_I_Delete] on [dbo].[tlbEmployee]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfEmployee]) as
		(
			SELECT [idfEmployee] FROM deleted
			EXCEPT
			SELECT [idfEmployee] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1
		FROM dbo.tlbEmployee as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfEmployee = b.idfEmployee;

	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Employees', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbEmployee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Employee/group identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbEmployee', @level2type = N'COLUMN', @level2name = N'idfEmployee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Employee/group type identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbEmployee', @level2type = N'COLUMN', @level2name = N'idfsEmployeeType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Site identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbEmployee', @level2type = N'COLUMN', @level2name = N'idfsSite';

