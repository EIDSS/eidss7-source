CREATE TABLE [dbo].[tlbTransferOUT] (
    [idfTransferOut]                BIGINT           NOT NULL,
    [idfsTransferStatus]            BIGINT           NOT NULL,
    [idfSendFromOffice]             BIGINT           NULL,
    [idfSendToOffice]               BIGINT           NULL,
    [idfSendByPerson]               BIGINT           NULL,
    [datSendDate]                   DATETIME         NULL,
    [strNote]                       NVARCHAR (200)   NULL,
    [strBarcode]                    NVARCHAR (200)   NULL,
    [intRowStatus]                  INT              CONSTRAINT [Def_0_2004] DEFAULT ((0)) NOT NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [newid__2007] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [Def_fnSiteID_tlbTransferOUT] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [tlbTransferOUT_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [strReservedAttribute]          NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]            BIGINT           CONSTRAINT [DEF_tlbTransferOUT_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [TestRequested]                 NVARCHAR (200)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tlbTransferOUT_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    CONSTRAINT [XPKtlbTransferOUT] PRIMARY KEY CLUSTERED ([idfTransferOut] ASC),
    CONSTRAINT [FK_tlbTransferOUT_tlbOffice__idfSendFromOffice_R_1516] FOREIGN KEY ([idfSendFromOffice]) REFERENCES [dbo].[tlbOffice] ([idfOffice]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbTransferOUT_tlbOffice__idfSendToOffice_R_1517] FOREIGN KEY ([idfSendToOffice]) REFERENCES [dbo].[tlbOffice] ([idfOffice]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbTransferOUT_tlbPerson__idfSendByPerson_R_1518] FOREIGN KEY ([idfSendByPerson]) REFERENCES [dbo].[tlbPerson] ([idfPerson]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbTransferOUT_trtBaseReference__idfsTransferStatus_R_1671] FOREIGN KEY ([idfsTransferStatus]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbTransferOUT_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbTransferOUT_tstSite__idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlbTransferOUT_strBarcode_Unique]
    ON [dbo].[tlbTransferOUT]([strBarcode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbTransferOUT_idfSendFromOffice]
    ON [dbo].[tlbTransferOUT]([idfSendFromOffice] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbTransferOUT_idfSentToOffice]
    ON [dbo].[tlbTransferOUT]([idfSendToOffice] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbTransferOUT_intRowStatus]
    ON [dbo].[tlbTransferOUT]([intRowStatus] ASC);


GO

CREATE TRIGGER [dbo].[TR_tlbTransferOut_Insert_DF] 
   ON  [dbo].[tlbTransferOUT]
   for INSERT
   NOT FOR REPLICATION
AS 
BEGIN
	SET NOCOUNT ON;

	declare @guid uniqueidentifier = newid()
	declare @strTableName nvarchar(128) = N'tlbTransferOUT' + cast(@guid as nvarchar(36)) collate Cyrillic_General_CI_AS

	insert into [dbo].[tflNewID] 
		(
			[strTableName], 
			[idfKey1], 
			[idfKey2]
		)
	select  
			@strTableName, 
			ins.[idfTransferOut], 
			sg.[idfSiteGroup]
	from  inserted as ins
		inner join [dbo].[tflSiteToSiteGroup] as stsg with(nolock)
		on   stsg.[idfsSite] = ins.[idfsSite]
		
		inner join [dbo].[tflSiteGroup] sg with(nolock)
		on	sg.[idfSiteGroup] = stsg.[idfSiteGroup]
			and sg.[idfsRayon] is null
			and sg.[idfsCentralSite] is null
			and sg.[intRowStatus] = 0
			
		left join [dbo].[tflTransferOutFiltered] as cf
		on  cf.[idfTransferOut] = ins.[idfTransferOut]
			and cf.[idfSiteGroup] = sg.[idfSiteGroup]
	where  cf.[idfTransferOutFiltered] is null

	insert into [dbo].[tflTransferOutFiltered]
		(
			[idfTransferOutFiltered], 
			[idfTransferOut], 
			[idfSiteGroup]
		)
	select 
			nID.[NewID], 
			ins.[idfTransferOut], 
			nID.[idfKey2]
	from  inserted as ins
		inner join [dbo].[tflNewID] as nID
		on  nID.[strTableName] = @strTableName collate Cyrillic_General_CI_AS
			and nID.[idfKey1] = ins.[idfTransferOut]
			and nID.[idfKey2] is not null
		left join [dbo].[tflTransferOutFiltered] as cf
		on   cf.[idfTransferOutFiltered] = nID.[NewID]
	where  cf.[idfTransferOutFiltered] is null

	SET NOCOUNT OFF;
END				
GO


CREATE TRIGGER [dbo].[TR_tlbTransferOUT_I_Delete] on [dbo].[tlbTransferOUT]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfTransferOut]) as
		(
			SELECT [idfTransferOut] FROM deleted
			EXCEPT
			SELECT [idfTransferOut] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			datModificationForArchiveDate = GETDATE()
		FROM dbo.tlbTransferOUT as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfTransferOut = b.idfTransferOut;

	END

END

GO

CREATE TRIGGER [dbo].[TR_tlbTransferOUT_A_Update] ON [dbo].[tlbTransferOUT]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1)
	BEGIN
		IF UPDATE(idfTransferOut)
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

		ELSE
		BEGIN

			UPDATE a
			SET datModificationForArchiveDate = GETDATE()
			FROM dbo.tlbTransferOUT AS a 
			INNER JOIN inserted AS b ON a.idfTransferOut = b.idfTransferOut

		END
	
	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Container transfers out (to another lab/site)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Transfer out identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT', @level2type = N'COLUMN', @level2name = N'idfTransferOut';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Transfer out of office identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT', @level2type = N'COLUMN', @level2name = N'idfSendFromOffice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Transfer out to office identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT', @level2type = N'COLUMN', @level2name = N'idfSendToOffice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Person sent by identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT', @level2type = N'COLUMN', @level2name = N'idfSendByPerson';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Date sent', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT', @level2type = N'COLUMN', @level2name = N'datSendDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Comment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbTransferOUT', @level2type = N'COLUMN', @level2name = N'strNote';

