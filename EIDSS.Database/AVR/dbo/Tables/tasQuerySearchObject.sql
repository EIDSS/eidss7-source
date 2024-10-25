CREATE TABLE [dbo].[tasQuerySearchObject] (
    [idfQuerySearchObject]       BIGINT           NOT NULL,
    [idflQuery]                  BIGINT           NOT NULL,
    [idfsSearchObject]           BIGINT           NOT NULL,
    [idfParentQuerySearchObject] BIGINT           NULL,
    [intOrder]                   INT              NOT NULL,
    [idfsReportType]             BIGINT           NULL,
    [strReservedAttribute]       NVARCHAR (MAX)   NULL,
    [rowguid]                    UNIQUEIDENTIFIER CONSTRAINT [DF_tasQuerySearchObject_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]         BIGINT           NULL,
    [SourceSystemKeyValue]       NVARCHAR (MAX)   NULL,
    [AuditCreateUser]            NVARCHAR (200)   NULL,
    [AuditCreateDTM]             DATETIME         CONSTRAINT [DF_tasQuerySearchObject_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]            NVARCHAR (200)   NULL,
    [AuditUpdateDTM]             DATETIME         NULL,
    CONSTRAINT [XPKtasQuerySearchObject] PRIMARY KEY CLUSTERED ([idfQuerySearchObject] ASC),
    CONSTRAINT [FK_tasQuerySearchObject_tasQuery__idflQueryName_R_1327] FOREIGN KEY ([idflQuery]) REFERENCES [dbo].[tasQuery] ([idflQuery]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tasQuerySearchObject_tasQuerySearchObject__idfParentQuerySearchObject_R_1329] FOREIGN KEY ([idfParentQuerySearchObject]) REFERENCES [dbo].[tasQuerySearchObject] ([idfQuerySearchObject]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tasQuerySearchObject_tasSearchObject__idfsSearchObject_R_1328] FOREIGN KEY ([idfsSearchObject]) REFERENCES [dbo].[tasSearchObject] ([idfsSearchObject]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tasQuerySearchObject_trtBaseReference__idfsReportType] FOREIGN KEY ([idfsReportType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tasQuerySearchObject_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_tasQuerySearchObject_A_Update] ON [dbo].[tasQuerySearchObject]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfQuerySearchObject))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
