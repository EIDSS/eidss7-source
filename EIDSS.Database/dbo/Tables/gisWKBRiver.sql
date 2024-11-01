﻿CREATE TABLE [dbo].[gisWKBRiver] (
    [idfsGeoObject]        BIGINT           NOT NULL,
    [strCode]              NVARCHAR (256)   NULL,
    [NameEng]              NVARCHAR (256)   NULL,
    [NameRu]               NVARCHAR (256)   NULL,
    [Type]                 NVARCHAR (256)   NULL,
    [idfsCountry]          BIGINT           NULL,
    [geomShape]            [sys].[geometry] NULL,
    [NameLoc]              NVARCHAR (256)   NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_gisWKBRiver_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_gisWKBRiver_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKgisWKBRiver] PRIMARY KEY CLUSTERED ([idfsGeoObject] ASC),
    CONSTRAINT [FK_gisWKBRiver_gisCountry] FOREIGN KEY ([idfsCountry]) REFERENCES [dbo].[gisCountry] ([idfsCountry]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBRiver_gisOtherBaseReference] FOREIGN KEY ([idfsGeoObject]) REFERENCES [dbo].[gisOtherBaseReference] ([idfsGISOtherBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBRiver_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE SPATIAL INDEX [IX_gisWKBRiver_geomShape]
    ON [dbo].[gisWKBRiver] ([geomShape])
    USING GEOMETRY_GRID
    WITH  (
            BOUNDING_BOX = (XMAX = 9723590, XMIN = 2478360, YMAX = 7279960, YMIN = 3565910),
            GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM)
          );


GO

CREATE TRIGGER [dbo].[TR_gisWKBRiver_A_Update] ON [dbo].[gisWKBRiver]
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
