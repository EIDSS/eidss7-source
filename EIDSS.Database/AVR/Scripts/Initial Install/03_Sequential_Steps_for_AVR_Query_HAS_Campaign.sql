-------------------------------------------------------------------
-- Script for Human Active Surveillance Campaign fields
-------------------------------------------------------------------

DECLARE @idfSearchTable BIGINT
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT -- bigint
PRINT '@idfSearchTable'
PRINT @idfSearchTable

-- Step 1. Insert into tasSearchTable
INSERT INTO dbo.tasSearchTable
(
    idfSearchTable,
    strTableName,
    strFrom,
    intTableCount,
    blnPrimary,
    rowguid,
    strPKField,
    strExistenceCondition,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   @idfSearchTable,         -- idfSearchTable - bigint
    N'HAS Campaign',       -- strTableName - nvarchar(200)
    N'  {(}    tlbCampaign AS as_cam{0}  {1}{)}   ',       -- strFrom - nvarchar(max)
    1,         -- intTableCount - int
    0,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'as_cam{0}.idfCampaign',        -- strPKField - varchar(200)
    'as_cam{0}.intRowStatus = 0 AND as_cam{0}.CampainCategoryID=10501001',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- add search table for 'HAS Campaign - Sample Type' (10081322) field, it should generate id 4583090000128
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT -- bigint
PRINT '@idfSearchTable'
PRINT @idfSearchTable

INSERT INTO dbo.tasSearchTable
(
    idfSearchTable,
    strTableName,
    strFrom,
    intTableCount,
    blnPrimary,
    rowguid,
    strPKField,
    strExistenceCondition,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   @idfSearchTable,         -- idfSearchTable - bigint
    N'Campaign Diagnoses',           -- strTableName - nvarchar(200) 
    N'  {(}    tlbCampaignToDiagnosis AS as_cam_to_dg{0}  {1}{)}   ',       -- strFrom - nvarchar(max)
    1,         -- intTableCount - int
    0,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'as_cam_to_dg{0}.idfCampaignToDiagnosis',        -- strPKField - varchar(200)
    'as_cam_to_dg{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- 4583090000128 should be generated from record above, added search table 'Campaign Diagnoses'
INSERT INTO  dbo.tasSearchTableJoinRule
(idfMainSearchTable, idfSearchTable, idfParentSearchTable, strJoinCondition, rowguid, idfUnionSearchTable) VALUES
(4582550000000, @idfSearchTable, 4582550000000, N'ON as_cam_to_dg{0}.idfCampaign= as_cam{0}.idfCampaign AND as_cam_to_dg{0}.intRowStatus = 0 ', NEWID(), 4582550000000)

-- Step 2. Insert into tasSearchObjectToSystemFunction
INSERT INTO dbo.trtSystemFunction
(
    idfsSystemFunction,
    idfsObjectType,
    intNumber,
    rowguid,
    intRowStatus,
    strMaintenanceFlag,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10094505,       -- idfsSystemFunction - bigint
    10060053,    -- idfsObjectType - bigint
    91,    -- intNumber - int
    NEWID(), -- rowguid - uniqueidentifier
    0, -- intRowStatus - int
    NULL,    -- strMaintenanceFlag - nvarchar(20)
    NULL,    -- strReservedAttribute - nvarchar(max)
    10519001,    -- SourceSystemNameID - bigint
    NULL,    -- SourceSystemKeyValue - nvarchar(max)
    NULL,    -- AuditCreateUser - nvarchar(200)
    DEFAULT, -- AuditCreateDTM - datetime
    NULL,    -- AuditUpdateUser - nvarchar(200)
    NULL     -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasSearchObjectToSystemFunction
(
    idfsSearchObject,
    idfsSystemFunction,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10082047,       -- idfsSearchObject - bigint
    10094505,       -- idfsSystemFunction - bigint
    NEWID(), -- rowguid - uniqueidentifier
    NULL,    -- strReservedAttribute - nvarchar(max)
    10519001,    -- SourceSystemNameID - bigint
    NULL,    -- SourceSystemKeyValue - nvarchar(max)
    NULL,    -- AuditCreateUser - nvarchar(200)
    DEFAULT, -- AuditCreateDTM - datetime
    NULL,    -- AuditUpdateUser - nvarchar(200)
    NULL     -- AuditUpdateDTM - datetime
    )

-- Step 3. Insert into tasSearchObjectToSearchObject
INSERT INTO dbo.tasSearchObjectToSearchObject
(
    idfsRelatedSearchObject,
    idfsParentSearchObject,
    rowguid,
    strSubQueryJoinCondition,
    blnUseForSubQuery,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10082047,         -- idfsRelatedSearchObject - bigint
    10082047,         -- idfsParentSearchObject - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    N'v_{6}.[PKField] = v.[PKField]',       -- strSubQueryJoinCondition - nvarchar(2000)
    0,      -- blnUseForSubQuery - bit
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- Step 4. Insert into tasMainTableForObject
INSERT INTO dbo.tasMainTableForObject
(
    idfsSearchObject,
    idfMainSearchTable,
    rowguid,
    idfMandatorySearchTable,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10082047,         -- idfsSearchObject - bigint
    4582550000000,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4582550000000,         -- idfMandatorySearchTable - bigint
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- Step 5. Insert into tasFieldSourceForTable
INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081315,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.strCampaignID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081316,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.strCampaignName',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081317,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.strCampaignAdministrator',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081318,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.idfsCampaignType',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081319,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.idfsCampaignStatus',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081320,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.datCampaignDateStart',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081321,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582550000000,         -- idfSearchTable - bigint
    N'as_cam{0}.datCampaignDateEnd',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

INSERT INTO dbo.tasFieldSourceForTable
(
    idfsSearchField,
    idfUnionSearchTable,
    idfSearchTable,
    strFieldText,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM,
    AuditUpdateUser,
    AuditUpdateDTM
)
VALUES
(   10081322,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    @idfSearchTable,         -- idfSearchTable - bigint, value from execution of line 49
    N'as_cam_to_dg{0}.idfCampaign',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

	GO
