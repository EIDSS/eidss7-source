CREATE TABLE [dbo].[gisMainCityForRayon] (
    [idfsRayon]            BIGINT           NOT NULL,
    [idfsMainSettlement]   BIGINT           NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [newid_gisMainCityForRayon] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [DF_gisMainCityForRayon_intRowStatus] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_gisMainCityForRayon_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF_gisMainCityForRayon_UpdateDTM] DEFAULT (getdate()) NULL,
    CONSTRAINT [XPKgisMainCityForRayon] PRIMARY KEY CLUSTERED ([idfsRayon] ASC),
    CONSTRAINT [FK_gisMainCityForRayon_gisRayon__idfsRayon] FOREIGN KEY ([idfsRayon]) REFERENCES [dbo].[gisRayon] ([idfsRayon]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisMainCityForRayon_gisSettlement__idfsMainSettlement] FOREIGN KEY ([idfsMainSettlement]) REFERENCES [dbo].[gisSettlement] ([idfsSettlement]) NOT FOR REPLICATION
);

