CREATE TABLE [dbo].[SystemPreference] (
    [SystemPreferenceUID]  BIGINT           NOT NULL,
    [PreferenceDetail]     NVARCHAR (MAX)   NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [DF__SystemPreference__intRo__1E7B3CAD] DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]      VARCHAR (100)    CONSTRAINT [DF__SystemPreference__Audit__2063851F] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF__SystemPreference__Audit__2157A958] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    CONSTRAINT [DF__SystemPreference__Audit__224BCD91] DEFAULT (user_name()) NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF__SystemPreference__Audit__233FF1CA] DEFAULT (getdate()) NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF__SystemPreference__rowgu__1F6F60E6] DEFAULT (newid()) NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    CONSTRAINT [XPKSystemPreference] PRIMARY KEY CLUSTERED ([SystemPreferenceUID] ASC),
    CONSTRAINT [FK_SystemPreference_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_SystemPreference_A_Update] ON [dbo].[SystemPreference]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(SystemPreferenceUID))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_SystemPreference_I_Delete] on [dbo].[SystemPreference]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([SystemPreferenceUID]) as
		(
			SELECT [SystemPreferenceUID] FROM deleted
			EXCEPT
			SELECT [SystemPreferenceUID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.[SystemPreference] as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[SystemPreferenceUID] = b.[SystemPreferenceUID];

	END

END
