CREATE TABLE [dbo].[tflSiteGroup] (
    [idfSiteGroup]            BIGINT           NOT NULL,
    [idfsRayon]               BIGINT           NULL,
    [strSiteGroupName]        NVARCHAR (40)    NOT NULL,
    [idfsCentralSite]         BIGINT           NULL,
    [intRowStatus]            INT              CONSTRAINT [DF__tflSiteGr__intRo__32EFA8D4] DEFAULT ((0)) NOT NULL,
    [rowguid]                 UNIQUEIDENTIFIER CONSTRAINT [tflSiteGroup_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]      BIGINT           CONSTRAINT [DEF_tflSiteGroup_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]    NVARCHAR (MAX)   NULL,
    [AuditCreateUser]         NVARCHAR (200)   NULL,
    [AuditCreateDTM]          DATETIME         CONSTRAINT [DF_tflSiteGroup_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]         NVARCHAR (200)   NULL,
    [AuditUpdateDTM]          DATETIME         NULL,
    [idfsSiteGroupType]       BIGINT           NULL,
    [strSiteGroupDescription] NVARCHAR (100)   NULL,
    [idfsLocation]            BIGINT           NULL,
    CONSTRAINT [PK__tflSiteG__9ECB252731076062] PRIMARY KEY CLUSTERED ([idfSiteGroup] ASC),
    CONSTRAINT [FK_tflSiteGroup_gisLocation_idfsLocation] FOREIGN KEY ([idfsLocation]) REFERENCES [dbo].[gisLocation] ([idfsLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflSiteGroup_gisRayon_idfsRayon] FOREIGN KEY ([idfsRayon]) REFERENCES [dbo].[gisRayon] ([idfsRayon]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflSiteGroup_trtBaseReference_idfsSiteGroupType] FOREIGN KEY ([idfsSiteGroupType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tflSiteGroup_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tflSiteGroup_tstSite_idfsSite] FOREIGN KEY ([idfsCentralSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO

CREATE TRIGGER [dbo].[TR_tflSiteGroup_A_Update] ON [dbo].[tflSiteGroup]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfSiteGroup))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_tflSiteGroup_I_Delete] on [dbo].[tflSiteGroup]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([idfSiteGroup]) as
		(
			SELECT [idfSiteGroup] FROM deleted
			EXCEPT
			SELECT [idfSiteGroup] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1
		FROM dbo.[tflSiteGroup] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[idfSiteGroup] = b.[idfSiteGroup];

	END

END
