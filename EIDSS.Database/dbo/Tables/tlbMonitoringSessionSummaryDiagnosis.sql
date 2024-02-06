CREATE TABLE [dbo].[tlbMonitoringSessionSummaryDiagnosis] (
    [idfMonitoringSessionSummary] BIGINT           NOT NULL,
    [idfsDiagnosis]               BIGINT           NOT NULL,
    [intRowStatus]                INT              CONSTRAINT [DF__tlbMonito__intRo__6DED45B5] DEFAULT ((0)) NOT NULL,
    [rowguid]                     UNIQUEIDENTIFIER CONSTRAINT [tlbMonitoringSessionSummaryDiagnosis_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [blnChecked]                  BIT              CONSTRAINT [DF__tlbMonito__blnCh__66F62F63] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]          NVARCHAR (20)    NULL,
    [strReservedAttribute]        NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]          BIGINT           CONSTRAINT [DEF_tlbMonitoringSessionSummaryDiagnosis_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]        NVARCHAR (MAX)   NULL,
    [AuditCreateUser]             NVARCHAR (200)   NULL,
    [AuditCreateDTM]              DATETIME         CONSTRAINT [DF_tlbMonitoringSessionSummaryDiagnosis_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]             NVARCHAR (200)   NULL,
    [AuditUpdateDTM]              DATETIME         NULL,
    CONSTRAINT [PK_tlbMonitoringSessionSummaryDiagnosis] PRIMARY KEY CLUSTERED ([idfMonitoringSessionSummary] ASC, [idfsDiagnosis] ASC),
    CONSTRAINT [FK_tlbMonitoringSessionSummaryDiagnosis_tlbMonitoringSessionSummary__idfMonitoringSessionSummary] FOREIGN KEY ([idfMonitoringSessionSummary]) REFERENCES [dbo].[tlbMonitoringSessionSummary] ([idfMonitoringSessionSummary]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSessionSummaryDiagnosis_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbMonitoringSessionSummaryDiagnosis_trtDiagnosis__idfsDiagnosis] FOREIGN KEY ([idfsDiagnosis]) REFERENCES [dbo].[trtDiagnosis] ([idfsDiagnosis]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummaryDiagnosis_A_Update] ON [dbo].[tlbMonitoringSessionSummaryDiagnosis]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionSummary))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_tlbMonitoringSessionSummaryDiagnosis_I_Delete] on [dbo].[tlbMonitoringSessionSummaryDiagnosis]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfMonitoringSessionSummary], [idfsDiagnosis]) as
		(
			SELECT [idfMonitoringSessionSummary], [idfsDiagnosis] FROM deleted
			EXCEPT
			SELECT [idfMonitoringSessionSummary], [idfsDiagnosis] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1
		FROM dbo.tlbMonitoringSessionSummaryDiagnosis as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfMonitoringSessionSummary = b.idfMonitoringSessionSummary
			AND a.idfsDiagnosis = b.idfsDiagnosis;

	END

END
