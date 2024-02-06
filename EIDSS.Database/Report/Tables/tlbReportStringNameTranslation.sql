CREATE TABLE [Report].[tlbReportStringNameTranslation] (
    [idfsLanguage]         BIGINT           NOT NULL,
    [idfsReportID]         BIGINT           NOT NULL,
    [idfsReportTextID]     BIGINT           NOT NULL,
    [strTextString]        NVARCHAR (2000)  NULL,
    [Comments]             NVARCHAR (MAX)   NULL,
    [rowguid]              UNIQUEIDENTIFIER DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtlbReportStringNameTranslation] PRIMARY KEY CLUSTERED ([idfsLanguage] ASC, [idfsReportID] ASC, [idfsReportTextID] ASC)
);



