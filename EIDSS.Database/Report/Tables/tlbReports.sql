CREATE TABLE [Report].[tlbReports] (
    [idfsReportID]         BIGINT           NOT NULL,
    [idfsLanguage]         BIGINT           NOT NULL,
    [strName]              NVARCHAR (2000)  NULL,
    [strURL]               NVARCHAR (MAX)   NULL,
    [rowguid]              UNIQUEIDENTIFIER DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtlbReports] PRIMARY KEY CLUSTERED ([idfsLanguage] ASC, [idfsReportID] ASC)
);


GO

