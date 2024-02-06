-------------------------------------------------------------------
-- Script for 'Outbreak Veterinary Case' fields
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
    N'Outbreak Veterinary Case',           -- strTableName - nvarchar(200) 
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
(   10082061,         -- idfsSearchObject - bigint
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
(   10082061,         -- idfsRelatedSearchObject - bigint
    10082061,         -- idfsParentSearchObject - bigint
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
(   10082061,         -- idfsSearchObject - bigint
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

-- Step 5. Insert into tasFieldSourceForTable, object 'Outbreak Veterinary Case'
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
(   10080995,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
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
(   10080996,         -- idfsSearchField - bigint
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
(   10080997,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
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
(   10080998,         -- idfsSearchField - bigint
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
(   10080999,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583010000000,         -- idfSearchTable - bigint
    N'vc{0}.idfsCaseType',       -- strFieldText - nvarchar(2000)
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
(   10081100,         -- idfsSearchField - bigint
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
(   10081101,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583010000000,         -- idfSearchTable - bigint
    N'vc{0}.idfsCaseClassification',       -- strFieldText - nvarchar(2000)
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
(   10081102,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582610000000,         -- idfSearchTable - bigint
    N'f_adr{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
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
(   10081103,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582610000000,         -- idfSearchTable - bigint
    N'f_adr{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
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
(   10081104,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
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
(   10081105,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582630000000,         -- idfSearchTable - bigint
    N'f_loc{0}.dblLatitude',       -- strFieldText - nvarchar(2000)
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
(   10081106,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4582630000000,         -- idfSearchTable - bigint
    N'f_loc{0}.dblLongitude',       -- strFieldText - nvarchar(2000)
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
(   10081107,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583030000000,         -- idfSearchTable - bigint
    N'vc_fd{0}.idfsDiagnosis',       -- strFieldText - nvarchar(2000)
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
(   10081108,         -- idfsSearchField - bigint
    4582900000000,         -- idfUnionSearchTable - bigint
    4583010000000,         -- idfSearchTable - bigint
    N'vc{0}.datFinalDiagnosisDate',       -- strFieldText - nvarchar(2000)
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
(   10081109,         -- idfsSearchField - bigint
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
(   10081110,         -- idfsSearchField - bigint
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
(   10081111,         -- idfsSearchField - bigint
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
(   10081112,         -- idfsSearchField - bigint
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
(   10081113,         -- idfsSearchField - bigint
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
(   10081114,         -- idfsSearchField - bigint
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
(   10081115,         -- idfsSearchField - bigint
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
(   10081116,         -- idfsSearchField - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, we do not have an example
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
(   10081117,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, we do not have an example
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
(   10081118,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, we do not have an example
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
(   10081119,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, we do not have an example
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
(   10081120,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: strFieldText update value
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
(   10081121,         -- idfsSearchField - bigint
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

--- Object 'Outbreak Veterinary Case Herd/Flock/Species' ---
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
    N'Outbreak Veterinary Case Herd/Flock/Species',           -- strTableName - nvarchar(200) 
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
(   10082062,         -- idfsSearchObject - bigint
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
(   10082062,         -- idfsRelatedSearchObject - bigint
    10082062,         -- idfsParentSearchObject - bigint
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
(   10082062,         -- idfsSearchObject - bigint
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

-- Step 5. Insert into tasFieldSourceForTable, object 'Outbreak Veterinary Case'
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
(   10081122,         -- idfsSearchField - bigint
    4582560000000,         -- idfUnionSearchTable - bigint
    4582660000000,         -- idfSearchTable - bigint
    N'Herd{0}.strHerdCode',       -- strFieldText - nvarchar(2000)
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
(   10081123,         -- idfsSearchField - bigint
    4583090000078,         -- idfUnionSearchTable - bigint
    4583090000089,         -- idfSearchTable - bigint
    N'case when isnumeric(cast(ap_Total.varValue as nvarchar)) = 1 then cast(cast(ap_Total.varValue as nvarchar) as int) else null end ',       -- strFieldText - nvarchar(2000)
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
(   10081124,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4582660000000,         -- idfSearchTable - bigint
    N'Herd{0}.intSickAnimalQty',       -- strFieldText - nvarchar(2000)
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
(   10081125,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4582660000000,         -- idfSearchTable - bigint
    N'Herd{0}.intDeadAnimalQty',       -- strFieldText - nvarchar(2000)
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
(   10081126,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.idfsSpeciesType ',       -- strFieldText - nvarchar(2000)
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
(   10081127,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.intTotalAnimalQty',       -- strFieldText - nvarchar(2000)
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
(   10081128,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.intSickAnimalQty',       -- strFieldText - nvarchar(2000)
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
(   10081129,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.intDeadAnimalQty',       -- strFieldText - nvarchar(2000)
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
(   10081130,         -- idfsSearchField - bigint
    4583090000078,         -- idfUnionSearchTable - bigint
    4583090000089,         -- idfSearchTable - bigint
    N'case when isnumeric(cast(ap_Total.varValue as nvarchar)) = 1 then cast(cast(ap_Total.varValue as nvarchar) as int) else null end ',       -- strFieldText - nvarchar(2000)
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
(   10081131,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.intSickAnimalQty',       -- strFieldText - nvarchar(2000)
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
(   10081132,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.intDeadAnimalQty',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

--- Object 'Outbreak Veterinary Case Clinical' ---
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
    N'Outbreak Veterinary Case Clinical',           -- strTableName - nvarchar(200) 
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
(   10082063,         -- idfsSearchObject - bigint
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
(   10082063,         -- idfsRelatedSearchObject - bigint
    10082063,         -- idfsParentSearchObject - bigint
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
(   10082063,         -- idfsSearchObject - bigint
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

-- Step 5. Insert into tasFieldSourceForTable, object 'Outbreak Veterinary Case'
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
(   10081133,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.idfsSpeciesType ',       -- strFieldText - nvarchar(2000)
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
(   10081134,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.idfsAnimalCondition ',       -- strFieldText - nvarchar(2000)
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
(   10081135,         -- idfsSearchField - bigint
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

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, we do not have an example
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
(   10081136,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000040,         -- idfSearchTable - bigint
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
(   10081137,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.strAnimalCode ',       -- strFieldText - nvarchar(2000)
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
(   10081138,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4582660000000,         -- idfSearchTable - bigint
    N'Herd{0}.strHerdCode',       -- strFieldText - nvarchar(2000)
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
(   10081139,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.idfsAnimalAge ',       -- strFieldText - nvarchar(2000)
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
(   10081140,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.idfsAnimalGender ',       -- strFieldText - nvarchar(2000)
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
(   10081141,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.idfsAnimalCondition ',       -- strFieldText - nvarchar(2000)
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
(   10081142,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582830000000,         -- idfSearchTable - bigint
    N'hcs_ap{0}.varValue',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

INSERT INTO dbo.tasFieldSourceForTable -- TODO: update values, we do not have an example
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
(   10081143,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000040,         -- idfSearchTable - bigint
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
(   10081144,         -- idfsSearchField - bigint
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
(   10081145,         -- idfsSearchField - bigint
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
(   10081146,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.intNumberVaccinated',       -- strFieldText - nvarchar(2000)
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
(   10081147,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.idfsVaccinationType',       -- strFieldText - nvarchar(2000)
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
(   10081148,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.idfsVaccinationRoute',       -- strFieldText - nvarchar(2000)
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
(   10081149,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.strLotNumber',       -- strFieldText - nvarchar(2000)
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
(   10081150,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583000000000,         -- idfSearchTable - bigint
    N'Vaccination{0}.strLotNumber',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

--- Object 'Outbreak Veterinary Case Contacts' ---
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
    N'Outbreak Veterinary Case Contacts',           -- strTableName - nvarchar(200) 
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
(   10082064,         -- idfsSearchObject - bigint
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
(   10082064,         -- idfsRelatedSearchObject - bigint
    10082064,         -- idfsParentSearchObject - bigint
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
(   10082064,         -- idfsSearchObject - bigint
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

-- Step 5. Insert into tasFieldSourceForTable, object 'Outbreak Veterinary Case'
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
(   10081151,         -- idfsSearchField - bigint
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
(   10081152,         -- idfsSearchField - bigint
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
(   10081153,         -- idfsSearchField - bigint
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
(   10081154,         -- idfsSearchField - bigint
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
(   10081155,         -- idfsSearchField - bigint
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
(   10081156,         -- idfsSearchField - bigint
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
(   10081157,         -- idfsSearchField - bigint
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
(   10081158,         -- idfsSearchField - bigint
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
(   10081159,         -- idfsSearchField - bigint
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
(   10081160,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582700000000,         -- idfSearchTable - bigint
    N'gl_cr_hc{0}.idfsSettlement',       -- strFieldText - nvarchar(2000)
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
(   10081161,         -- idfsSearchField - bigint
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
(   10081162,         -- idfsSearchField - bigint
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
(   10081163,         -- idfsSearchField - bigint
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

--- Object 'Outbreak Veterinary Case Samples' ---
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
    N'Outbreak Veterinary Case Samples',           -- strTableName - nvarchar(200) 
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
(   10082065,         -- idfsSearchObject - bigint
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
(   10082065,         -- idfsRelatedSearchObject - bigint
    10082065,         -- idfsParentSearchObject - bigint
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
(   10082065,         -- idfsSearchObject - bigint
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
	
-- Step 5. Insert into tasFieldSourceForTable, object 'Outbreak Veterinary Case'
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
(   10081164,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081165,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081166,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.strAnimalCode ',       -- strFieldText - nvarchar(2000)
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
(   10081167,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.idfsSpeciesType ',       -- strFieldText - nvarchar(2000)
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
(   10081168,         -- idfsSearchField - bigint
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
(   10081169,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081170,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4582960000000,         -- idfSearchTable - bigint
    N's_cby_o{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10081171,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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

--- Object 'Outbreak Veterinary Case Penside Test' ---
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
    N'Outbreak Veterinary Case Penside Test',           -- strTableName - nvarchar(200) 
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
(   10082066,         -- idfsSearchObject - bigint
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
(   10082066,         -- idfsRelatedSearchObject - bigint
    10082066,         -- idfsParentSearchObject - bigint
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
(   10082066,         -- idfsSearchObject - bigint
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
	
-- Step 5. Insert into tasFieldSourceForTable, object ''Outbreak Veterinary Case Penside Test'
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
(   10081172,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081173,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081174,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000090,         -- idfSearchTable - bigint
    N'Species{0}.idfsSpeciesType ',       -- strFieldText - nvarchar(2000)
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
(   10081175,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
    4583090000091,         -- idfSearchTable - bigint
    N'Animal{0}.strAnimalCode ',       -- strFieldText - nvarchar(2000)
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
(   10081176,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081177,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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
(   10081178,         -- idfsSearchField - bigint
    4583010000000,         -- idfUnionSearchTable - bigint
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

GO
