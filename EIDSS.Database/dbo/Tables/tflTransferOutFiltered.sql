CREATE TABLE [dbo].[tflTransferOutFiltered] (
    [idfTransferOutFiltered] BIGINT           NOT NULL,
    [idfTransferOut]         BIGINT           NOT NULL,
    [idfSiteGroup]           BIGINT           NOT NULL,
    [rowguid]                UNIQUEIDENTIFIER CONSTRAINT [newid__2574] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]     BIGINT           CONSTRAINT [DEF_tflTransferOutFiltered_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]   NVARCHAR (MAX)   NULL,
    [AuditCreateUser]        NVARCHAR (200)   NULL,
    [AuditCreateDTM]         DATETIME         CONSTRAINT [DF_tflTransferOutFiltered_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]        NVARCHAR (200)   NULL,
    [AuditUpdateDTM]         DATETIME         NULL,
    CONSTRAINT [XPKtflTransferOutFiltered] PRIMARY KEY CLUSTERED ([idfTransferOutFiltered] ASC),
    CONSTRAINT [FK_tflTransferOutFiltered_tflSiteGroup__idfSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflTransferOutFiltered_tlbTransferOUT__idfTransferOut_R_1817] FOREIGN KEY ([idfTransferOut]) REFERENCES [dbo].[tlbTransferOUT] ([idfTransferOut]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflTransferOutFiltered_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [tflTransferOutFiltered_idfOutbreak_idfSiteGroup]
    ON [dbo].[tflTransferOutFiltered]([idfTransferOut] ASC, [idfSiteGroup] ASC);


GO

CREATE TRIGGER [dbo].[TR_tflTransferOutFiltered_A_Update] ON [dbo].[tflTransferOutFiltered]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfTransferOutFiltered))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
