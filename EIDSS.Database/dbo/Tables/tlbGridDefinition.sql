CREATE TABLE [dbo].[tlbGridDefinition] (
    [idfGrid]              BIGINT           NOT NULL,
    [idfUserID]            BIGINT           NULL,
    [idfsSite]             BIGINT           NULL,
    [ColumnDefinition]     NVARCHAR (MAX)   NULL,
    [GridID]               NVARCHAR (200)   NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_rowguid] DEFAULT (newid()) ROWGUIDCOL NULL,
    [intRowStatus]         INT              CONSTRAINT [tlbGridDefinition_intRowStatus] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tlbGridDefinition_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tlbGridDefinition_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtlbGridDefinition] PRIMARY KEY CLUSTERED ([idfGrid] ASC),
    CONSTRAINT [FK_tlbGridDefinition_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbGridDefinition_tstSite_idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]),
    CONSTRAINT [FK_tlbGridDefinition_tstUserTable_idfUserID] FOREIGN KEY ([idfUserID]) REFERENCES [dbo].[tstUserTable] ([idfUserID])
);

