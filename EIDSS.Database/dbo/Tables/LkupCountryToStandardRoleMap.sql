CREATE TABLE [dbo].[LkupCountryToStandardRoleMap] (
    [CountryToStandardRoleUID] BIGINT           NOT NULL,
    [CountryID]                BIGINT           NOT NULL,
    [CountryRoleName]          NVARCHAR (MAX)   NOT NULL,
    [StandardRoleID]           BIGINT           NOT NULL,
    [intRowStatus]             INT              DEFAULT ((0)) NOT NULL,
    [rowguid]                  UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [strMaintenanceFlag]       NVARCHAR (20)    NULL,
    [strReservedAttribute]     NVARCHAR (MAX)   NULL,
    [AuditCreateUser]          NVARCHAR (200)   DEFAULT ('SYSTEM') NULL,
    [AuditCreateDTM]           DATETIME         DEFAULT (getdate()) NOT NULL,
    [AuditUpdateUser]          NVARCHAR (200)   NULL,
    [AuditUpdateDTM]           DATETIME         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [XPKCountryRoleToStandardRoleMap] PRIMARY KEY CLUSTERED ([CountryToStandardRoleUID] ASC),
    CONSTRAINT [FK_CountryRoleToStandardRoleMap_gidCountry_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[gisCountry] ([idfsCountry]),
    CONSTRAINT [FK_CountryRoleToStandardRoleMap_trtBaseReference_StadardRoleID] FOREIGN KEY ([StandardRoleID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);

