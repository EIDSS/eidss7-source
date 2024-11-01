﻿CREATE TABLE [dbo].[tflGeoLocationFiltered] (
    [idfGeoLocationFiltered] BIGINT           NOT NULL,
    [idfGeoLocation]         BIGINT           NOT NULL,
    [idfSiteGroup]           BIGINT           NOT NULL,
    [rowguid]                UNIQUEIDENTIFIER CONSTRAINT [newid__2564] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]     BIGINT           CONSTRAINT [DEF_tflGeoLocationFiltered_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]   NVARCHAR (MAX)   NULL,
    [AuditCreateUser]        NVARCHAR (200)   NULL,
    [AuditCreateDTM]         DATETIME         CONSTRAINT [DF_tflGeoLocationFiltered_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]        NVARCHAR (200)   NULL,
    [AuditUpdateDTM]         DATETIME         NULL,
    CONSTRAINT [XPKtflGeoLocationFiltered] PRIMARY KEY CLUSTERED ([idfGeoLocationFiltered] ASC),
    CONSTRAINT [FK_tflGeoLocationFiltered_tflSiteGroup__idfSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflGeoLocationFiltered_tlbGeoLocation__idfGeoLocation_R_1805] FOREIGN KEY ([idfGeoLocation]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflGeoLocationFiltered_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [tflGeoLocationFiltered_idfGeoLocation_idfSiteGroup]
    ON [dbo].[tflGeoLocationFiltered]([idfGeoLocation] ASC, [idfSiteGroup] ASC);


GO

CREATE TRIGGER [dbo].[TR_tflGeoLocationFiltered_A_Update] ON [dbo].[tflGeoLocationFiltered]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfGeoLocationFiltered))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
