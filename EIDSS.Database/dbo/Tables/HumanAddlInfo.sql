﻿CREATE TABLE [dbo].[HumanAddlInfo] (
    [HumanAdditionalInfo]      BIGINT           NOT NULL,
    [ReportedAge]              INT              NULL,
    [ReportedAgeUOMID]         BIGINT           NULL,
    [ReportedAgeDTM]           DATETIME         NULL,
    [PassportNbr]              NVARCHAR (20)    NULL,
    [IsEmployedID]             BIGINT           NULL,
    [EmployerPhoneNbr]         NVARCHAR (200)   NULL,
    [EmployedDTM]              DATETIME         NULL,
    [IsStudentID]              BIGINT           NULL,
    [SchoolName]               NVARCHAR (200)   NULL,
    [SchoolPhoneNbr]           NVARCHAR (200)   NULL,
    [SchoolAddressID]          BIGINT           NULL,
    [SchoolLastAttendDTM]      DATETIME         NULL,
    [ContactPhoneCountryCode]  INT              NULL,
    [ContactPhoneNbr]          NVARCHAR (200)   NULL,
    [ContactPhoneNbrTypeID]    BIGINT           NULL,
    [ContactPhone2CountryCode] INT              NULL,
    [ContactPhone2Nbr]         NVARCHAR (200)   NULL,
    [ContactPhone2NbrTypeID]   BIGINT           NULL,
    [AltAddressID]             BIGINT           NULL,
    [intRowStatus]             INT              CONSTRAINT [Def_HumanAddlInfo_intRowStatus] DEFAULT ((0)) NOT NULL,
    [AuditCreateUser]          NVARCHAR (100)   CONSTRAINT [DF__HumanAddl__Audit__3A8D6B76] DEFAULT (user_name()) NOT NULL,
    [AuditCreateDTM]           DATETIME         CONSTRAINT [DF__HumanAddl__Audit__3B818FAF] DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]          NVARCHAR (200)   CONSTRAINT [DF__HumanAddl__Audit__3C75B3E8] DEFAULT (user_name()) NULL,
    [AuditUpdateDTM]           DATETIME         NULL,
    [rowguid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_HumanAddlInfo_rowguid] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SourceSystemNameID]       BIGINT           CONSTRAINT [DEF_HumanAddlInfo_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]     NVARCHAR (MAX)   NULL,
    [IsAnotherPhoneID]         BIGINT           NULL,
    [IsAnotherAddressID]       BIGINT           NULL,
    CONSTRAINT [XPKHumanAddlInfo] PRIMARY KEY CLUSTERED ([HumanAdditionalInfo] ASC),
    CONSTRAINT [FK_HumanAddlIfo_BaseRef_IsSchool] FOREIGN KEY ([IsStudentID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlIfo_Geo_addressID] FOREIGN KEY ([SchoolAddressID]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_ContactPhoneNbr2Type] FOREIGN KEY ([ContactPhone2NbrTypeID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_ContactPhoneNbrType] FOREIGN KEY ([ContactPhoneNbrTypeID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsEmployed] FOREIGN KEY ([IsEmployedID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsInSchool] FOREIGN KEY ([IsStudentID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_ReportedAgeUOM] FOREIGN KEY ([ReportedAgeUOMID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_GeoLocation_AltAddress] FOREIGN KEY ([AltAddressID]) REFERENCES [dbo].[tlbGeoLocation] ([idfGeoLocation]),
    CONSTRAINT [FK_HumanAddlInfo_Human_idfhuman] FOREIGN KEY ([HumanAdditionalInfo]) REFERENCES [dbo].[tlbHuman] ([idfHuman]),
    CONSTRAINT [FK_HumanAddlInfo_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsAnotherPhone] FOREIGN KEY ([IsAnotherPhoneID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_HumanAddlInfo_BaseRef_IsAnotherAddress] FOREIGN KEY ([IsAnotherAddressID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO

CREATE TRIGGER [dbo].[TR_HumanAddlInfo_A_Update] ON [dbo].[HumanAddlInfo]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(HumanAdditionalInfo))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	END

END

GO


CREATE TRIGGER [dbo].[TR_HumanAddlInfo_I_Delete] on [dbo].[HumanAddlInfo]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRows([HumanAdditionalInfo]) as
		(
			SELECT [HumanAdditionalInfo] FROM deleted
			EXCEPT
			SELECT [HumanAdditionalInfo] FROM inserted
		)

		UPDATE a
		SET intRowStatus = 1,
			AuditUpdateUser = SYSTEM_USER,
			AuditUpdateDTM = GETDATE()
		FROM dbo.HumanAddlInfo as a 
		INNER JOIN cteOnlyDeletedRows as b 
			ON a.[HumanAdditionalInfo] = b.[HumanAdditionalInfo];

	END

END
