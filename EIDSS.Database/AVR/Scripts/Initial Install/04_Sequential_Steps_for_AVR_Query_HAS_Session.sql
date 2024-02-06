-------------------------------------------------------------------
-- Script for Human Active Surveillance Session fields
-------------------------------------------------------------------

DECLARE @idfSearchTable BIGINT
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT -- bigint
PRINT '@idfSearchTable'
PRINT @idfSearchTable

-- Step 1. Insert into tasSearchTable, these values come from tasSearchTable look for similar values to find what you are looking for.
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
    N'HAS Session',           -- strTableName - nvarchar(200) 
    N'  {(}     tlbMonitoringSession asms{0}    {1}{)}   ',       -- strFrom - nvarchar(max)
    1,         -- intTableCount - int
    0,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'asms{0}.idfMonitoringSession',        -- strPKField - varchar(200)
    'asms{0}.intRowStatus = 0 AND asms{0}.SessionCategoryID=10502001',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- create 'HAS Session Actions' search table (record).
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT -- bigint
PRINT '@idfSearchTable'
PRINT @idfSearchTable

-- Add new table 'HAS Session Actions'
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
    N'HAS Session Actions',           -- strTableName - nvarchar(200) 
    N'  {(}    tlbMonitoringSessionAction action{0}   inner join tlbMonitoringSession session{0}     on action{0}.idfMonitoringSession = session{0}.idfMonitoringSession  {1}{)} ',       -- strFrom - nvarchar(max)
    2,         -- intTableCount - int
    0,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'action{0}.idfMonitoringSessionAction',        -- strPKField - varchar(200)
    N'',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- Add join rule for new table 'HAS Session Actions'
INSERT INTO tasSearchTableJoinRule
(
	idfMainSearchTable,
	idfSearchTable,
	idfParentSearchTable,
	strJoinCondition,
	rowguid,
	idfUnionSearchTable
	)
VALUES
(
	4582560000000,		-- idfMainSearchTable
	@idfSearchTable,	-- idfSearchTable
	4582560000000,		-- idfParentSearchTable
	N'ON action{0}.idfMonitoringSession = session{0}.idfMonitoringSession ',	-- strJoinCondition
	NEWID(),			-- rowguid
	4582560000000		-- idfUnionSearchTable
)

-- Adding rec. to tasFieldSourceForTable here because value of @idfSearchTable could change 
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
(   10080870,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    @idfSearchTable,         -- idfSearchTable - bigint, this id is from the newlly created 'HAS Session Actions' table
    N'action{0}.idfMonitoringSessionAction',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- Add table 'Human' search table
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT -- bigint
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
	AuditCreateDTM
)
VALUES
(   @idfSearchTable,       -- idfSearchTable - bigint
    N'Human',     -- strTableName - nvarchar(200)
    '  {(}    tlbHuman th{0}   {1}{)}   ',    -- strFrom - nvarchar(max)
    1,    -- intTableCount - int
    0, -- blnPrimary - bit
    NEWID(), -- rowguid - uniqueidentifier
    'th{0}.idfHuman',      -- strPKField - varchar(200)
    'th{0}.intRowStatus = 0',      -- strExistenceCondition - varchar(200)
    NULL,    -- strReservedAttribute - nvarchar(max)
    10519001,    -- SourceSystemNameID - bigint
    '[{"idfSearchTable":'+ CAST(4582640000000 AS NVARCHAR(100))+ '}]',    -- SourceSystemKeyValue - nvarchar(max)
    'SYSTEM',    -- AuditCreateUser - nvarchar(200)
    DEFAULT -- AuditCreateDTM - datetime
	)
    
-- We need @idfSearchTable value for the search field.
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
(   10080849,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    @idfSearchTable,         -- idfSearchTable - bigint
    N'th{0}.strPersonID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- TODO: check with Mandar update below is changing 'Human Active Surveillance Session Tests' (10082050) not 'Human Active Surveillance Session Persons and Samples' (10082049), checked it should be 10082049
UPDATE dbo.tasSearchObjectToSearchObject SET blnUseForSubQuery = 1,
strSubQueryJoinCondition ='v_{6}.[PKField] = v.[PKField] and v_{6}.[PKField_4582560000000] = v.[PKField_4582560000000] and v_{6}.[PKField_4582950000000] is not null',
SourceSystemNameID = 10519001, SourceSystemKeyValue ='{"idfsRelatedSearchObject":10082050,"idfsParentSearchObject":10082048}'
WHERE idfsParentSearchObject = 10082048 AND idfsRelatedSearchObject = 10082049 

INSERT INTO dbo.tasSearchTableJoinRule
(
    idfMainSearchTable,idfSearchTable,idfParentSearchTable,strJoinCondition,rowguid,idfUnionSearchTable,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM
)
VALUES
(   4582560000000,       -- idfMainSearchTable - bigint
    @idfSearchTable,       -- idfSearchTable - bigint
    4582950000000,       -- idfParentSearchTable - bigint
    N'ON th{0}.idfHuman = m{0}.idfHuman ',     -- strJoinCondition - nvarchar(2000)
    DEFAULT, -- rowguid - uniqueidentifier
    4582560000000,       -- idfUnionSearchTable - bigint
    NULL,    -- strReservedAttribute - nvarchar(max)
    10519001,    -- SourceSystemNameID - bigint
    '{"idfMainSearchTable":4582560000000,"idfSearchTable":' + CAST(@idfSearchTable AS NVARCHAR(100)) + ',"idfUnionSearchTable":4582950000000}',    -- SourceSystemKeyValue - nvarchar(max)
    'SYSTEM',    -- AuditCreateUser - nvarchar(200)
    DEFAULT -- AuditCreateDTM - datetime
)

INSERT INTO dbo.tasSearchTableJoinRule
(
    idfMainSearchTable,idfSearchTable,idfParentSearchTable,strJoinCondition,rowguid,idfUnionSearchTable,strReservedAttribute,SourceSystemNameID,SourceSystemKeyValue,AuditCreateUser,AuditCreateDTM
)
VALUES
(   4582950000000,       -- idfMainSearchTable - bigint
    @idfSearchTable,       -- idfSearchTable - bigint
    4582950000000,       -- idfParentSearchTable - bigint
    N'ON th{0}.idfHuman = m{0}.idfHuman ',     -- strJoinCondition - nvarchar(2000)
    DEFAULT, -- rowguid - uniqueidentifier
    4582560000000,       -- idfUnionSearchTable - bigint
    NULL,    -- strReservedAttribute - nvarchar(max)
    10519001,    -- SourceSystemNameID - bigint
    '{"idfMainSearchTable":4582560000000,"idfSearchTable":' + CAST(@idfSearchTable AS NVARCHAR(100)) + ',"idfUnionSearchTable":4582950000000}',    -- SourceSystemKeyValue - nvarchar(max)
    'SYSTEM',    -- AuditCreateUser - nvarchar(200)
    DEFAULT -- AuditCreateDTM - datetime
)






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
(   10094506,       -- idfsSystemFunction - bigint
    10060054,    -- idfsObjectType - bigint
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

-- Step 2. Insert into tasSearchObjectToSystemFunction
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
(   10082048,         -- idfsSearchObject - bigint
    10094506,         -- idfsSystemFunction - bigint , this is permission to execute
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- Step 3. Insert into tasSearchObjectToSearchObject, Not needed since relation is already added from main script '01_Rename of root objects.sql'
-- look at line ~202 of rename of fields: Add relations - 'Human Active Surveillance Session' child of 'Human Active Surveillance Campaign'
--INSERT INTO dbo.tasSearchObjectToSearchObject
--(
--    idfsRelatedSearchObject,
--    idfsParentSearchObject,
--    rowguid,
--    strSubQueryJoinCondition,
--    blnUseForSubQuery,
--    strReservedAttribute,
--    SourceSystemNameID,
--    SourceSystemKeyValue,
--    AuditCreateUser,
--    AuditCreateDTM,
--    AuditUpdateUser,
--    AuditUpdateDTM
--)
--VALUES
--(   10082048,         -- idfsRelatedSearchObject - bigint
--    10082047,         -- idfsParentSearchObject - bigint
--    NEWID(),      -- rowguid - uniqueidentifier
--    N'v_{6}.[PKField] = v.[PKField]',       -- strSubQueryJoinCondition - nvarchar(2000)
--    0,      -- blnUseForSubQuery - bit
--    N'',       -- strReservedAttribute - nvarchar(max)
--    10519001,         -- SourceSystemNameID - bigint
--    N'',       -- SourceSystemKeyValue - nvarchar(max)
--    N'',       -- AuditCreateUser - nvarchar(200)
--    GETDATE(), -- AuditCreateDTM - datetime
--    N'',       -- AuditUpdateUser - nvarchar(200)
--    GETDATE()  -- AuditUpdateDTM - datetime
--	)

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
(   10082048,         -- idfsSearchObject - bigint
    4582560000000,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4582560000000,         -- idfMandatorySearchTable - bigint
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
(   10081323,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.strMonitoringSessionID',       -- strFieldText - nvarchar(2000)
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
(   10080837,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsMonitoringSessionStatus',       -- strFieldText - nvarchar(2000)
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
(   10080838,         -- idfsSearchField - bigint
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
(   10080839,         -- idfsSearchField - bigint
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
(   10080840,         -- idfsSearchField - bigint
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
(   10080841,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.datStartDate',       -- strFieldText - nvarchar(2000)
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
(   10080842,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.datEndDate',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
    )

-- fix from Mandar on 6/21/21 to 'VAS Session - Start Date' and  'VAS Session - End Date' fields (4/26/22 commented this since values already have  4582550000000 , couses an error)
--ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
--UPDATE dbo.tasFieldSourceForTable SET idfUnionSearchTable = 4582550000000 WHERE idfsSearchField IN (10080811, 10080812)
--ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL


-- 'Human Active Surveillance Session – Disease'
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
(   10080843,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfMonitoringSession',       -- strFieldText - nvarchar(2000) -- This field comes from table tlbMonitoringSession
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
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
(   10080844,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.datEnteredDate',       -- strFieldText - nvarchar(2000)
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
(   10080845,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsCountry',       -- strFieldText - nvarchar(2000)
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
(   10080846,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
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
(   10080847,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
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
(   10080848,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsSettlement',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)


-- tasFieldSourceForTable records for "Human Active Surveillance Session Persons and Samples", PersonID (10080849) was moved to top of script since we created a new search table 'Human'
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
(   10080850,         -- idfsSearchField - bigint 
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsCountry',       -- strFieldText - nvarchar(2000)
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
(   10080851,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
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
(   10080852,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
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
(   10080853,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsSettlement',       -- strFieldText - nvarchar(2000)
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
(   10080854,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.strFieldBarcode',       -- strFieldText - nvarchar(2000)
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
(   10080855,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.idfsSampleType',       -- strFieldText - nvarchar(2000)
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
(   10080856,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.datFieldCollectionDate',       -- strFieldText - nvarchar(2000)
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
(   10080857,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4583090000028,         -- idfSearchTable - bigint
    N'm_sent_to_o{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10080858,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.idfsSampleType',       -- strFieldText - nvarchar(2000)
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
(   10080859,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.strBarcode',       -- strFieldText - nvarchar(2000)
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
(   10080860,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582930000000,         -- idfSearchTable - bigint
    N'pm{0}.idfsSampleStatus',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)


-- tasFieldSourceForTable records for "Human Active Surveillance Session Tests"
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
(   10080861,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.strBarcode',       -- strFieldText - nvarchar(2000)
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
(   10080862,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.strFieldBarcode',       -- strFieldText - nvarchar(2000)
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
(   10080863,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.idfsSampleType',       -- strFieldText - nvarchar(2000)
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
(   10080864,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4583090000114,         -- idfSearchTable - bigint
    N'th{0}.strPersonID',       -- strFieldText - nvarchar(2000)
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
(   10081346,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfMonitoringSession',       -- strFieldText - nvarchar(2000)
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
(   10080865,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582990000000,         -- idfSearchTable - bigint
    N't{0}.idfsTestName',       -- strFieldText - nvarchar(2000)
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
(   10080866,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582990000000,         -- idfSearchTable - bigint
    N't{0}.idfsTestCategory',       -- strFieldText - nvarchar(2000)
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
(   10080867,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582990000000,         -- idfSearchTable - bigint
    N't{0}.idfsTestResult',       -- strFieldText - nvarchar(2000)
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
(   10080868,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582590000000,         -- idfSearchTable - bigint
    N'isnull(t{0}.datConcludedDate, bt{0}.datValidatedDate)',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)


-- tasFieldSourceForTable records for "Human Active Surveillance Session Actions"
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
(   10080869,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.strBarcode',       -- strFieldText - nvarchar(2000)
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
(   10080871,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.datEnteredDate',       -- strFieldText - nvarchar(2000)
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
(   10080872,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4583090000019,         -- idfSearchTable - bigint
    N'dbo.fnConcatFullName(tby_p{0}.strFamilyName, tby_p{0}.strFirstName, tby_p{0}.strSecondName)',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- add join rule for 4582560000000 and 4583090000019, field 10080872
INSERT INTO tasSearchTableJoinRule
(
	idfMainSearchTable,
	idfSearchTable,
	idfParentSearchTable,
	strJoinCondition,
	rowguid,
	idfUnionSearchTable
	)
VALUES
(
	4582560000000,
	4583090000019,
	4582560000000,
	N'ON tby_p{0}.idfPerson = asms{0}.idfPersonEnteredBy and IsNull(tby_p{0}.idfInstitution, 0) = IsNull(asms{0}.idfPersonEnteredBy, IsNull(tby_p{0}.idfInstitution, 0)) ',
	NEWID(),
	4582560000000
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
(   10080873,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.strCondition',       -- strFieldText - nvarchar(2000)
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
(   10080874,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsMonitoringSessionStatus',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)


-- tasFieldSourceForTable records for "Human Active Surveillance Session Disease Reports"
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
(   10080875,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.strCaseID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- add join rule for 4582560000000 and 4582670000000, field 10080875
INSERT INTO tasSearchTableJoinRule
(
	idfMainSearchTable,
	idfSearchTable,
	idfParentSearchTable,
	strJoinCondition,
	rowguid,
	idfUnionSearchTable
	)
VALUES
(
	4582560000000,
	4582670000000,
	4582560000000,
	N'ON asms{0}.idfMonitoringSession = hc{0}.idfParentMonitoringSession AND asms{0}.intRowStatus = 0 ',
	NEWID(),
	4582560000000
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
(   10080876,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.idfsFinalCaseStatus',       -- strFieldText - nvarchar(2000)
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
(   10080877,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.idfsCaseProgressStatus',       -- strFieldText - nvarchar(2000)
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
(   10080878,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.idfsFinalDiagnosis',       -- strFieldText - nvarchar(2000)
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
(   10080879,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
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
(   10080880,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
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
(   10080881,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsSettlement',       -- strFieldText - nvarchar(2000)
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
