-------------------------------------------------------------------
-- Script for 'Human Disease Report' fields
-------------------------------------------------------------------

-- Step 5. Insert into tasFieldSourceForTable, object 'Human Disease Report'
-- Human Disease Report - Epidemiologist Name Personal ID
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
(   10081292,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582750000000,         -- idfSearchTable - bigint
    N'p_inv_hc{0}.PersonalIDValue',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Epidemiologist Name Personal ID Type
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
(   10081293,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582750000000,         -- idfSearchTable - bigint
    N'p_inv_hc{0}.PersonalIDTypeID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Notification Received By Officer Personal ID
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
(   10081294,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582790000000,         -- idfSearchTable - bigint
    N'p_rec_hc{0}.PersonalIDValue',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Notification Received By Officer Personal ID Type
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
(   10081295,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582790000000,         -- idfSearchTable - bigint
    N'p_rec_hc{0}.PersonalIDTypeID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Notification Sent By Officer Personal ID
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
(   10081296,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582810000000,         -- idfSearchTable - bigint
    N'p_sent_hc{0}.PersonalIDValue',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Notification Sent By Officer Personal ID Type
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
(   10081297,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582810000000,         -- idfSearchTable - bigint
    N'p_sent_hc{0}.PersonalIDTypeID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Sample Status, this field will cause an incorrect count due to multiple samples for a human case 
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
(   10081298,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582930000000,         -- idfSearchTable - bigint
    N'pm{0}.idfsSampleStatus',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
	
-- Human Disease Report - Tested By, this field will cause an incorrect count due to multiple test for a human case
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
(   10081299,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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

INSERT INTO tasSearchTableJoinRule
(idfMainSearchTable, idfSearchTable, idfParentSearchTable, strJoinCondition, rowguid, idfUnionSearchTable) VALUES
(4582670000000, 4583090000019, 4582990000000, N'ON tby_p{0}.idfPerson = t{0}.idfTestedByPerson and IsNull(tby_p{0}.idfInstitution, 0) = IsNull(t{0}.idfTestedByOffice, IsNull(tby_p{0}.idfInstitution, 0)) ', NEWID(), 4582670000000)

-- Human Disease Report - Tested By Institution	
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
(   10081300,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000004,         -- idfSearchTable - bigint
    N'tby_o{0}.idfOffice',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

INSERT INTO tasSearchTableJoinRule
(idfMainSearchTable, idfSearchTable, idfParentSearchTable, strJoinCondition, rowguid, idfUnionSearchTable) VALUES 
(4582670000000, 4583090000004, 4582990000000, N'ON tby_o{0}.idfOffice = t{0}.idfTestedByOffice ', NEWID(), 4582670000000)


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
(   10081301,         -- idfsSearchField - bigint
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
(   10081302,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4582670000000,         -- idfSearchTable - bigint
    N'h_hc{0}.idfsPersonIDType',       -- strFieldText - nvarchar(2000)
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
(   10081303,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10081304,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000004,         -- idfSearchTable - bigint
    N'tby_o{0}.idfOffice',       -- strFieldText - nvarchar(2000)
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
(   10081305,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000092,         -- idfSearchTable - bigint
    N'rm{0}.idfsSampleStatus',       -- strFieldText - nvarchar(2000)
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
(   10081306,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
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
(   10081307,         -- idfsSearchField - bigint
    4582670000000,         -- idfUnionSearchTable - bigint
    4583090000004,         -- idfSearchTable - bigint
    N'tby_o{0}.idfOffice',       -- strFieldText - nvarchar(2000)
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
