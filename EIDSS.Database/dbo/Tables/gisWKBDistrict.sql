CREATE TABLE [dbo].[gisWKBDistrict] (
    [idfsGeoObject]        BIGINT           NOT NULL,
    [name_en]              NVARCHAR (200)   NULL,
    [name_th]              NVARCHAR (200)   NULL,
    [geomShape]            [sys].[geometry] NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_gisWKBDistrict_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_gisWKBDistrict_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKgisWKBDistrict] PRIMARY KEY CLUSTERED ([idfsGeoObject] ASC),
    CONSTRAINT [FK_gisWKBDistrict_gisBaseReference] FOREIGN KEY ([idfsGeoObject]) REFERENCES [dbo].[gisBaseReference] ([idfsGISBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisWKBDistrict_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_gisWKBDistrict_A_Update] ON [dbo].[gisWKBDistrict]
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
