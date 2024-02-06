CREATE TABLE [dbo].[gisImportedMapGeometry](
	[idfsGISImportedMapGeometry] [bigint] NOT NULL,
	[idfsGISImportedMap] [bigint] NOT NULL,
	[geomShape] [geometry] NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[intRowStatus] [int] NOT NULL,
	[strMaintenanceFlag] [nvarchar](20) NULL,
	[strReservedAttribute] [nvarchar](max) NULL,
	[SourceSystemNameID] [bigint] NULL,
	[SourceSystemKeyValue] [nvarchar](max) NULL,
	[AuditCreateUser] [nvarchar](200) NULL,
	[AuditCreateDTM] [datetime] NULL,
	[AuditUpdateUser] [nvarchar](200) NULL,
	[AuditUpdateDTM] [datetime] NULL,
 CONSTRAINT [XPKgisImportedMapGeometry] PRIMARY KEY CLUSTERED 
(
	[idfsGISImportedMapGeometry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[gisImportedMapGeometry] ADD  CONSTRAINT [newid__gisImportedMapGeometry]  DEFAULT (newid()) FOR [rowguid]
GO

ALTER TABLE [dbo].[gisImportedMapGeometry] ADD  CONSTRAINT [DF__gisImport__intRo__7F4F0C1C]  DEFAULT ((0)) FOR [intRowStatus]
GO

ALTER TABLE [dbo].[gisImportedMapGeometry] ADD  CONSTRAINT [DF_gisImportedMapGeometry_CreateDTM]  DEFAULT (getdate()) FOR [AuditCreateDTM]
GO