CREATE TABLE [dbo].[tflVectorSurveillanceSessionFiltered] (
    [idfVectorSurveillanceSessionFiltered] BIGINT           NOT NULL,
    [idfVectorSurveillanceSession]         BIGINT           NOT NULL,
    [idfSiteGroup]                         BIGINT           NOT NULL,
    [rowguid]                              UNIQUEIDENTIFIER CONSTRAINT [newid__tflVectorSurveillanceSessionFiltered] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]                   BIGINT           CONSTRAINT [DEF_tflVectorSurveillanceSessionFiltered_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]                 NVARCHAR (MAX)   NULL,
    [AuditCreateUser]                      NVARCHAR (200)   NULL,
    [AuditCreateDTM]                       DATETIME         CONSTRAINT [DF_tflVectorSurveillanceSessionFiltered_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]                      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                       DATETIME         NULL,
    CONSTRAINT [XPKtflVectorSurveillanceSessionFiltered] PRIMARY KEY CLUSTERED ([idfVectorSurveillanceSessionFiltered] ASC),
    CONSTRAINT [FK_tflVectorSurveillanceSessionFiltered_tflSiteGroup__idfSiteGroup] FOREIGN KEY ([idfSiteGroup]) REFERENCES [dbo].[tflSiteGroup] ([idfSiteGroup]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflVectorSurveillanceSessionFiltered_tlbVectorSurveillanceSession__idfVectorSurveillanceSession] FOREIGN KEY ([idfVectorSurveillanceSession]) REFERENCES [dbo].[tlbVectorSurveillanceSession] ([idfVectorSurveillanceSession]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tflVectorSurveillanceSessionFiltered_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [tflVectorSurveillanceSessionFiltered_idfVectorSurveillanceSession_idfSiteGroup]
    ON [dbo].[tflVectorSurveillanceSessionFiltered]([idfVectorSurveillanceSession] ASC, [idfSiteGroup] ASC);


GO

CREATE TRIGGER [dbo].[TR_tflVectorSurveillanceSessionFiltered_A_Update] ON [dbo].[tflVectorSurveillanceSessionFiltered]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfVectorSurveillanceSessionFiltered))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
