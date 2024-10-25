CREATE TABLE [dbo].[tflBatchTestFiltered] (
    [idfBatchTestFiltered] BIGINT           NOT NULL,
    [idfBatchTest]         BIGINT           NOT NULL,
    [idfSiteGroup]         BIGINT           NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [tflBatchTestFiltered_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           CONSTRAINT [DEF_tflBatchTestFiltered_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_tflBatchTestFiltered_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKtflBatchTestFiltered] PRIMARY KEY CLUSTERED ([idfBatchTestFiltered] ASC),
    CONSTRAINT [FK_tflBatchTestFiltered_tflSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflBatchTestFiltered_tlbBatchTest] FOREIGN KEY ([idfBatchTest]) REFERENCES [dbo].[tlbBatchTest] ([idfBatchTest]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflBatchTestFiltered_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [tflBatchTestFiltered_idfBatchTest_idfSiteGroup]
    ON [dbo].[tflBatchTestFiltered]([idfBatchTest] ASC, [idfSiteGroup] ASC);


GO

CREATE TRIGGER [dbo].[TR_tflBatchTestFiltered_A_Update] ON [dbo].[tflBatchTestFiltered]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfBatchTestFiltered))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
