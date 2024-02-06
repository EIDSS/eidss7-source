CREATE TABLE [dbo].[tstEvent] (
    [idfEventID]           BIGINT           NOT NULL,
    [idfsEventTypeID]      BIGINT           NULL,
    [idfObjectID]          BIGINT           NULL,
    [strInformationString] NVARCHAR (MAX)   NULL,
    [strNote]              NVARCHAR (MAX)   NULL,
    [datEventDatatime]     DATETIME         NULL,
    [strClient]            NVARCHAR (50)    NULL,
    [idfUserID]            BIGINT           NULL,
    [intProcessed]         INT              NULL,
    [idfsSite]             BIGINT           NULL,
    [idfsRegion]           BIGINT           NULL,
    [idfsRayon]            BIGINT           NULL,
    [idfsDiagnosis]        BIGINT           NULL,
    [idfsLoginSite]        BIGINT           NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_tstEvent_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tstEvent_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    [idfsLocation]         BIGINT           NULL,
    CONSTRAINT [XPKtstEvent] PRIMARY KEY CLUSTERED ([idfEventID] ASC),
    CONSTRAINT [FK_tstEvent_gisLocation_idfsLocation] FOREIGN KEY ([idfsLocation]) REFERENCES [dbo].[gisLocation] ([idfsLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstEvent_gisRayon__idfsRayon] FOREIGN KEY ([idfsRayon]) REFERENCES [dbo].[gisRayon] ([idfsRayon]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstEvent_gisRegion__idfsRegion] FOREIGN KEY ([idfsRegion]) REFERENCES [dbo].[gisRegion] ([idfsRegion]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstEvent_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tstEvent_trtDiagnosis__idfsDiagnosis] FOREIGN KEY ([idfsDiagnosis]) REFERENCES [dbo].[trtDiagnosis] ([idfsDiagnosis]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstEvent_trtEventType__idfsEventTypeID_R_664] FOREIGN KEY ([idfsEventTypeID]) REFERENCES [dbo].[trtEventType] ([idfsEventTypeID]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstEvent_tstSite__idfsLoginSite] FOREIGN KEY ([idfsLoginSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tstEvent_tstSite__idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);




GO

CREATE TRIGGER [dbo].[TR_tstEvent_A_Update] ON [dbo].[tstEvent]
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1 AND UPDATE([idfEventID]))  -- update to Primary Key is not allowed.
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1);
		ROLLBACK TRANSACTION;
	END

END
