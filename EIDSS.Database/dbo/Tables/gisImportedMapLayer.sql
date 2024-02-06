CREATE TABLE [dbo].[gisImportedMapLayer](
	[idfImportedMapLayer] [bigint] NOT NULL,
	[idfsImportedMap] [bigint] NOT NULL,
	[strGeoJson] [nvarchar](max) NULL,
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
 CONSTRAINT [XPKgisImportedMapGeoJsonLayer] PRIMARY KEY CLUSTERED 
(
	[idfImportedMapLayer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[gisImportedMapLayer] ADD  DEFAULT ((0)) FOR [intRowStatus]
GO
