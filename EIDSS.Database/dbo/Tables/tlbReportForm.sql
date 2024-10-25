CREATE TABLE [dbo].[tlbReportForm] (
    [idfReportForm]                 BIGINT           NOT NULL,
    [idfsReportFormType]            BIGINT           NOT NULL,
    [idfsAdministrativeUnit]        BIGINT           NOT NULL,
    [idfSentByOffice]               BIGINT           NOT NULL,
    [idfSentByPerson]               BIGINT           NOT NULL,
    [idfEnteredByOffice]            BIGINT           NOT NULL,
    [idfEnteredByPerson]            BIGINT           NOT NULL,
    [datSentByDate]                 DATETIME         NULL,
    [datEnteredByDate]              DATETIME         NULL,
    [datStartDate]                  DATETIME         NULL,
    [datFinishDate]                 DATETIME         NULL,
    [strReportFormID]               NVARCHAR (200)   NOT NULL,
    [intRowStatus]                  INT              CONSTRAINT [DF_tlbReportForm_intRowStatus_Def_0] DEFAULT ((0)) NOT NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [DF_tlbReportForm_newid] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [DF_tlbReportForm_datModificationForArchiveDate] DEFAULT (getdate()) NOT NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [strReservedAttribute]          NVARCHAR (MAX)   NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [DF_tlbReportForm_idfsSite] DEFAULT ([dbo].[FN_GBL_SITEID_GET]()) NOT NULL,
    [SourceSystemNameID]            BIGINT           CONSTRAINT [DF_tlbReportForm_SourceSystemNameID] DEFAULT ((10519001)) NOT NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tlbReportForm_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    [idfsDiagnosis]                 BIGINT           NOT NULL,
    [Total]                         INT              CONSTRAINT [DF_tlbReportForm_Total] DEFAULT ((0)) NOT NULL,
    [Notified]                      INT              NULL,
    [Comments]                      NVARCHAR (256)   NULL,
    CONSTRAINT [XPKtlbReportForm] PRIMARY KEY CLUSTERED ([idfReportForm] ASC),
    CONSTRAINT [FK_tlbReportForm_idfsReportFormType] FOREIGN KEY ([idfsReportFormType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbReportForm_tlbOffice__idfEnteredByOffice] FOREIGN KEY ([idfEnteredByOffice]) REFERENCES [dbo].[tlbOffice] ([idfOffice]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbReportForm_tlbOffice__idfSentByOffice] FOREIGN KEY ([idfSentByOffice]) REFERENCES [dbo].[tlbOffice] ([idfOffice]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbReportForm_tlbPerson__idfEnteredByPerson] FOREIGN KEY ([idfEnteredByPerson]) REFERENCES [dbo].[tlbPerson] ([idfPerson]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbReportForm_tlbPerson__idfSentByPerson] FOREIGN KEY ([idfSentByPerson]) REFERENCES [dbo].[tlbPerson] ([idfPerson]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbReportForm_tstSite_idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO


CREATE TRIGGER [dbo].[TR_tlbReportForm_A_Update] ON [dbo].[tlbReportForm]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfReportForm))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO



CREATE TRIGGER [dbo].[TR_tlbReportForm_I_Delete] ON [dbo].[tlbReportForm]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords(idfReportForm) AS
		(
			SELECT idfReportForm FROM deleted
			EXCEPT
			SELECT idfReportForm FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1
		FROM dbo.tlbReportForm AS a 
		INNER JOIN cteOnlyDeletedRecords AS b ON a.idfReportForm = b.idfReportForm;

	END

END
