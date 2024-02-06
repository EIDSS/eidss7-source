CREATE TABLE [dbo].[gisWKBSettlementReady] (
    [oid]                  INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [idfsGeoObject]        BIGINT           NOT NULL,
    [Ratio]                INT              NOT NULL,
    [geomShape_3857]       [sys].[geometry] NULL,
    [geomShape_4326]       [sys].[geometry] NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_gisWKBSettlementReady_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_gisWKBSettlementReady_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [PK__gisWKBSe__C2FFCF130902EEBE] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_gisWKBSettlementReady_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_gisWKBSettlementReady_A_Update] ON [dbo].[gisWKBSettlementReady]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(oid))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
