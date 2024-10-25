CREATE TABLE [dbo].[LkupEIDSSMenuToEventType] (
    [EIDSSMenuID]          BIGINT           NOT NULL,
    [EventTypeID]          BIGINT           NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_LkupEIDSSMenuToEventType_intRowStatus] DEFAULT ((0)) NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_LkupEIDSSMenuToEventType_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      VARCHAR (100)    NOT NULL,
    [AuditCreateDTM]       DATETIME         NOT NULL,
    [AuditUpdateUser]      VARCHAR (100)    CONSTRAINT [DF_LkupEIDSSMenuToEventType_AuditUpdateUser] DEFAULT ('SYSTEM') NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF_LkupEIDSSMenuToEventType_AuditUpdateDTM] DEFAULT (getdate()) NULL,
    [Area]                 NVARCHAR (255)   NULL,
    [SubArea]              NVARCHAR (255)   NULL,
    [Controller]           NVARCHAR (255)   NULL,
    [strEditAction]        NVARCHAR (255)   NULL,
    [strEditActionParm]    NVARCHAR (255)   NULL,
    CONSTRAINT [XPKLkupEIDSSMenuToEventType] PRIMARY KEY CLUSTERED ([EIDSSMenuID] ASC, [EventTypeID] ASC),
    CONSTRAINT [FK_LkupEIDSSMenuToEventType_BaseRef_MenuID] FOREIGN KEY ([EIDSSMenuID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_LkupEIDSSMenuToEventType_EventType_idfsEventTypeId] FOREIGN KEY ([EventTypeID]) REFERENCES [dbo].[trtEventType] ([idfsEventTypeID]),
    CONSTRAINT [FK_LkupEIDSSMenuToEventType_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

