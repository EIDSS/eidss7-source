CREATE TABLE [dbo].[tlbxSiteDocumentMap] (
    [EIDSSMenuId]          BIGINT           NULL,
    [xSiteGUID]            UNIQUEIDENTIFIER NULL,
    [LanguageCode]         NVARCHAR (10)    NULL,
    [inRowStatus]          INT              CONSTRAINT [DF_tlbxSiteDocumentMap_inRowStatus] DEFAULT ((0)) NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [FK_tlbxSiteDocumentMap_LkupEIDSSMenu] FOREIGN KEY ([EIDSSMenuId]) REFERENCES [dbo].[LkupEIDSSMenu] ([EIDSSMenuID]) NOT FOR REPLICATION
);

