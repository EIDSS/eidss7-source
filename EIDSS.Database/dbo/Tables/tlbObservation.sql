CREATE TABLE [dbo].[tlbObservation] (
    [idfObservation]       BIGINT           NOT NULL,
    [idfsFormTemplate]     BIGINT           NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_0_1972] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [newid__1976] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [idfsSite]             BIGINT           CONSTRAINT [DF_tlbObservation_idfsSite] DEFAULT ([dbo].[FN_GBL_SITEID_GET]()) NOT NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tlbObservation_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tlbObservation_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtlbObservation] PRIMARY KEY CLUSTERED ([idfObservation] ASC),
    CONSTRAINT [FK_tlbObservation_ffFormTemplate__idfsFormTemplate_R_1405] FOREIGN KEY ([idfsFormTemplate]) REFERENCES [dbo].[ffFormTemplate] ([idfsFormTemplate]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbObservation_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbObservation_tstSite__idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO


CREATE TRIGGER [dbo].[TR_tlbObservation_I_Delete] on [dbo].[tlbObservation]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfObservation]) as
		(
			SELECT [idfObservation] FROM deleted
			EXCEPT
			SELECT [idfObservation] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1
		FROM dbo.tlbObservation as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfObservation = b.idfObservation;

	END

END

GO

CREATE TRIGGER [dbo].[TR_tlbObservation_A_Update] ON [dbo].[tlbObservation]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfObservation))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Flex-form filled out instances', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbObservation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Flex-Form instance identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbObservation', @level2type = N'COLUMN', @level2name = N'idfObservation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Flex-form template identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbObservation', @level2type = N'COLUMN', @level2name = N'idfsFormTemplate';

