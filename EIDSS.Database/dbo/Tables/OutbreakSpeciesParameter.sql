CREATE TABLE [dbo].[OutbreakSpeciesParameter] (
    [OutbreakSpeciesParameterUID] BIGINT           NOT NULL,
    [idfOutbreak]                 BIGINT           NOT NULL,
    [OutbreakSpeciesTypeID]       BIGINT           NULL,
    [CaseMonitoringDuration]      INT              NULL,
    [CaseMonitoringFrequency]     INT              NULL,
    [ContactTracingDuration]      INT              NULL,
    [ContactTracingFrequency]     INT              NULL,
    [intRowStatus]                INT              CONSTRAINT [Def_OutbreakSpeciesParameter_intRowStatus] DEFAULT ((0)) NOT NULL,
    [CaseQuestionaireTemplateID]  BIGINT           NULL,
    [CaseMonitoringTemplateID]    BIGINT           NULL,
    [ContactTracingTemplateID]    BIGINT           NULL,
    [AuditCreateUser]             VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]              DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]             VARCHAR (100)    NULL,
    [AuditUpdateDTM]              DATETIME         NULL,
    [rowguid]                     UNIQUEIDENTIFIER CONSTRAINT [DF_OutbreakSpeciesParameter_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]          BIGINT           CONSTRAINT [DEF_OutbreakSpeciesParameter_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]        NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKOutbreakSpeciesParameter] PRIMARY KEY CLUSTERED ([OutbreakSpeciesParameterUID] ASC),
    CONSTRAINT [FK_outbreakSpeciesParameter_tlbOutbreak_OutbreakID] FOREIGN KEY ([idfOutbreak]) REFERENCES [dbo].[tlbOutbreak] ([idfOutbreak]),
    CONSTRAINT [FK_OutbreakSpeciesParameter_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_OutbreakSpeciesParm_FormTemplate_CaseMonitoringTemplateID] FOREIGN KEY ([CaseMonitoringTemplateID]) REFERENCES [dbo].[ffFormTemplate] ([idfsFormTemplate]),
    CONSTRAINT [FK_OutbreakSpeciesParm_FormTemplate_CaseQuestionaireTemplateID] FOREIGN KEY ([CaseQuestionaireTemplateID]) REFERENCES [dbo].[ffFormTemplate] ([idfsFormTemplate]),
    CONSTRAINT [FK_OutbreakSpeciesParm_FormTemplate_ContactTracingTemplateID] FOREIGN KEY ([ContactTracingTemplateID]) REFERENCES [dbo].[ffFormTemplate] ([idfsFormTemplate])
);


GO

CREATE TRIGGER [dbo].[TR_OutbreakSpeciesParameter_I_Delete] on [dbo].[OutbreakSpeciesParameter]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([OutbreakSpeciesParameterUID]) as
		(
			SELECT [OutbreakSpeciesParameterUID] FROM deleted
			EXCEPT
			SELECT [OutbreakSpeciesParameterUID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.OutbreakSpeciesParameter as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[OutbreakSpeciesParameterUID] = b.[OutbreakSpeciesParameterUID];

	END

END

GO


CREATE TRIGGER [dbo].[TR_OutbreakSpeciesParameter_A_Update] on [dbo].[OutbreakSpeciesParameter]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1) AND (UPDATE(OutbreakSpeciesParameterUID))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END
