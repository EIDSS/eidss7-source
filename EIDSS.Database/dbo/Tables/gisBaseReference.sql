CREATE TABLE [dbo].[gisBaseReference] (
    [idfsGISBaseReference] BIGINT           NOT NULL,
    [idfsGISReferenceType] BIGINT           NOT NULL,
    [strBaseReferenceCode] VARCHAR (36)     NULL,
    [strDefault]           NVARCHAR (200)   NULL,
    [intOrder]             INT              NULL,
    [rowguid]              UNIQUEIDENTIFIER CONSTRAINT [newid__1935] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [intRowStatus]         INT              CONSTRAINT [DF__gisBaseRe__intRo__2819E74A] DEFAULT ((0)) NOT NULL,
    [strMaintenanceFlag]   NVARCHAR (20)    NULL,
    [strReservedAttribute] NVARCHAR (MAX)   NULL,
    [SourceSystemNameID]   BIGINT           NULL,
    [SourceSystemKeyValue] NVARCHAR (MAX)   NULL,
    [AuditCreateUser]      NVARCHAR (200)   NULL,
    [AuditCreateDTM]       DATETIME         CONSTRAINT [DF_gisBaseReference_CreateDTM] DEFAULT (getdate()) NULL,
    [AuditUpdateUser]      NVARCHAR (200)   NULL,
    [AuditUpdateDTM]       DATETIME         NULL,
    CONSTRAINT [XPKgisBaseReference] PRIMARY KEY CLUSTERED ([idfsGISBaseReference] ASC),
    CONSTRAINT [FK_gisBaseReference_gisReferenceType__idfsGISReferenceType_R_1632] FOREIGN KEY ([idfsGISReferenceType]) REFERENCES [dbo].[gisReferenceType] ([idfsGISReferenceType]) NOT FOR REPLICATION,
    CONSTRAINT [FK_gisBaseReference_trtBaseReference_SourceSystemNameID] FOREIGN KEY ([SourceSystemNameID]) REFERENCES [dbo].[trtBaseReference] ([idfsBaseReference])
);


GO
CREATE NONCLUSTERED INDEX [IX_gisBaseReference_RS1]
    ON [dbo].[gisBaseReference]([idfsGISReferenceType] ASC, [intRowStatus] ASC)
    INCLUDE([strDefault], [intOrder]);


GO

CREATE TRIGGER [dbo].[TR_gisBaseReference_A_Update] ON [dbo].[gisBaseReference]
FOR UPDATE
NOT FOR REPLICATION
AS
BEGIN
	IF(dbo.FN_GBL_TriggersWork ()=1 AND UPDATE(idfsGISBaseReference))
	BEGIN
		RAISERROR('Update Trigger: Not allowed to update PK.',16,1)
		ROLLBACK TRANSACTION
	-- If the strDefault column was updated...
	END ELSE IF( UPDATE(strDefault))
	BEGIN
		DECLARE 
			 @idfsGISReferenceType BIGINT
			,@oldlocationName NVARCHAR(255)
			,@updatedLocationName NVARCHAR(255)

		SELECT @idfsGISReferenceType = idfsGISReferenceType, @updatedlocationName = strDefault
		FROM INSERTED

		SELECT @oldlocationName = strDefault 
		FROM DELETED

		-- If the change was to any gisreference type...
		-- This test should ideally be testing if any one of the administrative level names changed...
		-- IF(@idfsGISReferenceTYpe IN( 19000001,19000002,19000003,19000004,AdminLevel5ID, AdminLevel6ID, AdminLevel7ID)
		-- GIS Reference Types for Admin Levels 5 thru 7 have yet to be created...
		IF(@idfsGISReferenceType IN(
			SELECT idfsGisReferenceType
			FROM gisReferenceType rt))
		BEGIN
			-- Update the gisLocationDenormalized table with the updated location name...
			UPDATE ld
			SET 
				 ld.Level1Name = CASE WHEN ld.Level1Name = @oldLocationName THEN @updatedLocationName ELSE Level1Name END
				,ld.Level2Name = CASE WHEN ld.Level2Name = @oldLocationName THEN @updatedLocationName ELSE Level2Name END
				,ld.Level3Name = CASE WHEN ld.Level3Name = @oldLocationName THEN @updatedLocationName ELSE Level3Name END
				,ld.Level4Name = CASE WHEN ld.Level4Name = @oldLocationName THEN @updatedLocationName ELSE Level4Name END
				,ld.Level5Name = CASE WHEN ld.Level5Name = @oldLocationName THEN @updatedLocationName ELSE Level5Name END
				,ld.Level6Name = CASE WHEN ld.Level6Name = @oldLocationName THEN @updatedLocationName ELSE Level6Name END
				,ld.Level7Name = CASE WHEN ld.Level7Name = @oldLocationName THEN @updatedLocationName ELSE Level7Name END
			FROM gisLocationDenormalized ld
			JOIN gisReferenceType rt ON rt.strGISReferenceTypeName = ld.LevelType
			WHERE @oldlocationName IN(Level1Name,Level2Name,Level3Name,Level4Name,Level5Name,Level6Name,Level7Name)
			
		END
	END
END

GO


CREATE TRIGGER [dbo].[TR_gisBaseReference_I_Delete] on [dbo].[gisBaseReference]
INSTEAD OF DELETE
NOT FOR REPLICATION
AS
BEGIN

	IF (dbo.FN_GBL_TriggersWork() = 1)
	BEGIN

		WITH cteOnlyDeletedRecords([idfsGISBaseReference]) as
		(
			SELECT [idfsGISBaseReference] FROM deleted
			EXCEPT
			SELECT [idfsGISBaseReference] FROM inserted
		)
		
		UPDATE a
		SET intRowStatus = 1
		FROM dbo.gisBaseReference as a 
		INNER JOIN cteOnlyDeletedRecords as b 
			ON a.idfsGISBaseReference = b.idfsGISBaseReference;

	END

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Base Reference table for GIS reference values', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gisBaseReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'GIS reference value identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gisBaseReference', @level2type = N'COLUMN', @level2name = N'idfsGISBaseReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'GIS reference type identifier', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gisBaseReference', @level2type = N'COLUMN', @level2name = N'idfsGISReferenceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Legacy string identifier for value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gisBaseReference', @level2type = N'COLUMN', @level2name = N'strBaseReferenceCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Default value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gisBaseReference', @level2type = N'COLUMN', @level2name = N'strDefault';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Order in lists/lookups', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'gisBaseReference', @level2type = N'COLUMN', @level2name = N'intOrder';

