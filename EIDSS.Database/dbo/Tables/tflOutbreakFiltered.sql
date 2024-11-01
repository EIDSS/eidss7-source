﻿CREATE TABLE [dbo].[tflOutbreakFiltered] (
    [idfOutbreakFiltered]  BIGINT           NOT NULL,
    [idfOutbreak]          BIGINT           NOT NULL,
    [idfSiteGroup]         BIGINT           NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [newid__2569] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tflOutbreakFiltered_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tflOutbreakFiltered_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtflOutbreakFiltered] PRIMARY KEY CLUSTERED ([idfOutbreakFiltered] ASC),
    CONSTRAINT [FK_tflOutbreakFiltered_tflSiteGroup__idfSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflOutbreakFiltered_tlbOutbreak__idfOutbreak_R_1811] FOREIGN KEY ([idfOutbreak]) REFERENCES [dbo].[tlbOutbreak] ([idfOutbreak]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflOutbreakFiltered_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [tflOutbreakFiltered_idfOutbreak_idfSiteGroup]
    ON [dbo].[tflOutbreakFiltered]([idfOutbreak] ASC, [idfSiteGroup] ASC);


GO

CREATE TRIGGER [dbo].[TR_tflOutbreakFiltered_A_Update] ON [dbo].[tflOutbreakFiltered]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfOutbreakFiltered))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
