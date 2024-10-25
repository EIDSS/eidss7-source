CREATE TABLE [dbo].[tlbGeoLocationSharedTranslation] (
    [idfGeoLocationShared]  BIGINT           NOT NULL,
    [idfsLanguage]          BIGINT           NOT NULL,
    [strTextString]         NVARCHAR (2000)  NULL,
    [strShortAddressString] NVARCHAR (2000)  NULL,
    [strMaintenanceFlag]    NVARCHAR (20)    NULL,
    [strReservedAttribute]  NVARCHAR (MAX)   NULL,
    [rowguid]               UNIQUEIDENTIFIER CONSTRAINT [DF_tlbGeoLocationSharedTranslation_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]    BIGINT           CONSTRAINT [DEF_tlbGeoLocationSharedTranslation_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]  NVARCHAR (MAX)   NULL,
    [AuditCreateUser]       NVARCHAR (200)   NULL,
    [AuditCreateDTM]        DATETIME         CONSTRAINT [DF_tlbGeoLocationSharedTranslation_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]       NVARCHAR (200)   NULL,
    [AuditUpdateDTM]        DATETIME         NULL,
    CONSTRAINT [XPKtlbGeoLocationSharedTranslation] PRIMARY KEY CLUSTERED ([idfGeoLocationShared] ASC, [idfsLanguage] ASC),
    CONSTRAINT [FK_tlbGeoLocationSharedTranslation_tlbGeoLocationShared__idfGeoLocationShared] FOREIGN KEY ([idfGeoLocationShared]) REFERENCES [dbo].[tlbGeoLocationShared] ([idfGeoLocationShared]) ON DELETE CASCADE NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocationSharedTranslation_trtBaseReference__idfsLanguage] FOREIGN KEY ([idfsLanguage]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocationSharedTranslation_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [IX_tlbGeoLocationSharedTranslation_BL]
    ON [dbo].[tlbGeoLocationSharedTranslation]([idfGeoLocationShared] ASC, [idfsLanguage] ASC)
    INCLUDE([strTextString]);


GO

CREATE TRIGGER [dbo].[TR_tlbGeoLocationSharedTranslation_A_Update] ON [dbo].[tlbGeoLocationSharedTranslation]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND (UPDATE(idfGeoLocationShared) OR UPDATE(idfsLanguage)))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
