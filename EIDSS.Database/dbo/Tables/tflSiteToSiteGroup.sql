CREATE TABLE [dbo].[tflSiteToSiteGroup] (
    [idfSiteToSiteGroup]   BIGINT           NOT NULL,
    [idfSiteGroup]         BIGINT           NOT NULL,
    [idfsSite]             BIGINT           NOT NULL,
    [strSiteID]            NVARCHAR (100)   NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [tflSiteToSiteGroup_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tflSiteToSiteGroup_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tflSiteToSiteGroup_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [PK__tflSiteT__314ACD1638A8822A] PRIMARY KEY CLUSTERED ([idfSiteToSiteGroup] ASC),
    CONSTRAINT [FK_tflSiteToSiteGroup_tflSiteGroup_idfSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflSiteToSiteGroup_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tflSiteToSiteGroup_tstSite_idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tflSiteToSiteGroup_A_Update] ON [dbo].[tflSiteToSiteGroup]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSiteToSiteGroup))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
