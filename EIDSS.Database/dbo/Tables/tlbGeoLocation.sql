CREATE TABLE [dbo].[tlbGeoLocation] (
    [idfGeoLocation]                BIGINT           NOT NULL,
    [idfsResidentType]              BIGINT           NULL,
    [idfsGroundType]                BIGINT           NULL,
    [idfsGeoLocationType]           BIGINT           NULL,
    [idfsCountry]                   BIGINT           NULL,
    [idfsRegion]                    BIGINT           NULL,
    [idfsRayon]                     BIGINT           NULL,
    [idfsSettlement]                BIGINT           NULL,
    [idfsSite]                      BIGINT           CONSTRAINT [Def_fnSiteID_tlbGeoLocation] DEFAULT ([dbo].[fnSiteID]()) NOT NULL,
    [strPostCode]                   NVARCHAR (200)   NULL,
    [strStreetName]                 NVARCHAR (200)   NULL,
    [strHouse]                      NVARCHAR (200)   NULL,
    [strBuilding]                   NVARCHAR (200)   NULL,
    [strApartment]                  NVARCHAR (200)   NULL,
    [strDescription]                NVARCHAR (200)   NULL,
    [dblDistance]                   FLOAT (53)       NULL,
    [dblLatitude]                   FLOAT (53)       NULL,
    [dblLongitude]                  FLOAT (53)       NULL,
    [dblAccuracy]                   FLOAT (53)       NULL,
    [dblAlignment]                  FLOAT (53)       NULL,
    [intRowStatus]                  INT              CONSTRAINT [Def_0_2056] DEFAULT ((0)) NOT NULL,
    [rowguid]                       UNIQUEIDENTIFIER CONSTRAINT [newid__2058] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [blnForeignAddress]             BIT              CONSTRAINT [DF__tlbGeoLoc__blnFo__35A8EC92] DEFAULT ((0)) NOT NULL,
    [strForeignAddress]             NVARCHAR (200)   NULL,
    [strAddressString]              NVARCHAR (1000)  NULL,
    [strShortAddressString]         NVARCHAR (2000)  NULL,
    [datModificationForArchiveDate] DATETIME         CONSTRAINT [tlbGeoLocation_datModificationForArchiveDate] DEFAULT (getdate()) NULL,
    [strMaintenanceFlag]            NVARCHAR (20)    NULL,
    [strReservedAttribute]          NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]            BIGINT           CONSTRAINT [DEF_tlbGeoLocation_SourceSystemNameID] DEFAULT ((10519001)) NULL,
    [SourceSystemKeyValue]          NVARCHAR (MAX)   NULL,
    [AuditCreateUser]               NVARCHAR (200)   NULL,
    [AuditCreateDTM]                DATETIME         CONSTRAINT [DF_tlbGeoLocation_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]               NVARCHAR (200)   NULL,
    [AuditUpdateDTM]                DATETIME         NULL,
    [dblElevation]                  FLOAT (53)       NULL,
    [idfsLocation]                  BIGINT           NULL,
    CONSTRAINT [XPKtlbGeoLocation] PRIMARY KEY CLUSTERED ([idfGeoLocation] ASC),
    CONSTRAINT [FK_tlbGeoLocation_gisCountry__idfsCountry_R_972] FOREIGN KEY ([idfsCountry]) REFERENCES [dbo].[gisCountry] ([idfsCountry]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_gisLocation_idfsLocation] FOREIGN KEY ([idfsLocation]) REFERENCES [dbo].[gisLocation] ([idfsLocation]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_gisRayon__idfsRayon_R_974] FOREIGN KEY ([idfsRayon]) REFERENCES [dbo].[gisRayon] ([idfsRayon]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_gisRegion__idfsRegion_R_973] FOREIGN KEY ([idfsRegion]) REFERENCES [dbo].[gisRegion] ([idfsRegion]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_gisSettlement__idfsSettlement_R_1218] FOREIGN KEY ([idfsSettlement]) REFERENCES [dbo].[gisSettlement] ([idfsSettlement]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_trtBaseReference__idfsGeoLocationType_R_1238] FOREIGN KEY ([idfsGeoLocationType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_trtBaseReference__idfsGroundType_R_1239] FOREIGN KEY ([idfsGroundType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_trtBaseReference__idfsResidentType_R_1277] FOREIGN KEY ([idfsResidentType]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tlbGeoLocation_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference]),
    CONSTRAINT [FK_tlbGeoLocation_tstSite__idfsSite_R_1028] FOREIGN KEY ([idfsSite]) REFERENCES [dbo].[tstSite] ([idfsSite]) NOT FOR REPLICATION
);


GO
CREATE NONCLUSTERED INDEX [IX_tlbGeoLocation_idfsRegion]
    ON [dbo].[tlbGeoLocation]([intRowStatus] ASC, [idfsRegion] ASC)
    INCLUDE([idfGeoLocation]);


GO
CREATE NONCLUSTERED INDEX [IX_tlbGeoLocation_idfsRayon]
    ON [dbo].[tlbGeoLocation]([idfsRayon] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbGeoLocation_idfsSettlement]
    ON [dbo].[tlbGeoLocation]([idfsSettlement] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tlbGeoLocation_intRowStatus_idfsLocation]
    ON [dbo].[tlbGeoLocation]([intRowStatus] ASC, [idfsLocation] ASC);


GO

CREATE TRIGGER [dbo].[TR_tlbGeoLocation_A_Insert] ON [dbo].[tlbGeoLocation]	
FOR INSERT
as
DECLARE @okToUpdate BIT = 0
IF EXISTS
	(
	SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM deleted
	EXCEPT
	SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM inserted
)
SET @okToUpdate = 1
IF ((TRIGGER_NESTLEVEL()<2) AND (dbo.FN_GBL_TriggersWork()=1)) AND @okToUpdate = 1
BEGIN
	
	UPDATE tgl
	SET	
		tgl.strAddressString = dbo.FN_GBL_GeoLocationString('en-US', i.idfGeoLocation, i.idfsGeoLocationType),
		tgl.strShortAddressString = dbo.FN_GBL_GeoLocationShortAddressString('en-US', i.idfGeoLocation, i.idfsGeoLocationType)
	FROM dbo.tlbGeoLocation AS tgl 
	JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation

	WHERE ISNULL(tgl.strAddressString, '') <> dbo.FN_GBL_GeoLocationString('en-US', i.idfGeoLocation, i.idfsGeoLocationType)
	OR ISNULL(tgl.strShortAddressString, '') <> dbo.FN_GBL_GeoLocationShortAddressString('en-US', i.idfGeoLocation, i.idfsGeoLocationType)
	
	
	INSERT INTO dbo.tlbGeoLocationTranslation
	(idfGeoLocation, idfsLanguage, strTextString, strShortAddressString)
	SELECT
		tgl.idfGeoLocation,
		tltc.idfsLanguage,
		dbo.FN_GBL_GeoLocationString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strTextString,
		dbo.FN_GBL_GeoLocationShortAddressString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strShortAddressString
	FROM dbo.tlbGeoLocation AS tgl 
	JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation
	CROSS JOIN trtLanguageToCP tltc	JOIN trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0
	LEFT JOIN tlbGeoLocationTranslation tglt ON	tglt.idfGeoLocation = tgl.idfGeoLocation AND tglt.idfsLanguage = tltc.idfsLanguage
	JOIN tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = tltc.idfCustomizationPackage
	
	WHERE tcp1.idfsCountry = dbo.FN_GBL_CustomizationCountry()
	AND tglt.idfGeoLocation IS NULL

END


SET ANSI_NULLS ON

GO


CREATE TRIGGER [dbo].[TR_tlbGeoLocation_I_Delete] on [dbo].[tlbGeoLocation]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfGeoLocation]) as
		(
			SELECT [idfGeoLocation] FROM deleted
			EXCEPT
			SELECT [idfGeoLocation] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1, 
			datModificationForArchiveDate = getdate()
		FROM dbo.tlbGeoLocation as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfGeoLocation = b.idfGeoLocation;

	END

END

GO


CREATE TRIGGER [dbo].[TR_tlbGeoLocation_A_Update] ON [dbo].[tlbGeoLocation]
FOR UPDATE
NOT FOR REPLICATION
AS

BEGIN
	DECLARE @okToUpdate BIT = 0
	IF EXISTS
	 (
		SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM deleted
		EXCEPT
		SELECT idfGeoLocation, idfsResidentType, idfsGroundType, idfsGeoLocationType, idfsCountry, idfsRegion, idfsRayon, idfsSettlement, strPostCode, strStreetName, strHouse, strBuilding, strApartment, strDescription, dblDistance, dblLatitude, dblLongitude, dblAccuracy, dblAlignment, blnForeignAddress, strForeignAddress, strShortAddressString FROM inserted
	)
	SET @okToUpdate = 1

	IF(dbo.FN_GBL_TriggersWork ()=1) AND @okToUpdate = 1
	BEGIN
		IF(UPDATE(idfGeoLocation))
		BEGIN
			RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
			ROLLBACK TRANSACTION
		END

	ELSE IF @okToUpdate = 1
		BEGIN
				UPDATE tgl
				SET	strAddressString = dbo.FN_GBL_GeoLocationString('en-US', i.idfGeoLocation, i.idfsGeoLocationType),
					tgl.strShortAddressString = dbo.FN_GBL_GeoLocationShortAddressString('en-US', i.idfGeoLocation, i.idfsGeoLocationType)
				FROM dbo.tlbGeoLocation AS tgl 
				JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation
				WHERE ISNULL(tgl.strAddressString, '') <> dbo.FN_GBL_GeoLocationString('en-US', i.idfGeoLocation, i.idfsGeoLocationType)
				OR ISNULL(tgl.strShortAddressString, '') <> dbo.FN_GBL_GeoLocationShortAddressString('en-US', i.idfGeoLocation, i.idfsGeoLocationType)
	
				MERGE dbo.tlbGeoLocationTranslation AS [target]
				USING (				
						SELECT
							tgl.idfGeoLocation,
							tltc.idfsLanguage,
							dbo.FN_GBL_GeoLocationString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strTextString,
							dbo.FN_GBL_GeoLocationShortAddressString(tbr.strBaseReferenceCode, i.idfGeoLocation, i.idfsGeoLocationType) AS strShortAddressString
						FROM dbo.tlbGeoLocation AS tgl 
						JOIN inserted AS i ON tgl.idfGeoLocation = i.idfGeoLocation
						CROSS JOIN dbo.trtLanguageToCP tltc	JOIN trtBaseReference tbr ON tbr.idfsBaseReference = tltc.idfsLanguage AND tbr.intRowStatus = 0
						JOIN dbo.tstCustomizationPackage tcp1 ON tcp1.idfCustomizationPackage = tltc.idfCustomizationPackage
						WHERE tcp1.idfsCountry = dbo.FN_GBL_CustomizationCountry()
					) AS [source]
				ON ([target].idfGeoLocation = [source].idfGeoLocation AND [target].idfsLanguage = [source].idfsLanguage)
				WHEN MATCHED AND (
									ISNULL([target].strTextString, '') <> ISNULL([source].strTextString, '')
									OR ISNULL([target].strShortAddressString, '') <> ISNULL([source].strShortAddressString, '')
								)
				THEN UPDATE 
					 SET strTextString = [source].strTextString,
						 strShortAddressString = [source].strShortAddressString;
		END
	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Address/Geo Location', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Geo location/address identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfGeoLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Residence type identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsResidentType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Landscape type identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsGroundType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Geo location/address type identifier (exact point/relative point/address)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsGeoLocationType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Country identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Region identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsRegion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Rayon identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsRayon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Settlement identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Site identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'idfsSite';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Postal code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'strPostCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Street name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'strStreetName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'House number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'strHouse';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Building number', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'strBuilding';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Geo location description', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'strDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Distance from settlement (used in relative point)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'dblDistance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Latitude', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'dblLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Longitude', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'dblLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Accuracy', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'dblAccuracy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Alignment (used in relative point)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tlbGeoLocation', @level2type = N'COLUMN', @level2name = N'dblAlignment';

