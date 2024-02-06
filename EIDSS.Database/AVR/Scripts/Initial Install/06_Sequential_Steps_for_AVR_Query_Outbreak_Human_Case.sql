-------------------------------------------------------------------
-- Script for Outbreak Human Case fields, check TODO's
-------------------------------------------------------------------

DECLARE @idfSearchTable BIGINT
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
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
    N'Outbreak Human Case',           -- strTableName - nvarchar(200) 
    N'  {(}    tlbOutbreak outb{0}   {1}{)}   ',       -- strFrom - nvarchar(max)
    1,         -- intTableCount - int
    0,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'outb{0}.idfOutbreak',        -- strPKField - varchar(200)
    'outb{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
   10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
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
(   10082057,         -- idfsSearchObject - bigint
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
(   10082057,         -- idfsRelatedSearchObject - bigint
    10082057,         -- idfsParentSearchObject - bigint
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

-- Step 4. Insert into tasMainTableForObject, using values from 10082016
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
(   10082057,         -- idfsSearchObject - bigint
    4582900000000,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4582900000000,         -- idfMandatorySearchTable - bigint
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

-- Step 5. Insert into tasFieldSourceForTable, object 'Outbreak Session'
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
(   10080919,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582900000000,         -- idfSearchTable - bigint
    N'outb{0}.strOutbreakID',       -- strFieldText - nvarchar(2000)
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
(   10080920,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583010000000,         -- idfSearchTable - bigint
    N'vc{0}.idfsOutbreakType',       -- strFieldText - nvarchar(2000)
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
(   10080921,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582900000000,         -- idfSearchTable - bigint
    N'vc{0}.idfsOutbreakType',       -- strFieldText - nvarchar(2000)
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
(   10080922,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.strPersonID',       -- strFieldText - nvarchar(2000)
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
(   10080923,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.idfsHumanGender',       -- strFieldText - nvarchar(2000)
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
(   10080924,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.datDateofBirth',       -- strFieldText - nvarchar(2000)
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
(   10080925,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.intPatientAge',       -- strFieldText - nvarchar(2000)
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
(   10080926,         -- idfsSearchField - bigint
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
(   10080927,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582900000000,         -- idfSearchTable - bigint
    N'outb{0}.idfsOutbreakStatus',       -- strFieldText - nvarchar(2000)
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
(   10080928,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582910000000,         -- idfSearchTable - bigint
    N'gl_outb{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
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
(   10080929,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582910000000,         -- idfSearchTable - bigint
    N'gl_outb{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
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
(   10080930,         -- idfsSearchField - bigint
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
(   10080931,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582770000000,         -- idfSearchTable - bigint
    N'gl_hc{0}.dblLatitude',       -- strFieldText - nvarchar(2000)
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
(   10080932,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582770000000,         -- idfSearchTable - bigint
    N'gl_hc{0}.dblLongitude',       -- strFieldText - nvarchar(2000)
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
(   10080933,         -- idfsSearchField - bigint
    4582550000000,         -- idfUnionSearchTable - bigint
    4582560000000,         -- idfSearchTable - bigint
    N'asms{0}.idfsDiagnosis',       -- strFieldText - nvarchar(2000)
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
(   10080934,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.datTentativeDiagnosisDate',       -- strFieldText - nvarchar(2000)
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
(   10080935,         -- idfsSearchField - bigint
    4583090000064,         -- idfUnionSearchTable - bigint
    4583090000064,         -- idfSearchTable - bigint
    N'bss{0}.datDateOfSymptomsOnset',       -- strFieldText - nvarchar(2000)
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
(   10080936,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'IsNull(hc{0}.idfsFinalCaseStatus, hc{0}.idfsInitialCaseStatus)',       -- strFieldText - nvarchar(2000)
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
(   10080937,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.datEnteredDate',       -- strFieldText - nvarchar(2000)
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
(   10080938,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582820000000,         -- idfSearchTable - bigint
    N'o_sent_hc{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10080939,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582800000000,         -- idfSearchTable - bigint
    N'o_rec_hc{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10080940,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.idfsYNHospitalization',       -- strFieldText - nvarchar(2000)
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
(   10080941,         -- idfsSearchField - bigint
    4583090000064,         -- idfUnionSearchTable - bigint
    4583090000067,         -- idfSearchTable - bigint
    N'hosp_bss{0}.idfsOfficeAbbreviation',       -- strFieldText - nvarchar(2000)
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
(   10080942,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.datHospitalizationDate',       -- strFieldText - nvarchar(2000)
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
(   10080943,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.datDischargeDate',       -- strFieldText - nvarchar(2000)
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
(   10080944,         -- idfsSearchField - bigint
    4583090000064,         -- idfUnionSearchTable - bigint
    4583090000064,         -- idfSearchTable - bigint
    N'bss{0}.idfsYNAdministratedAntiviralMedication',       -- strFieldText - nvarchar(2000)
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
(   10080945,         -- idfsSearchField - bigint
    4583090000064,         -- idfUnionSearchTable - bigint
    4583090000064,         -- idfSearchTable - bigint
    N'bss{0}.strNameOfMedication',       -- strFieldText - nvarchar(2000)
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
(   10080946,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582540000000,         -- idfSearchTable - bigint
    N'at{0}.strDosage',       -- strFieldText - nvarchar(2000)
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
(   10080947,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582540000000,         -- idfSearchTable - bigint
    N'at{0}.strDosage',       -- strFieldText - nvarchar(2000)
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
(   10080948,         -- idfsSearchField - bigint
    4583090000064,         -- idfUnionSearchTable - bigint
    4583090000064,         -- idfSearchTable - bigint
    N'bss{0}.idfsYNSeasonalFluVaccine',       -- strFieldText - nvarchar(2000)
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
(   10080949,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.strNote',       -- strFieldText - nvarchar(2000)
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
(   10080950,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.datVaccinationDate',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- TODO: update with correct value for FlexForms (not done)
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
(   10080951,         -- idfsSearchField - bigint
    0000000000000,         -- idfUnionSearchTable - bigint
    0000000000000,         -- idfSearchTable - bigint
    N'',       -- strFieldText - nvarchar(2000)
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
(   10080952,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080953,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583040000000,         -- idfSearchTable - bigint
    N'dbo.fnConcatFullName(p_inv_vc{0}.strFamilyName, p_inv_vc{0}.strFirstName, p_inv_vc{0}.strSecondName)',       -- strFieldText - nvarchar(2000)
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
(   10080954,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.datInvestigationStartDate',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- TODO: update with correct value for FlexForms (not done)
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
(   10080955,         -- idfsSearchField - bigint
    0000000000000,         -- idfUnionSearchTable - bigint
    0000000000000,         -- idfSearchTable - bigint
    N'',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- TODO: update with correct value for FlexForms (not done)
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
(   10080956,         -- idfsSearchField - bigint
    0000000000000,         -- idfUnionSearchTable - bigint
    0000000000000,         -- idfSearchTable - bigint
    N'',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- TODO: update with correct value for FlexForms (not done)
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
(   10080957,         -- idfsSearchField - bigint
    0000000000000,         -- idfUnionSearchTable - bigint
    0000000000000,         -- idfSearchTable - bigint
    N'',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- TODO: update with correct value for FlexForms (not done)
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
(   10080958,         -- idfsSearchField - bigint
    0000000000000,         -- idfUnionSearchTable - bigint
    0000000000000,         -- idfSearchTable - bigint
    N'',       -- strFieldText - nvarchar(2000)
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
(   10080959,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.idfsYNSpecimenCollected',       -- strFieldText - nvarchar(2000)
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
(   10080960,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.idfsNotCollectedReason',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)


--- Object 'Outbreak Human Case Contacts' ---
-- Insert into tasSearchObjectToSystemFunction
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
(   10082058,         -- idfsSearchObject - bigint
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

-- Insert into tasMainTableForObject, using values from 10082016
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
(   10082058,         -- idfsSearchObject - bigint
    4582900000000,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4582900000000,         -- idfMandatorySearchTable - bigint
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
(   10080961,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582690000000,         -- idfSearchTable - bigint
    N'ccp{0}.idfsPersonContactType',       -- strFieldText - nvarchar(2000)
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
(   10080962,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.strPersonID',       -- strFieldText - nvarchar(2000)
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
(   10080963,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583010000000,         -- idfSearchTable - bigint
    N'f_vc{0}.strFarmCode',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, there are no existing fields for example
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
(   10080964,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583010000000,         -- idfSearchTable - bigint
    N'ccp{0}.idfsPersonContactStatus',       -- strFieldText - nvarchar(2000)
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
(   10080965,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582690000000,         -- idfSearchTable - bigint
    N'ccp{0}.idfsPersonContactType',       -- strFieldText - nvarchar(2000)
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
(   10080966,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582690000000,         -- idfSearchTable - bigint
    N'ccp{0}.datDateOfLastContact',       -- strFieldText - nvarchar(2000)
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
(   10080967,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582690000000,         -- idfSearchTable - bigint
    N'ccp{0}.strPlaceInfo',       -- strFieldText - nvarchar(2000)
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
(   10080968,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582770000000,         -- idfSearchTable - bigint
    N'gl_hc{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
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
(   10080969,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582770000000,         -- idfSearchTable - bigint
    N'gl_hc{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
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
(   10080970,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4582610000000,         -- idfSearchTable - bigint
    N'f_adr{0}.idfsSettlement',       -- strFieldText - nvarchar(2000)
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
(   10080971,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.idfsHumanGender',       -- strFieldText - nvarchar(2000)
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
(   10080972,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.datDateofBirth',       -- strFieldText - nvarchar(2000)
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
(   10080973,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'hc{0}.intPatientAge',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

--- Object 'Outbreak Human Case Samples' ---
-- Insert into tasSearchObjectToSystemFunction
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
(   10082059,         -- idfsSearchObject - bigint
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

-- Insert into tasMainTableForObject, using values from 10082016
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
(   10082059,         -- idfsSearchObject - bigint
    4582900000000,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4582900000000,         -- idfMandatorySearchTable - bigint
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
(   10080974,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080975,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080976,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080977,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000093,         -- idfSearchTable - bigint
    N'rm_cby_o{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10080978,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582950000000,         -- idfSearchTable - bigint
    N'm{0}.datFieldSentDate',       -- strFieldText - nvarchar(2000)
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
(   10080979,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000094,         -- idfSearchTable - bigint
    N'rm_sto_o{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10080980,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000092,         -- idfSearchTable - bigint
    N'rm{0}.datAccession',       -- strFieldText - nvarchar(2000)
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
(   10080981,         -- idfsSearchField - bigint
    4583090000015,         -- idfUnionSearchTable - bigint
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

--- Object 'Outbreak Human Case Tests' ---
-- Insert into tasSearchObjectToSystemFunction
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
(   10082060,         -- idfsSearchObject - bigint
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

-- Insert into tasMainTableForObject, using values from 10082016
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
(   10082060,         -- idfsSearchObject - bigint
    4582900000000,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4582900000000,         -- idfMandatorySearchTable - bigint
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
(   10080982,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080983,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080984,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080985,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080986,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080987,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10080988,         -- idfsSearchField - bigint
    4583090000078,         -- idfUnionSearchTable - bigint
    4583090000078,         -- idfSearchTable - bigint
    N'HAggrCase{0}.datStartDate',       -- strFieldText - nvarchar(2000)
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
(   10080989,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values since we do not have an exmple
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
(   10080990,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582990000000,         -- idfSearchTable - bigint
    N'v_{6}.[PKField] = v.[PKField]',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values since we do not have an exmple
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
(   10080991,         -- idfsSearchField - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values since we do not have an exmple
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
(   10080992,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582990000000,         -- idfSearchTable - bigint
    N'v_{6}.[PKField] = v.[PKField]',       -- strFieldText - nvarchar(2000)
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
(   10080993,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000040,         -- idfSearchTable - bigint
    N'(IsNull(diag_hc{0}.blnZoonotic, 0) * 10100001 + (1 - IsNull(diag_hc{0}.blnZoonotic, 0)) * 10100002)',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values since we do not have an exmple
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
(   10080994,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582990000000,         -- idfSearchTable - bigint
    N'v_{6}.[PKField] = v.[PKField]',       -- strFieldText - nvarchar(2000)
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
