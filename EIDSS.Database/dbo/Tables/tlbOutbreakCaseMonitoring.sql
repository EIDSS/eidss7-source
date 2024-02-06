CREATE TABLE [dbo].[tlbOutbreakCaseMonitoring] (
    [idfOutbreakCaseMonitoring] BIGINT           NOT NULL,
    [idfVetCase]                BIGINT           NULL,
    [idfHumanCase]              BIGINT           NULL,
    [idfObservation]            BIGINT           NULL,
    [idfInvestigatedByOffice]   BIGINT           NULL,
    [idfInvestigatedByPerson]   BIGINT           NULL,
    [strAdditionalComments]     NVARCHAR (MAX)   NULL,
    [datMonitoringDate]         DATETIME         NULL,
    [intRowStatus]              INT              CONSTRAINT [Def_tlbOutbreakCaseMonitoring_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]                   UNIQUEIDENTIFIER CONSTRAINT [newid_tlbOutbreakCaseMonitoring] DEFAULT (newid()) NOT NULL,
    [SourceSystemNameID]        BIGINT           CONSTRAINT [DEF_tlbOutbreakCaseMonitoring_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]      NVARCHAR (MAX)   NULL,
    [AuditCreateUser]           NVARCHAR (200)   NULL,
    [AuditCreateDTM]            DATETIME         CONSTRAINT [DF_tlbOutbreakCaseMonitoring_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]           NVARCHAR (200)   NULL,
    [AuditUpdateDTM]            DATETIME         CONSTRAINT [DF_tlbOutbreakCaseMonitoring_UpdateDTM] DEFAULT (getdate()) NULL,
    CONSTRAINT [XPKtlbOutbreakCaseMonitoring] PRIMARY KEY CLUSTERED ([idfOutbreakCaseMonitoring] ASC),
    CONSTRAINT [FK_tlbOutbreakCaseMonitoring_tlbHumanCase__idfHumanCase] FOREIGN KEY ([idfHumanCase]) REFERENCES [dbo].[tlbHumanCase] ([idfHumanCase]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreakCaseMonitoring_tlbObservation__idfInvestigatedByOffice] FOREIGN KEY ([idfInvestigatedByOffice]) REFERENCES [dbo].[tlbOffice] ([idfOffice]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreakCaseMonitoring_tlbObservation__idfInvestigatedByPerson] FOREIGN KEY ([idfInvestigatedByPerson]) REFERENCES [dbo].[tlbPerson] ([idfPerson]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreakCaseMonitoring_tlbObservation__idfObservation] FOREIGN KEY ([idfObservation]) REFERENCES [dbo].[tlbObservation] ([idfObservation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreakCaseMonitoring_tlbVetCase__idfVetCase] FOREIGN KEY ([idfVetCase]) REFERENCES [dbo].[tlbVetCase] ([idfVetCase]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbOutbreakCaseMonitoring_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO


CREATE TRIGGER [dbo].[TR_tlbOutbreakCaseMonitoring_A_Update] ON [dbo].[tlbOutbreakCaseMonitoring]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE([idfOutbreakCaseMonitoring]))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO



CREATE TRIGGER [dbo].[TR_tlbOutbreakCaseMonitoring_I_Delete] on [dbo].[tlbOutbreakCaseMonitoring]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfOutbreakCaseMonitoring]) as
		(
			SELECT [idfOutbreakCaseMonitoring] FROM deleted
			EXCEPT
			SELECT [idfOutbreakCaseMonitoring] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.[tlbOutbreakCaseMonitoring] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[idfOutbreakCaseMonitoring] = b.[idfOutbreakCaseMonitoring];

	END

END
