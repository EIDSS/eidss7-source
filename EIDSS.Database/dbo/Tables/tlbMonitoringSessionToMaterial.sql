CREATE TABLE [dbo].[tlbMonitoringSessionToMaterial] (
    [idfMonitoringSessionToMaterial] BIGINT           NOT NULL,
    [idfMonitoringSession]           BIGINT           NOT NULL,
    [idfMaterial]                    BIGINT           NOT NULL,
    [idfsSampleType]                 BIGINT           NOT NULL,
    [intRowStatus]                   INT              CONSTRAINT [[tlbMonitoringSessionToMaterial_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]                        UNIQUEIDENTIFIER CONSTRAINT [tlbMonitoringSessionToMaterial_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]             NVARCHAR (20)    NULL,
    [strReservedAttribute]           NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]             BIGINT           CONSTRAINT [DEF_tlbMonitoringSessionToMaterial_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]           NVARCHAR (MAX)   NULL,
    [AuditCreateUser]                NVARCHAR (200)   CONSTRAINT [tlbMonitoringSessionToMaterial_AuditCreateUser] DEFAULT (getdate()) NULL,
    [AuditCreateDTM]                 DATETIME         CONSTRAINT [tlbMonitoringSessionToMaterial_AuditCreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]                NVARCHAR (200)   CONSTRAINT [DF_tlbMonitoringSessionToMaterial_AuditUpdateUser] DEFAULT (getdate()) NULL,
    [AuditUpdateDTM]                 DATETIME         CONSTRAINT [DF_tlbMonitoringSessionToMaterial_AuditUpdateDTM] DEFAULT (getdate()) NULL,
    [idfsDisease]                    BIGINT           NULL,
    CONSTRAINT [XPKtlbMonitoringSessionToMaterial] PRIMARY KEY CLUSTERED ([idfMonitoringSessionToMaterial] ASC),
    CONSTRAINT [FK_tlbMonitoringSessionToMaterial_tlbMaterial] FOREIGN KEY ([idfMaterial]) REFERENCES [dbo].[tlbMaterial] ([idfMaterial]),
    CONSTRAINT [FK_tlbMonitoringSessionToMaterial_trtBaseRef_idfsSampleType] FOREIGN KEY ([idfsSampleType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbMonitoringSessionToMaterial_trtBaseReference] FOREIGN KEY ([idfsDisease]) REFERENCES [dbo].[trtDiagnosis] ([idfsDiagnosis]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbMonitoringSessionToMaterial_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);



