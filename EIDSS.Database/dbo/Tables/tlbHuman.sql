CREATE TABLE [dbo].[tlbHuman] (
    [idfHuman]                      BIGINT           NOT NULL,
    [idfHumanActual]                BIGINT           NULL,
    [idfsOccupationType]            BIGINT           NULL,
    [idfsNationality]               BIGINT           NULL,
    [idfsHumanGender]               BIGINT           NULL,
    [idfCurrentResidenceAddress]    BIGINT           NULL,
    [idfEmployerAddress]            BIGINT           NULL,
    [idfRegistrationAddress]        BIGINT           NULL,
    [datDateofBirth]                DATETIME         NULL,
    [datDateOfDeath]                DATETIME         NULL,
    [strLastName]                   NVARCHAR (200)   NOT NULL,
    [strSecondName]                 NVARCHAR (200)   NULL,
    [strFirstName]                  NVARCHAR (200)   NULL,
    [strRegistrationPhone]          NVARCHAR (200)   NULL,
    [strEmployerName]               NVARCHAR (200)   NULL,
    [strHomePhone]                  NVARCHAR (200)   NULL,
    [strWorkPhone]                  NVARCHAR (200)   NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [newid__1989] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [intRowStatus]                  INT              CONSTRAINT [tlbHuman_intRowStatus] DEFAULT ((0)) NOT NULL,
    [idfsPersonIDType]              BIGINT           NULL,
    [strPersonID]                   NVARCHAR (100)   NULL,
    [blnPermantentAddressAsCurrent] BIT              NULL,
    [datEnteredDate]                DATETIME         CONSTRAINT [tlbHuman_datEnteredDate] DEFAULT (getdate()) NULL,
    [datModificationDate]           DATETIME         CONSTRAINT [tlbHuman_datModificationDate] DEFAULT (getdate()) NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [tlbHuman_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [strReservedAttribute]          NVARCHAR (MAX)   NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [DF__tlbHuman__idfsSi__5D05DE31] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [idfMonitoringSession]          BIGINT           NULL,
    [SourceSystemNameID]            BIGINT           CONSTRAINT [DEF_tlbHuman_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tlbHuman_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    CONSTRAINT [XPKtlbHuman] PRIMARY KEY CLUSTERED ([idfHuman] ASC),
    CONSTRAINT [FK_tlbHuman_tlbGeoLocation__idfCurrentResidenceAddress_R_1424] FOREIGN KEY ([idfCurrentResidenceAddress]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_tlbGeoLocation__idfEmployerAddress_R_1425] FOREIGN KEY ([idfEmployerAddress]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_tlbGeoLocation__idfRegistrationAddress_R_1426] FOREIGN KEY ([idfRegistrationAddress]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_tlbHumanActual] FOREIGN KEY ([idfHumanActual]) REFERENCES [dbo].[tlbHumanActual] ([idfHumanActual]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_tlbMonitoringSession_MontoringSessionID] FOREIGN KEY ([idfMonitoringSession]) REFERENCES [dbo].[tlbMonitoringSession] ([idfMonitoringSession]),
    CONSTRAINT [FK_tlbHuman_trtBaseReference__idfsHumanGender_R_1232] FOREIGN KEY ([idfsHumanGender]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_trtBaseReference__idfsNationality_R_1278] FOREIGN KEY ([idfsNationality]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_trtBaseReference__idfsOccupationType_R_1233] FOREIGN KEY ([idfsOccupationType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_trtBaseReference_idfsPersonIDType] FOREIGN KEY ([idfsPersonIDType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbHuman_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbHuman_tstSite__idfsSite] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO
CREATE NONCLUSTERED INDEX [IX_tlbHuman_H]
    ON [dbo].[tlbHuman]([idfHuman] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbHuman_HumanActual]
    ON [dbo].[tlbHuman]([idfHumanActual] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbHuman_intRowStatus]
    ON [dbo].[tlbHuman]([idfCurrentResidenceAddress] ASC, [intRowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbHuman_intRowStatus_idfCurrentAddress]
    ON [dbo].[tlbHuman]([intRowStatus] ASC)
    INCLUDE([idfCurrentResidenceAddress], [strLastName], [strSecondName], [strFirstName]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Human/Patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Human identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfHuman';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Occupation type identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfsOccupationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nationality identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfsNationality';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Human gender identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfsHumanGender';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Current residence address identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfCurrentResidenceAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Employer address identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfEmployerAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Registration address identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'idfRegistrationAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Date of birth', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'datDateofBirth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Date of death', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'datDateOfDeath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Last name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strLastName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Middle name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strSecondName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'First name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strFirstName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Registration phone number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strRegistrationPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Employer''s Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strEmployerName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Home phone number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strHomePhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Work phone number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbHuman', @level2type = N'COLUMN', @level2name = N'strWorkPhone';

