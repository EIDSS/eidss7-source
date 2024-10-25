CREATE TABLE [dbo].[EventSubscription] (
    [EventNameID]          BIGINT           NOT NULL,
    [ReceiveAlertFlag]     BIT              NOT NULL,
    [AlertRecipient]       NVARCHAR (100)   NULL,
    [intRowStatus]         INT              CONSTRAINT [Def_EventSubscription_intRowStatus] DEFAULT ((0)) NOT NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [DF_EventSubscription_RowGUID] DEFAULT (newsequentialid()) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   CONSTRAINT [DF_EventSubscription_CreateUser] DEFAULT (user_name()) NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_EventSubscription_CreateDTM] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]      VARCHAR (200)    CONSTRAINT [DF_EventSubscription_UpdateUser] DEFAULT (user_name()) NULL,
    [AuditUpdateDTM]       DATETIME         CONSTRAINT [DF_EventSubscription_UpdateDTM] DEFAULT (getdate()) NOT NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [idfUserID]            BIGINT           NOT NULL,
    CONSTRAINT [XPKEventSubscription] PRIMARY KEY CLUSTERED ([EventNameID] ASC, [idfUserID] ASC),
    CONSTRAINT [FK_EventSubscription_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_EventSubscription_trtEventType_EventNameID] FOREIGN KEY ([EventNameID]) REFERENCES [dbo].[trtEventType] ([idfsEventTypeID]),
    CONSTRAINT [FK_EventSubscription_tstUserTable] FOREIGN KEY ([idfUserID]) REFERENCES [dbo].[tstUserTable] ([idfUserID])
);

