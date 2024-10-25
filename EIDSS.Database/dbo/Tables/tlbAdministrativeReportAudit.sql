CREATE TABLE [dbo].[tlbAdministrativeReportAudit] (
    [idfAdminReportAudit]  BIGINT           NOT NULL,
    [idfsReport]           BIGINT           NOT NULL,
    [RoleID]               BIGINT           NOT NULL,
    [idfOrganization]      BIGINT           NULL,
    [ReportSigned]         BIT              NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [tlbAdministrativeReportAudit_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [tlbAdministrativeReportAudit_intRowStatus] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DF_tlbAdministrativeReportAudit_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tlbAdministrativeReportAudit_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtlbAdministrativeReportAudit] PRIMARY KEY CLUSTERED ([idfAdminReportAudit] ASC),
    CONSTRAINT [FK_tlbAdministrativeReportAudit_idfsReport] FOREIGN KEY ([idfsReport]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbAdministrativeReportAudit_RoleID] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[tlbEmployeeGroup] ([idfEmployeeGroup]) NOT FOR REPLICATION
);

