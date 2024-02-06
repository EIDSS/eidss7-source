/*
Author:			Mike Kornegay
Date:			12/20/2022
Description:	Check and update resource set 225 (Settlement Details) in support of administrative units.
Note:           -Be sure to wrap your insert statements in "IF NOT EXISTS" in case deploy must be run twice
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

/* 
    resource set 
*/
IF NOT EXISTS (SELECT 1 FROM trtResourceSet WHERE idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSet (idfsResourceSet,strResourceSet, strResourceSetUnique, intRowStatus, rowguid, strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM)
        VALUES (225,N'Settlement Details',N'Settlement Details',0,NEWID(), N'Add', N'EIDSS7 Resource Sets', 10519001, N'[{"idfsResourceSet":225}]', N'System', GETDATE(), N'System', GETDATE())
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSet SET intRowStatus = 0 WHERE idfsResourceSet = 225
    END

/*
    resources for administrative units
*/
IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 47)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (47,N'Country',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":47}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 47
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 56)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (56,N'Default Name',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":56}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 56
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 139)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (139,N'National Name',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":139}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 139
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 249)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (249,N'Settlement Type',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":249}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 249
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 426)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (426,N'Rayon',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":426}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 426
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 428)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (428,N'Region',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":428}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 428
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 943)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (943,N'Administrative Level',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":943}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 943
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 949)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (949,N'Administrative Level 4',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":949}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 949
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 950)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (950,N'Administrative Level 5',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":950}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 950
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 951)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (951,N'Administrative Level 6',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":951}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 951
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 2418)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (2418,N'Latitude',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":2418}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 2418
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 2419)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (2419,N'Longitude',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":2419}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 2419
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 2420)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (2420,N'Elevation',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":2420}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 2420
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 2738)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (2738,N'Administrative Level 6',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":2738}]', N'System', GETDATE(), N'System', GETDATE(),10540004)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 2738
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 2739)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (2739,N'Unique Code',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":2739}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 2739
    END

IF NOT EXISTS (SELECT 1 FROM trtResource WHERE idfsResource = 4594)
    BEGIN
        INSERT INTO dbo.trtResource (idfsResource,strResourceName, intRowStatus, rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,idfsResourceType)
        VALUES (4594,N'Unique Code',0,NEWID(), N'Add', N'EIDSS7 Resources', 10519001, N'[{"idfsResource":4594}]', N'System', GETDATE(), N'System', GETDATE(),10540003)
    END
ELSE    
    BEGIN
        UPDATE dbo.trtResource SET intRowStatus = 0 WHERE idfsResource = 4594
    END

/*
    resource set to resource
*/
IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 47 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,47,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":47}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 47
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 56 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,56,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":56}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 56
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 139 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,139,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":139}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 139
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 249 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,249,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":249}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 249
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 426 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,426,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":47}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 426
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 428 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,428,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":428}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 428
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 943 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,943,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":943}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 943
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 949 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,949,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":949}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 949
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 950 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,950,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":950}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 950
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 951 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,951,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":951}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 951
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 2418 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,2418,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":2418}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 2418
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 2419 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,2419,0,1,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":2419}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 2419
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 2420 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,2420,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":2420}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 2420
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 2738 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,2738,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":2738}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 2738
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 2739 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,2739,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":2739}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 2739
    END

IF NOT EXISTS (SELECT 1 FROM trtResourceSetToResource WHERE idfsResource = 4594 AND idfsResourceSet = 225)
    BEGIN
        INSERT INTO dbo.trtResourceSetToResource (idfsResourceSet,idfsResource,isHidden,isRequired,intRowStatus,rowguid,strMaintenanceFlag,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM,AuditUpdateUser,AuditUpdateDTM,canEdit, idfsReportTextID)
        VALUES (225,4594,0,0,0,NEWID(), N'Add', N'Resource Set To Resource', 10519001, N'[{"idfsResourceSet":225,"idfsResource":4594}]', N'System', GETDATE(), N'System', GETDATE(),1, 0)
    END
ELSE
    BEGIN
        UPDATE dbo.trtResourceSetToResource SET intRowStatus = 0 WHERE idfsResourceSet = 225 AND idfsResource = 4594
    END
