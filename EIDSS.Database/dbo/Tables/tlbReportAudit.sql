CREATE TABLE [dbo].[tlbReportAudit] (
    [idfReportAudit]      BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [idfUserID]           BIGINT         NOT NULL,
    [FirstName]           NVARCHAR (256) NULL,
    [MiddleName]          NVARCHAR (256) NULL,
    [LastName]            NVARCHAR (256) NULL,
    [UserRole]            NVARCHAR (256) NULL,
    [Organization]        NVARCHAR (256) NOT NULL,
    [ReportName]          NVARCHAR (256) NULL,
    [IsSignatureIncluded] BIT            NULL,
    [GeneratedDate]       DATETIME       CONSTRAINT [DF__tlbReport__Gener__3D166914] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [XPKtlbReportsAudit] PRIMARY KEY CLUSTERED ([idfReportAudit] ASC)
);

