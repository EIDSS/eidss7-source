﻿CREATE TABLE [dbo].[gisWKBEarthRoad] (
    [idfsGeoObject]        BIGINT           NOT NULL,
    [strCode]              NVARCHAR (256)   NULL,
    [NameEng]              NVARCHAR (256)   NULL,
    [NameRu]               NVARCHAR (256)   NULL,
    [Type]                 NVARCHAR (256)   NULL,
    [Code]                 NVARCHAR (256)   NULL,
    [idfsCountry]          BIGINT           NULL,
    [geomShape]            [sys].[geometry] NULL,
    [NameLoc]              NVARCHAR (256)   NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_gisWKBEarthRoad_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_gisWKBEarthRoad_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKgisWKBEarthRoad] PRIMARY KEY CLUSTERED ([idfsGeoObject] ASC),
    CONSTRAINT [FK_gisWKBEarthRoad_gisCountry] FOREIGN KEY ([idfsCountry]) REFERENCES [dbo].[gisCountry] ([idfsCountry]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBEarthRoad_gisOtherBaseReference] FOREIGN KEY ([idfsGeoObject]) REFERENCES [dbo].[gisOtherBaseReference] ([idfsGISOtherBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBEarthRoad_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE SPATIAL INDEX [IX_gisWKBEarthRoad_geomShape]
    ON [dbo].[gisWKBEarthRoad] ([geomShape])
    USING GEOMETRY_GRID
    WITH  (
            BOUNDING_BOX = (XMAX = 9783480, XMIN = 2462180, YMAX = 7443930, YMIN = 3507660),
            GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM)
          );


GO

CREATE TRIGGER [dbo].[TR_gisWKBEarthRoad_A_Update] ON [dbo].[gisWKBEarthRoad]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGeoObject))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
