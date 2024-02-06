CREATE TABLE [dbo].[HumanActualAddlInfo] (
    [HumanActualAddlInfoUID]           BIGINT           NOT NULL,
    [EIDSSPersonID]                    VARCHAR (200)    NOT NULL,
    [ReportedAge]                      INT              NULL,
    [ReportedAgeUOMID]                 BIGINT           NULL,
    [ReportedAgeDTM]                   DATETIME         NULL,
    [PassportNbr]                      VARCHAR (20)     NULL,
    [IsEmployedID]                     BIGINT           NULL,
    [EmployerPhoneNbr]                 VARCHAR (200)    NULL,
    [EmployedDTM]                      DATETIME         NULL,
    [IsStudentID]                      BIGINT           NULL,
    [SchoolName]                       NVARCHAR (200)    NULL,
    [SchoolPhoneNbr]                   VARCHAR (200)    NULL,
    [SchoolAddressID]                  BIGINT           NULL,
    [SchoolLastAttendDTM]              DATETIME         NULL,
    [ContactPhoneCountryCode]          INT              NULL,
    [ContactPhoneNbr]                  VARCHAR (200)    NULL,
    [ContactPhoneNbrTypeID]            BIGINT           NULL,
    [ContactPhone2CountryCode]         INT              NULL,
    [ContactPhone2Nbr]                 VARCHAR (200)    NULL,
    [ContactPhone2NbrTypeID]           BIGINT           NULL,
    [AltAddressID]                     BIGINT           NULL,
    [intRowStatus]                     INT              CONSTRAINT [Def_HumanActualAddlInfo_intRowStatus] DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]                  NVARCHAR (100)   NULL,
    [AuditCreateDTM]                   DATETIME         NULL,
    [AuditUpdateUser]                  NVARCHAR (100)   NULL,
    [AuditUpdateDTM]                   DATETIME         NULL,
    [rowguid]                          UNIQUEIDENTIFIER CONSTRAINT [DF_HumanActualAddlInfo_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]               BIGINT           CONSTRAINT [DEF_HumanActualAddlInfo_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]             NVARCHAR (MAX)   NULL,
    [DeduplicationResultHumanActualID] BIGINT           NULL,
    CONSTRAINT [XPKHuamnActualAddlInfo] PRIMARY KEY CLUSTERED ([HumanActualAddlInfoUID] ASC),
    CONSTRAINT [FK_HumanActualAddlInfo_Human_UID] FOREIGN KEY ([HumanActualAddlInfoUID]) REFERENCES [dbo].[tlbHumanActual] ([idfHumanActual]),
    CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_AgeUOM] FOREIGN KEY ([ReportedAgeUOMID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_ContactPhone2NbrType] FOREIGN KEY ([ContactPhone2NbrTypeID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_ContactPhoneNbrType] FOREIGN KEY ([ContactPhoneNbrTypeID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanActualAddlInfo_BaseRef_IsEmployed] FOREIGN KEY ([IsEmployedID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanActualAddlInfo_tlbHUmanActual_idfHumanActual] FOREIGN KEY ([DeduplicationResultHumanActualID]) REFERENCES [dbo].[tlbHumanActual] ([idfHumanActual]),
    CONSTRAINT [FK_HumanActualAddlInfo_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanActulaAddlIfo_BaseRef_IsSchool] FOREIGN KEY ([IsStudentID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanActulaAddlIfo_GeoLocationShared_AtlAddressID] FOREIGN KEY ([AltAddressID]) REFERENCES [dbo].[tlbGeoLocationShared] ([idfGeoLocationShared]),
    CONSTRAINT [FK_HumanActulaAddlIfo_GeosharedaddressID] FOREIGN KEY ([SchoolAddressID]) REFERENCES [dbo].[tlbGeoLocationShared] ([idfGeoLocationShared])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UNIQ_HumanActualAddlInfo_EIDSSPersonID]
    ON [dbo].[HumanActualAddlInfo]([EIDSSPersonID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HumanActualAddlInfo_intRowStatus]
    ON [dbo].[HumanActualAddlInfo]([intRowStatus] ASC)
    INCLUDE([EIDSSPersonID], [ReportedAge], [PassportNbr], [ContactPhoneCountryCode], [ContactPhoneNbr]);


GO

CREATE TRIGGER [dbo].[TR_HumanActualAddlInfo_A_Update] ON [dbo].[HumanActualAddlInfo]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(HumanActualAddlInfoUID))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_HumanActualAddlInfo_I_Delete] on [dbo].[HumanActualAddlInfo]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([HumanActualAddlInfoUID]) as
		(
			SELECT [HumanActualAddlInfoUID] FROM deleted
			EXCEPT
			SELECT [HumanActualAddlInfoUID] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.HumanActualAddlInfo as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[HumanActualAddlInfoUID] = b.[HumanActualAddlInfoUID];

	END

END
