CREATE TABLE [dbo].[tstNotificationActivity] (
    [datLastNotificationActivity] DATETIME         NOT NULL,
    [rowguid]                     UNIQUEIDENTIFIER CONSTRAINT [DF_tstNotificationActivity_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]          BIGINT           NULL,
    [SourceSystemKeyValue]        NVARCHAR (MAX)   NULL,
    [AuditCreateUser]             NVARCHAR (200)   NULL,
    [AuditCreateDTM]              DATETIME         CONSTRAINT [DF_tstNotificationActivity_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]             NVARCHAR (200)   NULL,
    [AuditUpdateDTM]              DATETIME         NULL,
    CONSTRAINT [XPKtstNotificationActivity] PRIMARY KEY CLUSTERED ([datLastNotificationActivity] ASC),
    CONSTRAINT [FK_tstNotificationActivity_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

