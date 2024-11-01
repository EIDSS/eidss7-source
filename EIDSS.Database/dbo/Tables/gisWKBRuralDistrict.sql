﻿CREATE TABLE [dbo].[gisWKBRuralDistrict] (
    [idfsGeoObject]        BIGINT           NOT NULL,
    [geomShape]            [sys].[geometry] NULL,
    [idfsCountry]          BIGINT           NULL,
    [intRegCode]           INT              NULL,
    [intCode]              INT              NULL,
    [strKato]              NVARCHAR (MAX)   NULL,
    [strRegNameRus]        NVARCHAR (MAX)   NULL,
    [strRegNameLoc]        NVARCHAR (MAX)   NULL,
    [strDesc]              NVARCHAR (MAX)   NULL,
    [strNameRus]           NVARCHAR (MAX)   NULL,
    [strNameLoc]           NVARCHAR (MAX)   NULL,
    [strNameEn]            NVARCHAR (MAX)   NULL,
    [rowguid]              UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKgisWKBRuralDistrict] PRIMARY KEY CLUSTERED ([idfsGeoObject] ASC),
    CONSTRAINT [FK_gisWKBRuralDistrict_gisCountry] FOREIGN KEY ([idfsCountry]) REFERENCES [dbo].[gisCountry] ([idfsCountry]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBRuralDistrict_gisOtherBaseReference] FOREIGN KEY ([idfsGeoObject]) REFERENCES [dbo].[gisOtherBaseReference] ([idfsGISOtherBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBRuralDistrict_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

