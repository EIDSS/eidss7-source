CREATE TABLE [dbo].[tflMonitoringSessionFiltered] (
    [idfMonitoringSessionFiltered] BIGINT           NOT NULL,
    [idfMonitoringSession]         BIGINT           NOT NULL,
    [idfSiteGroup]                 BIGINT           NOT NULL,
    [rowguid]                      UNIQUEIDENTIFIER CONSTRAINT [newid__2566] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]           BIGINT           CONSTRAINT [DEF_tflMonitoringSessionFiltered_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]         NVARCHAR (MAX)   NULL,
    [AuditCreateUser]              NVARCHAR (200)   NULL,
    [AuditCreateDTM]               DATETIME         CONSTRAINT [DF_tflMonitoringSessionFiltered_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]              NVARCHAR (200)   NULL,
    [AuditUpdateDTM]               DATETIME         NULL,
    CONSTRAINT [XPKtflMonitoringSessionFiltered] PRIMARY KEY CLUSTERED ([idfMonitoringSessionFiltered] ASC),
    CONSTRAINT [FK_tflMonitoringSessionFiltered_tflSiteGroup__idfSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflMonitoringSessionFiltered_tlbMonitoringSession__idfMonitoringSession_R_1819] FOREIGN KEY ([idfMonitoringSession]) REFERENCES [dbo].[tlbMonitoringSession] ([idfMonitoringSession]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflMonitoringSessionFiltered_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [tflMonitoringSessionFiltered_idfMonitoringSession_idfSiteGroup]
    ON [dbo].[tflMonitoringSessionFiltered]([idfMonitoringSession] ASC, [idfSiteGroup] ASC);


GO

CREATE TRIGGER [dbo].[TR_tflMonitoringSessionFiltered_A_Update] ON [dbo].[tflMonitoringSessionFiltered]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfMonitoringSessionFiltered))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
