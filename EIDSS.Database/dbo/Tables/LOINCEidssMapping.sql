CREATE TABLE [dbo].[LOINCEidssMapping] (
    [idfsBaseReference]    BIGINT           NOT NULL,
    [idfsReferenceType]    BIGINT           NOT NULL,
    [LOINC_NUM]            NVARCHAR (255)   NULL,
    [intRowStatus]         INT              CONSTRAINT [LOINCEidssMapping_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [LOINCEidssMapping__rowguid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_LOINCEidssMapping_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKEIDSSLOINGMapping] PRIMARY KEY CLUSTERED ([idfsBaseReference] ASC),
    CONSTRAINT [FK_LOINCEidssMapping_trtBaseReference__idfsBaseReference] FOREIGN KEY ([idfsBaseReference]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_LOINCEidssMapping_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LOINCEidssMapping_trtReferenecType__idfsReferenceType] FOREIGN KEY ([idfsReferenceType]) REFERENCES [dbo].[trtReferenceType] ([idfsReferenceType]) NOT FOR REPLICATION
);

