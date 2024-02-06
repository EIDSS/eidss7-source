-- Script 2023_LM_AVR_SCRIPTS_3_16_23_11_23_AM.zip from Lamont revevied on 3/16/2023
/*Veterinary Aggregate Prophylactic Actions  4583090000138 */
DECLARE @idfSearchTable BIGINT
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
Delete from tasSearchObjectToSearchObject where idfsRelatedSearchObject = 10082072 and idfsParentSearchObject = 10082071 and AuditCreateDTM ='2022-04-27 19:14:14.193'
Delete from tasMainTableForObject where idfsSearchObject = 10082071 and idfMainSearchTable = 4583090000120
IF NOT EXISTS(SELECT * from tasSearchTable where idfSearchTable = 4583090000138)
begin
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
(   4583090000138,--@idfSearchTable,         -- idfSearchTable - bigint
    N'Aggregate Case',           -- strTableName - nvarchar(200) 
    N'{(}    dbo.tlbAggrCase ac{0}
LEFT JOIN dbo.tlbAggrProphylacticActionMTX mtx_vc{0} on mtx_vc{0}.idfVersion = ac{0}.idfVersion
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000019) D{0} on D{0}.idfsReference = mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosis trt_diag{0} on trt_diag{0}.idfsDiagnosis =  mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.tlbPerson eb_p{0} on eb_p{0}.idfPerson = ac{0}.idfEnteredByPerson
LEFT JOIN dbo.tlbOffice eb_o{0} on eb_o{0}.idfOffice = ac{0}.idfEnteredByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) eb_org_abbr{0} on  eb_org_abbr{0}.idfsReference = eb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) eb_org{0} on  eb_org{0}.idfsReference = eb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson sb_p{0} on sb_p{0}.idfPerson = ac{0}.idfSentByPerson
LEFT JOIN dbo.tlbOffice sb_o{0} on sb_o{0}.idfOffice = ac{0}.idfSentByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) sb_org_abbr{0} on  sb_org_abbr{0}.idfsReference = sb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) sb_org{0} on sb_org{0}.idfsReference = sb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson RBP{0} on RBP{0}.idfPerson = ac{0}.idfReceivedByPerson
LEFT JOIN dbo.tlbOffice rbo{0} on rbo{0}.idfOffice = ac{0}.idfReceivedByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) rb_org_abbr{0} on  rb_org_abbr{0}.idfsReference = rbo{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) rb_org{0} on rb_org{0}.idfsReference = rbo{0}.idfsOfficeName
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') loc{0} on loc{0}.idfsLocation = ac{0}.idfsAdministrativeUnit
LEFT JOIN dbo.tlbActivityParameters ap on ap.idfObservation = ac{0}.idfCaseObservation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000066) ffr{0} ON ffr{0}.idfsReference = ap{0}.idfsParameter
LEFT JOIN dbo.tlbAggrMatrixVersionHeader AMVH{0} ON AMVH{0}.idfVersion{0} = ac{0}.idfProphylacticVersion
{1}{)}',
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'ac{0}.idfAggrCase',        -- strPKField - varchar(200)
    N'ac{0}.idfsAggrCaseType = 10102003 AND ac{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
end
ALTER TABLE tasSearchObjectToSystemFunction DISABLE TRIGGER ALL
-- Step 2. Insert into tasSearchObjectToSystemFunction
IF NOT EXISTS (SELECT * FROM tasSearchObjectToSystemFunction where idfsSearchObject =10082071 and idfsSystemFunction =10094506)
BEGIN
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
(   10082071,         -- idfsSearchObject - bigint
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
END
-- Step 3. Insert into tasSearchObjectToSearchObject
IF NOT EXISTS (SELECT * FROM tasSearchObjectToSearchObject WHERE idfsParentSearchObject = 10082071 AND idfsRelatedSearchObject = 10082071)
BEGIN
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
(   10082071,         -- idfsRelatedSearchObject - bigint
    10082071,         -- idfsParentSearchObject - bigint
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
END

-- Step 4. Insert into tasMainTableForObject
IF NOT EXISTS (SELECT * FROM tasMainTableForObject WHERE idfsSearchObject = 10082071 AND idfMainSearchTable = 4583090000138 and idfMandatorySearchTable = 4583090000138)
BEGIN
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
(   10082071,         -- idfsSearchObject - bigint
    4583090000138,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4583090000138,         -- idfMandatorySearchTable - bigint
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END
ALTER TABLE dbo.tasMainTableForObject DISABLE TRIGGER ALL
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.idfsAggrCaseType' where idfsSearchField = 10081267
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'trt_diag{0}.strIDC10' where idfsSearchField =10081269
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.idfsAggrCaseType' where idfsSearchField = 10081267
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'trt_diag{0}.strOIECode' where idfsSearchField =10081242
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'rbo{0}.strOrganizationID' where idfsSearchField = 10081273
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'rb_org{0}.name' where idfsSearchField = 10081274
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.strCaseID' where idfsSearchField = 10081237
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datEnteredByDate' where idfsSearchField = 10081238
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datReceivedByDate ' where idfsSearchField = 10081249
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datFinishDate ' where idfsSearchField = 10081284
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datStartDate' where idfsSearchField = 10081285
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datSentByDate ' where idfsSearchField = 10081252
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'dbo.fnConcatFullName(eb_p{0}.strFamilyName, eb_p{0}.strFirstName, eb_p{0}.strSecondName)' where idfsSearchField = 10081243
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField = 10081275
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datSentByDate ' where idfsSearchField = 10081280
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'eb_org_abbr{0}.name' where idfsSearchField = 10081244
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'eb_o{0}.strOrganizationID ' where idfsSearchField = 10081245   --o_ent_hc{0}.strOrganizationID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField = 10081275
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'sb_o{0}.strOrganizationID' where idfsSearchField = 10081277
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'dbo.fnConcatFullName(sb_p{0}.strFamilyName, sb_p{0}.strFirstName, sb_p{0}.strSecondName)' where idfsSearchField = 10081251
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'loc.AdminLevel3Name' where idfsSearchField = 10081253
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'loc{0}.AdminLevel2Name' where idfsSearchField = 10081254
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'loc{0}.AdminLevel4Name' where idfsSearchField = 10081260
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'sb_o{0}.strOrganizationID' where idfsSearchField = 10081277
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'sb_org{0}.name' where idfsSearchField = 10081278
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'dbo{0}.fnConcatFullName(sb_p{0}.strFamilyName, sb_p{0}.strFirstName, sb_p{0}.strSecondName)' where idfsSearchField = 10081279
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'loc{0}.AdminLevel3Name' where idfsSearchField = 10081281
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'rbo{0}.strOrganizationID ' where idfsSearchField = 10081246
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'sb_org{0}.name ' where idfsSearchField = 10081250
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'rb_org{0}.name' where idfsSearchField = 10081247
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField = 10081248
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'mtx_vc{0}.idfsDiagnosis' where idfsSearchField = 10081241
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datFinishDate ' where idfsSearchField = 10081256
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.datStartDate ' where idfsSearchField = 10081257

update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081289
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081290
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138, strFieldText = N'ac{0}.idfsAdministrativeUnit' where idfsSearchField =10081291

update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081241
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081255
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081259
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081258
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081240
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081239
update tasFieldSourceForTable set idfUnionSearchTable =4583090000138, idfSearchTable = 4583090000138,strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081236
update tasSearchField set strCalculatedFieldText ='Ncast((   select  distinct ASCampaignDiagnosis.[name] + ''; ''    from  tlbCampaignToDiagnosis CampaignToDiagnosesString   inner join fnReferenceRepair(@LangID, 19000019) ASCampaignDiagnosis -- rftDiagnosis   on   ASCampaignDiagnosis.idfsReference = CampaignToDiagnosesString.idfsDiagnosis   where  CampaignToDiagnosesString.idfCampaign = {5}      and CampaignToDiagnosesString.intRowStatus = 0   order by ASCampaignDiagnosis.[name] + ''; '' for xml path('''')     ) as nvarchar(max)) as [sflASCampaign_DiagnosesString] ' where idfsSearchField = 10081241
update tasSearchField set strCalculatedFieldText=null where idfsSearchField = 10081241
update tasFieldSourceForTable set strFieldText ='ap{0}.varValue', idfUnionSearchTable=4583090000138,idfSearchTable=4583090000138  where idfsSearchField =10081241
update tasFieldSourceForTable set strFieldText ='ap{0}.varValue', idfUnionSearchTable=4583090000138,idfSearchTable=4583090000138  where idfsSearchField =10081262
update tasFieldSourceForTable set strFieldText ='ap{0}.varValue', idfUnionSearchTable=4583090000138,idfSearchTable=4583090000138  where idfsSearchField =10081263
update tasFieldSourceForTable set strFieldText ='sb_org{0}.idfsReference' where  idfsSearchField = 10081250
update tasFieldSourceForTable set strFieldText ='rb_org{0}.idfsReference' where  idfsSearchField = 10081247
update tasFieldSourceForTable set strFieldText ='eb_org_abbr{0}.idfsReference' where  idfsSearchField = 10081244
update tasFieldSourceForTable set strFieldText ='loc.AdminLevel3ID' where  idfsSearchField = 10081253
update tasFieldSourceForTable set strFieldText ='loc{0}.AdminLevel2ID' where  idfsSearchField = 10081254
update tasFieldSourceForTable set strFieldText ='loc{0}.AdminLevel4ID' where  idfsSearchField =10081260
ALTER TABLE dbo.tasMainTableForObject ENABLE TRIGGER ALL
ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL
/*
--Outbreak Session Case  4583090000139
*/
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint

PRINT @idfSearchTable
IF NOT EXISTS (SELECT * FROM tasSearchTable WHERE idfSearchTable = 4583090000139)
BEGIN
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
(   4583090000139,--@idfSearchTable,         -- idfSearchTable - bigint
    N'OutBreak Session Case',           -- strTableName - nvarchar(200) 
    N'',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'vc{0}.idfVetCase',        -- strPKField - varchar(200)
    N'vc{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
PRINT @idfSearchTable
-----4583090000140
IF NOT EXISTS (SELECT * FROM tasSearchTable WHERE idfSearchTable = 4583090000140)
BEGIN
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
(   4583090000140,--@idfSearchTable,         -- idfSearchTable - bigint
    N'OutBreak Session Contacts',           -- strTableName - nvarchar(200) 
    N'',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'vc{0}.idfVetCase',        -- strPKField - varchar(200)
    N'vc{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
PRINT @idfSearchTable
IF NOT EXISTS (SELECT * FROM tasSearchTable WHERE idfSearchTable = 4583090000141)
BEGIN
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
(   4583090000141,--@idfSearchTable,         -- idfSearchTable - bigint
    N'OutBreak Session Vector',           -- strTableName - nvarchar(200) 
    N'',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'vc{0}.idfVetCase',        -- strPKField - varchar(200)
    N'vc{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END
--4583090000142
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
PRINT @idfSearchTable
IF NOT EXISTS (SELECT * FROM tasSearchTable WHERE idfSearchTable = 4583090000142)
BEGIN
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
(   4583090000142,         -- idfSearchTable - bigint
    N'Outbreak Session',           -- strTableName - nvarchar(200) 
   N'{(}    dbo.tlbOutbreak outb{0} 
LEFT JOIN dbo.tlbGeoLocation gl{0}													ON outb{0}.idfGeoLocation = gl{0}.idfGeoLocation
LEFT JOIN dbo.gisLocation g{0}														ON g{0}.idfsLocation = gl{0}.idfsLocation
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-Us'', 19000001) adminLevel0{0}		ON g{0}.node.IsDescendantOf(AdminLevel0{0}.node) = 1
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-Us'', 19000003) adminLevel1{0}		ON g{0}.node.IsDescendantOf(AdminLevel1{0}.node) = 1
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-Us'', 19000002) adminLevel2{0}		ON g{0}.node.IsDescendantOf(AdminLevel2{0}.node) = 1
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-Us'', 19000004) adminLevel3{0}	ON g{0}.node.IsDescendantOf(AdminLevel3{0}.node) = 1
INNER JOIN	dbo.FN_GBL_Repair(''en-Us'', 19000019) D{0}								ON	D{0}.idfsReference = outb{0}.idfsDiagnosisOrDiagnosisGroup
INNER JOIN	dbo.FN_GBL_Repair(''en-Us'',19000063) os{0}								ON	os{0}.idfsReference = outb{0}.idfsOutbreakStatus
INNER JOIN	dbo.FN_GBL_Repair(''en-Us'',19000513) ot{0}								ON	ot{0}.idfsReference = outb{0}.OutbreakTypeId
LEFT JOIN	dbo.tlbStreet st{0}													ON st{0}.idfsLocation = gl{0}.idfsLocation AND st{0}.strStreetName = gl{0}.strStreetName
LEFT JOIN	dbo.tlbPostalCode pc{0}												ON pc{0}.idfsLocation = gl{0}.idfsLocation AND pc{0}.strPostCode = gl{0}.strPostCode
inner join OutbreakSpeciesParameter Species{0}										ON Species{0}.idfOutbreak = outb{0}.idfOutbreak
inner join FN_GBL_ReferenceRepair(''en-us'', 19000514) SA{0}							ON SA{0}.idfsReference = Species{0}.OutbreakSpeciesTypeID
inner join OutbreakCaseReport OCR{0}
on OCR{0}.idfOutbreak = outb{0}.idfOutbreak
inner join OutbreakCaseContact OCC{0}
on OCC{0}.OutBreakCaseReportUID = OCR{0}.OutbreakCaseReportUID
LEFT JOIN tlbHumanCase hc{0} on hc{0}.idfHumanCase = OCR{0}.idfHumanCase
LEFT JOIN tlbVetCase  vc{0} ON vc{0}.idfVetCase = OCR{0}.idfVetCase
LEFT JOIN dbo.tlbHuman h{0} ON h{0}.idfHuman = occ{0}.idfHuman
LEFT JOIN dbo.HumanActualAddlInfo haai{0} ON haai{0}.HumanActualAddlInfoUID = h{0}.idfHumanActual
LEFT JOIN dbo.tlbFarm f{0}  ON f{0}.idfHuman = occ{0}.idfHuman 
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-Us'', 19000043) gender{0} ON gender{0}.idfsReference = h{0}.idfsHumanGender
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-Us'', 19000054) citizenshipType{0} ON citizenshipType{0}.idfsReference = h{0}.idfsNationality
LEFT JOIN dbo.tlbGeoLocation geo{0} ON h{0}.idfCurrentResidenceAddress = geo{0}.idfGeoLocation
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-Us'') lh{0} ON lh{0}.idfsLocation = geo{0}.idfsLocation
LEFT JOIN dbo.gisLocation settlement{0} ON settlement{0}.idfsLocation = geo{0}.idfsLocation AND settlement{0}.idfsType IS NOT NULL
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-Us'', 19000516) contactType{0}  ON contactType{0}.idfsReference = occ{0}.ContactTypeID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-Us'', 19000517) contactStatusType{0} ON contactStatusType{0}.idfsReference = occ{0}.ContactStatusID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-Us'', 19000014) contactRelationshipType{0} ON contactRelationshipType{0}.idfsReference = occ{0}.ContactRelationshipTypeID
{1} {)}',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'vc{0}.idfVetCase',        -- strPKField - varchar(200)
    N'vc{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END
Update tasSearchTable set strFrom =N'
  	{(} 
  		trtDiagnosis diag_vc{0} 
  			outer apply (
  				select min(group_diag_vc{0}.idfsDiagnosisGroup) as idfsDiagnosisGroup
  				from dbo.trtDiagnosisToDiagnosisGroup group_diag_vc{0}
  				where group_diag_vc{0}.idfsDiagnosis = diag_vc{0}.idfsDiagnosis 		
  			) as group_diag_vc{0}
  	{1}{)} 
  ', strPKField='diag_vc{0}.idfsDiagnosis', strExistenceCondition='' where idfSearchTable =  4583090000039


--4583090000143
-- Step 1. Insert into tasSearchTable, these values come from tasSearchTable look for similar values to find what you are looking for
IF NOT EXISTS (SELECT * FROM tasSearchTable where idfSearchTable =4583090000143)
BEGIN
EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
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
(   4583090000143,--@idfSearchTable,         -- idfSearchTable - bigint
    N'',           -- strTableName - nvarchar(200) 
    N'{(}    dbo.tlbOutbreak outb{0} 
LEFT JOIN dbo.tlbGeoLocation gl{0}													ON outb{0}.idfGeoLocation = gl{0}.idfGeoLocation
LEFT JOIN dbo.gisLocation g{0}														ON g{0}.idfsLocation = gl{0}.idfsLocation
LEFT JOIN FN_GBL_LocationHierarchy_Flattened(''en-us'') outbLH{0}						 ON outbLH{0}.idfsLocation = g{0}.idfsLocation
INNER JOIN	dbo.FN_GBL_Repair(''en-us'', 19000019) D{0}								ON	D{0}.idfsReference = outb{0}.idfsDiagnosisOrDiagnosisGroup
INNER JOIN	dbo.FN_GBL_Repair(''en-us'',19000063) os{0}								ON	os{0}.idfsReference = outb{0}.idfsOutbreakStatus
INNER JOIN	dbo.FN_GBL_Repair(''en-us'',19000513) ot{0}								ON	ot{0}.idfsReference = outb{0}.OutbreakTypeId
LEFT JOIN	dbo.tlbStreet st{0}														ON st{0}.idfsLocation = gl{0}.idfsLocation AND st{0}.strStreetName = gl{0}.strStreetName
LEFT JOIN	dbo.tlbPostalCode pc{0}													ON pc{0}.idfsLocation = gl{0}.idfsLocation AND pc{0}.strPostCode = gl{0}.strPostCode
inner join OutbreakSpeciesParameter Species{0}										ON Species{0}.idfOutbreak = outb{0}.idfOutbreak
inner join FN_GBL_ReferenceRepair(''en-us'', 19000514) SA{0}						ON SA{0}.idfsReference = Species{0}.OutbreakSpeciesTypeID
inner join OutbreakCaseReport OCR{0}
on OCR{0}.idfOutbreak = outb{0}.idfOutbreak
inner join OutbreakCaseContact OCC{0}
on OCC{0}.OutBreakCaseReportUID = OCR{0}.OutbreakCaseReportUID
LEFT JOIN tlbHumanCase hc{0} on hc{0}.idfHumanCase = OCR{0}.idfHumanCase
LEFT JOIN tlbVetCase  vc{0} ON vc{0}.idfVetCase = OCR{0}.idfVetCase
LEFT JOIN dbo.tlbHuman h{0} ON h{0}.idfHuman = occ{0}.idfHuman
LEFT JOIN FN_GBL_LocationHierarchy_Flattened(''en-us'') hcLH{0}						 ON hcLH{0}.idfsLocation = h{0}.idfCurrentResidenceAddress
LEFT JOIN dbo.HumanActualAddlInfo haai{0} ON haai{0}.HumanActualAddlInfoUID = h{0}.idfHumanActual
LEFT JOIN dbo.tlbFarm f{0}  ON f{0}.idfHuman = occ{0}.idfHuman 
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000043) gender{0} ON gender{0}.idfsReference = h{0}.idfsHumanGender
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000054) citizenshipType{0} ON citizenshipType{0}.idfsReference = h{0}.idfsNationality
LEFT JOIN dbo.tlbGeoLocation geo{0} ON h{0}.idfCurrentResidenceAddress = geo{0}.idfGeoLocation
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') lh{0} ON lh{0}.idfsLocation = geo{0}.idfsLocation
LEFT JOIN dbo.gisLocation settlement{0} ON settlement{0}.idfsLocation = geo{0}.idfsLocation AND settlement{0}.idfsType IS NOT NULL
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000516) contactType{0}  ON contactType{0}.idfsReference = occ{0}.ContactTypeID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000517) contactStatusType{0} ON contactStatusType{0}.idfsReference = occ{0}.ContactStatusID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000014) contactRelationshipType{0} ON contactRelationshipType{0}.idfsReference = occ{0}.ContactRelationshipTypeID
LEFT JOIN tlbVectorSurveillanceSession vec{0} on vec{0}.idfOutbreak = outb{0}.idfOutbreak
LEFT JOIN dbo.tlbGeoLocation geovec{0} ON  geovec{0}.idfGeoLocation = vec{0}.idfLocation  
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-Us'') vec_lh{0} ON vec_lh{0}.idfsLocation = geovec{0}.idfsLocation
{1} {)}',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'outb{0}.idfOutbreak',        -- strPKField - varchar(200)
    N'outb{0}.intRowStatus=0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END
-- Step 2. Insert into tasSearchObjectToSystemFunction
IF NOT EXISTS(SELECT * from tasSearchObjectToSystemFunction where idfsSearchObject =10082053 and idfsSystemFunction = 10094506)
BEGIN
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
(   10082053,         -- idfsSearchObject - bigint
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
END
-- Step 3. Insert into tasSearchObjectToSearchObject
IF NOT EXISTS ( SELECT * FROM tasSearchObjectToSearchObject WHERE  idfsRelatedSearchObject = 10082053 AND idfsParentSearchObject = 10082053)
BEGIN
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
(   10082053,         -- idfsRelatedSearchObject - bigint
    10082053,         -- idfsParentSearchObject - bigint
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
END
-- Step 4. Insert into tasMainTableForObject
IF NOT EXISTS (SELECT * FROM tasMainTableForObject WHERE idfsSearchObject = 10082053 AND idfMainSearchTable = 4583090000143)
BEGIN
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
(   10082053,         -- idfsSearchObject - bigint
    4583090000143,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4583090000143,         -- idfMandatorySearchTable - bigint
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
END



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
(   10080887,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'outb{0}.idfsDiagnosisOrDiagnosisGroup',       -- strFieldText - nvarchar(2000)
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
(   10080885,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'outb{0}.datFinishDate',       -- strFieldText - nvarchar(2000)
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
(   10080882,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080884,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'outb{0}.datStartDate',       -- strFieldText - nvarchar(2000)
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
(   10080883,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080886,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'outb{0}.OutbreakTypeID',       -- strFieldText - nvarchar(2000)
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
(   10080890,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'adminLevel2{0}.idfsReference',       -- strFieldText - nvarchar(2000)
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
(   10080889,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'adminLevel1{0}.idfsReference',       -- strFieldText - nvarchar(2000)
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
(   10080891,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'adminLevel3{0}.idfsReference',       -- strFieldText - nvarchar(2000)
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
(   10080888,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'Species{0}.idfOutbreak',       -- strFieldText - nvarchar(2000)
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
(   10080897,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'hc{0}.datExposureDate',       -- strFieldText - nvarchar(2000)
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
(   10080898,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'OCR{0}.OutbreakCaseClassificationID',       -- strFieldText - nvarchar(2000)
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
(   10080902,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080895,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080894,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'outb{0}.OutbreakTypeID',       -- strFieldText - nvarchar(2000)
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
(   10080893,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080896,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'hc{0}.datOnSetDate',       -- strFieldText - nvarchar(2000)
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
(   10080892,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'OCR{0}.strOutbreakCaseID',       -- strFieldText - nvarchar(2000)
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
(   10080900,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080899,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080901,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
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
(   10080906,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'OCC{0}.DateOfLastContact',       -- strFieldText - nvarchar(2000)
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
(   10080904,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'f{0}.strFarmCode',       -- strFieldText - nvarchar(2000)
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
(   10080905,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'h{0}.idfsHumanGender',       -- strFieldText - nvarchar(2000)
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
(   10080903,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'h{0}.strPersonID',       -- strFieldText - nvarchar(2000)
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
(   10080910,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'asms{0}.idfsSettlement',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)  ---
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
(   10080908,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'gl{0}.idfsRayon',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080907,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'gl{0}.idfsRegion',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080909,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'gl{0}.idfsSettlement ',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080911,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'vec{0}.strSessionID',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080912,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'vec{0}.idfsVectorSurveillanceStatus',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080913,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'vec{0}.datStartDate',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080914,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'vec{0}.datCloseDate',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080915,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'glf{0}.AdminLevel1Name',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080916,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'glf{0}.AdminLevel2Name',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080917,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'glf{0}.AdminLevel1Name',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
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
(   10080918,         -- idfsSearchField - bigint
    4583090000143,         -- idfUnionSearchTable - bigint
    4583090000143,         -- idfSearchTable - bigint
    N'glf{0}.AdminLevel1Name',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	) ---
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel2ID'  where idfsSearchField = 10080899 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel3ID'  where idfsSearchField = 10080900 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel4ID'  where idfsSearchField = 10080901 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='outbLH{0}.AdminLevel2ID'  where idfsSearchField = 10080889 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='outbLH{0}.AdminLevel3ID'  where idfsSearchField = 10080890 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='outbLH{0}.AdminLevel4ID'  where idfsSearchField = 10080891 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='outbLH{0}.AdminLevel2ID'  where idfsSearchField = 10080889 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='outbLH{0}.AdminLevel3ID'  where idfsSearchField = 10080890 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='outbLH{0}.AdminLevel4ID'  where idfsSearchField = 10080891 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 45830900001
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel2ID'  where idfsSearchField = 10080899 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel3ID'  where idfsSearchField = 10080900 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel4ID'  where idfsSearchField = 10080901 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel2ID'  where idfsSearchField = 10080907 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel3ID'  where idfsSearchField = 10080908 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel4ID'  where idfsSearchField = 10080909 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='vec_lh{0}.AdminLevel1ID'  where idfsSearchField = 10080915 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='vec_lh{0}.AdminLevel3ID'  where idfsSearchField = 10080917 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='vec_lh{0}.AdminLevel2ID'  where idfsSearchField = 10080916 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasFieldSourceForTable set strFieldText ='vec_lh{0}.AdminLevel4ID'  where idfsSearchField = 10080918 and idfSearchTable = 4583090000143 and idfUnionSearchTable = 4583090000143
update tasSearchField set strSearchFieldAlias = 'sflOSV_Settlement' where idfsSearchField = 10080918
Delete from tasMainTableForObject where idfsSearchObject = 10082053 and idfMainSearchTable in(4582900000000
,4583090000122)
----GOOD 
ALTER TABLE tasSearchObjectToSystemFunction DISABLE TRIGGER ALL

/*
OUTBREAK HUMAN CASE 
*/
IF EXISTS(Select * from tasMainTableForObject where idfMainSearchTable = 4582900000000)
BEGIN
ALTER TABLE dbo.tasMainTableForObject DISABLE TRIGGER ALL
update tasMainTableForObject set idfMainSearchTable = 4583090000123, idfMandatorySearchTable = 4583090000123 where idfsSearchObject = 10082057
ALTER TABLE dbo.tasMainTableForObject ENABLE TRIGGER ALL
END
ELSE 
BEGIN 
ALTER TABLE dbo.tasMainTableForObject DISABLE TRIGGER ALL
INSERT INTO tasMainTableForObject (idfsSearchObject,idfMainSearchTable,rowguid, idfMandatorySearchTable, SourceSystemNameID,AuditCreateDTM)
VALUES
(4583090000123,4583090000123,NEWID(),4583090000123,10519002,GETDATE())
ALTER TABLE dbo.tasMainTableForObject ENABLE TRIGGER ALL
END
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
----sELECT * FROM tasMainTableForObject WHERE idfMainSearchTable = 4583090000123
update tasFieldSourceForTable set	strFieldText ='Hospitalization{0}.idfsReference' where idfsSearchField = 10080941
update tasFieldSourceForTable set	strFieldText ='SentByOfficeRef{0}.idfsReference' where idfsSearchField = 10080938
update tasFieldSourceForTable set	strFieldText ='ReceivedByOfficeRef{0}.idfsReference' where idfsSearchField = 10080939
update tasFieldSourceForTable set	strFieldText ='InvestigateByOfficeRef{0}.idfsReference' where idfsSearchField =  10080952
update tasFieldSourceForTable set strFieldText ='o{0}.OutbreakTypeID' where idfsSearchField = 10080920
update tasFieldSourceForTable set strFieldText ='LH{0}.AdminLevel2ID' where idfsSearchField = 10080968
update tasFieldSourceForTable set strFieldText ='LH{0}.AdminLevel3ID' where idfsSearchField = 10080969
update tasFieldSourceForTable set strFieldText = 'LH{0}.AdminLevel4ID' where idfsSearchField = 10080970
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080955,4583090000123,4583090000123,N'o{0}.idfPrimaryCaseOrSession',NEWID(),10519001)
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080951,4583090000123,4583090000123,N'hc{0}.strNote',NEWID(),10519001)
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080946,4583090000123,4583090000123,N'therapy{0}.strDosage',NEWID(),10519001)
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080950,4583090000123,4583090000123,N'vac{0}.datVaccinationDate',NEWID(),10519001)
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080958,4583090000123,4583090000123,'  ',NEWID(),10519001)
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080957,4583090000123,4583090000123,'hc{0}.idfParentMonitoringSession ',NEWID(),10519001) -- sflOHC_CaseMonitoring
Insert into tasFieldSourceForTable ( idfsSearchField, idfUnionSearchTable, idfSearchTable,strFieldText,rowguid, SourceSystemNameID)
values(10080956,4583090000123,4583090000123,'  ',NEWID(),10519001) -- sflOHC_CaseQuestionnaire
ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL
update tasFieldSourceForTable set strFieldText ='hc{0}.idfCSObservation' where idfsSearchField = 10080956
update tasFieldSourceForTable set strFieldText ='ccp{0}.idfContactedCasePerson' where idfsSearchField = 10080958
update tasFieldSourceForTable set strFieldText = N'vac{0}.datVaccinationDate' where idfsSearchField = 10080950
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL

update tasSearchTable set strPKField =N'hc{0}.idfHumanCase', strExistenceCondition=N'hc{0}.intRowStatus = 0'  where idfSearchTable = 4583090000123
update tasSearchTable set strFrom=N'
{(}dbo.tlbHumanCase hc{0} WITH (NOLOCK)
LEFT JOIN dbo.tlbOutbreak AS o{0} ON o{0}.idfOutbreak = hc{0}.idfOutbreak
LEFT JOIN dbo.tlbHuman AS h{0} ON h{0}.idfHuman = hc{0}.idfHuman
LEFT JOIN dbo.tlbHumanActual AS ha{0} ON ha{0}.idfHumanActual = h{0}.idfHumanActual AND h{0}.intRowStatus = 0
LEFT JOIN dbo.HumanActualAddlInfo AS addinfo{0} ON addinfo{0}.HumanActualAddlInfoUID = h{0}.idfHumanActual AND addinfo{0}.intRowStatus = 0
LEFT JOIN dbo.tlbGeoLocation AS gl{0} ON gl{0}.idfGeoLocation = hc{0}.idfPointGeoLocation AND gl{0}.intRowStatus = 0
LEFT JOIN dbo.tlbPerson AS sentByPersonRef{0} ON sentByPersonRef{0}.idfPerson = hc{0}.idfSentByPerson AND sentByPersonRef{0}.intRowStatus = 0    
LEFT JOIN dbo.tlbPerson AS receivedByPersonRef{0} ON receivedByPersonRef.idfPerson = hc{0}.idfReceivedByPerson AND receivedByPersonRef{0}.intRowStatus = 0    
LEFT JOIN dbo.tlbPerson AS investigatedByPersonRef{0} ON investigatedByPersonRef{0}.idfPerson = hc{0}.idfInvestigatedByPerson AND investigatedByPersonRef{0}.intRowStatus = 0
LEFT JOIN dbo.tlbPerson AS personEnteredByRef{0} ON personEnteredByRef{0}.idfPerson = hc{0}.idfPersonEnteredBy AND personEnteredByRef{0}.intRowStatus = 0
LEFT JOIN dbo.gisLocation L{0} ON L{0}.idfsLocation = gl{0}.idfsLocation
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-us'', 19000001) AS CountryRef{0} ON L{0}.node.IsDescendantOf(CountryRef{0}.node) = 1
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-us'', 19000003) AS RegionRef{0} ON L{0}.node.IsDescendantOf(RegionRef{0}.node) = 1
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-us'', 19000002) AS RayonRef{0} ON L{0}.node.IsDescendantOf(RayonRef{0}.node) = 1
LEFT JOIN dbo.FN_GBL_GIS_ReferenceRepair_GET(''en-us'', 19000004) AS SettlementRef{0} ON L.node.IsDescendantOf(SettlementRef{0}.node) = 1
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000042) AS HumanAgeRef{0} ON HumanAgeRef{0}.idfsReference = hc{0}.idfsHumanAgeType
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000064) AS OutcomeRef{0} ON OutcomeRef{0}.idfsReference = hc{0}.idfsOutcome 
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000019) AS FinalDiagnosis{0}  ON FinalDiagnosis{0}.idfsReference = hc{0}.idfsFinalDiagnosis
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000011) AS InitialCaseClassification{0} ON InitialCaseClassification.idfsReference = hc.idfsInitialCaseStatus{0}
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000011) AS FinalCaseClassification{0}  ON FinalCaseClassification{0}.idfsReference = hc{0}.idfsFinalCaseStatus
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000149) AS NonNotifiableDiagnosisRef{0} ON NonNotifiableDiagnosisRef{0}.idfsReference = hc{0}.idfsNonNotifiableDiagnosis
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000019) AS NotCollectedReasonRef{0} ON NotCollectedReasonRef{0}.idfsReference = hc{0}.idfsNotCollectedReason
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000111) CaseProgressStatusRef{0} ON CaseProgressStatusRef{0}.idfsReference = hc{0}.idfsCaseProgressStatus
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS SpecificVaccinationAdministered{0} ON SpecificVaccinationAdministered{0}.idfsReference = hc.idfsYNSpecificVaccinationAdministered{0}
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS PreviouslySoughtCareRef{0} ON PreviouslySoughtCareRef{0}.idfsReference = hc{0}.idfsYNPreviouslySoughtCare
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS ExposureLocationKnown{0} ON ExposureLocationKnown{0}.idfsReference = hc{0}.idfsYNExposureLocationKnown
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000041) AS HospitalizationStatusRef{0}  ON HospitalizationStatusRef{0}.idfsReference = hc{0}.idfsHospitalizationStatus
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS Hospitalization{0} ON Hospitalization{0}.idfsReference = hc{0}.idfsYNHospitalization
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS AntimicrobialTherapy{0} ON AntimicrobialTherapy{0}.idfsReference = hc{0}.idfsYNAntimicrobialTherapy
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS SpecimenCollection{0} ON SpecimenCollection{0}.idfsReference = hc{0}.idfsYNSpecimenCollected
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS RelatedToOutBreak{0}  ON RelatedToOutBreak{0}.idfsReference = hc.idfsYNRelatedToOutbreak
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000036) AS ExposureLocationTypeRef{0} ON ExposureLocationTypeRef{0}.idfsReference = gl{0}.idfsGeoLocationType
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000019) AS tentativeDiagnosisRef{0} ON tentativeDiagnosisRef{0}.idfsReference = hc.idfsTentativeDiagnosis{0}
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000038) AS groundTypeRef{0} ON groundTypeRef{0}.idfsReference = gl{0}.idfsGroundType 
LEFT JOIN dbo.tlbOffice RBO{0} ON RBO{0}.idfOffice = hc{0}.idfReceivedByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000045) ReceivedByOfficeRef{0} ON ReceivedByOfficeRef{0}.idfsReference = RBO{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.tlbOffice IBO{0} ON IBO{0}.idfOffice = hc{0}.idfInvestigatedByOffice 
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000045) InvestigateByOfficeRef{0} ON InvestigateByOfficeRef{0}.idfsReference = IBO{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.tlbOffice SBO{0} ON SBO{0}.idfOffice = hc{0}.idfSentByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000045) SentByOfficeRef{0} ON SentByOfficeRef{0}.idfsReference = SBO{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000100) AS TestConducted{0}     ON TestConducted{0}.idfsReference = hc{0}.idfsYNTestsConducted
LEFT JOIN dbo.tlbMonitoringSession AS MonitoringSession{0}     ON MonitoringSession{0}.idfMonitoringSession = hc{0}.idfParentMonitoringSession
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000035) AS PatientState{0}     ON PatientState{0}.idfsReference = hc{0}.idfsFinalState 
LEFT JOIN dbo.tlbOffice Hospital ON Hospital{0}.idfOffice = hc{0}.idfHospital
LEFT JOIN dbo.FN_GBL_ReferenceRepair(''en-us'', 19000045) HospitalRef{0} ON HospitalRef{0}.idfsReference = Hospital{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.tstSite  S{0} ON S{0}.idfsSite = hc{0}.idfsSite
LEFT JOIN dbo.FN_HUM_Institution_GET(''en-us'') AS tlbEnteredByOffice{0} ON tlbEnteredByOffice{0}.idfOffice = S{0}.idfOffice AND tlbEnteredByOffice{0}.idfsSite = hc{0}.idfsSite
LEFT JOIN dbo.trtDiagnosis AS finalSyndromicSurveielanceDiseases{0} ON finalSyndromicSurveielanceDiseases{0}.idfsDiagnosis =  hc{0}.idfsFinalDiagnosis
LEFT JOIN dbo.trtDiagnosis AS initialSyndromicSurveielanceDiseases{0} ON initialSyndromicSurveielanceDiseases{0}.idfsDiagnosis =  hc{0}.idfsTentativeDiagnosis
LEFT JOIN dbo.HumanDiseaseReportRelationship relatedTo{0}  ON relatedTo.HumanDiseaseReportID = hc{0}.idfHumanCase AND relatedTo{0}.intRowStatus = 0  AND relatedTo{0}.RelationshipTypeID = 10503001
LEFT JOIN dbo.tlbHumanCase relatedToReport{0}  ON relatedToReport{0}.idfHumanCase = relatedTo{0}.RelateToHumanDiseaseReportID  AND relatedToReport{0}.intRowStatus = 0  
LEFT JOIN dbo.HumanDiseaseReportRelationship connectedTo{0} ON connectedTo.RelateToHumanDiseaseReportID = hc{0}.idfHumanCase  AND connectedTo{0}.intRowStatus = 0  AND connectedTo{0}.RelationshipTypeID = 10503001
LEFT JOIN dbo.tlbHumanCase connectedToReport{0} ON connectedToReport{0}.idfHumanCase = connectedTo{0}.HumanDiseaseReportID
LEFT JOIN dbo.tlbAntimicrobialTherapy therapy{0} on therapy{0}.idfHumanCase = hc{0}.idfHumanCase
LEFT JOIN dbo.tlbVaccination vac{0} on vac{0}.idfVetCase = hc{0}.idfHumanCase
LEFT JOIN dbo.tlbContactedCasePerson ccp{0} on ccp{0}.idfHumanCase = hc{0}.idfHumanCase
LEFT JOIN dbo.tlbHuman ch{0} on ch{0}.idfHuman = ccp{0}.idfHuman
LEFT JOIN dbo.tlbMonitoringSession ms{0} on ms{0}.idfMonitoringSession = hc{0}.idfParentMonitoringSession
LEFT JOIN dbo.tlbMaterial m{0} on m{0}.idfHumanCase = hc{0}.idfHumanCase
LEFT JOIN dbo.tlbTesting tst{0} on tst{0}.idfHumanCase = hc{0}.idfHumanCase
LEFT JOIN dbo.OutbreakCaseReport oubtcr{0} on oubtcr{0}.idfOutbreak = o{0}.idfOutbreak
LEFT JOIN dbo.OutbreakCaseContact occ{0} on occ{0}.idfHuman = hc{0}.idfHuman
AND connectedToReport{0}.intRowStatus = 0{1} {)}' where idfSearchTable = 4583090000123
				   SELECT * FROM tasSearchTable WHERE idfSearchTable = 4583090000123
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'o{0}.strOutbreakID'  where idfsSearchField = 10080919	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'o.OutbreakTypeID' where idfsSearchField = 10080920	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'o{0}.strOutbreakID' where idfsSearchField = 10080921		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'h{0}.strPersonID' where idfsSearchField = 10080922		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ha{0}.idfsHumanGender' where idfsSearchField = 10080923	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ha{0}.datDateofBirth' where idfsSearchField = 10080924		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.intPatientAge' where idfsSearchField = 10080925	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datEnteredDate' where idfsSearchField = 10080926		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'o{0}.idfsOutbreakStatus' where idfsSearchField = 10080927		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'RegionRef{0}.idfsReference' where idfsSearchField = 10080928	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'RayonRef{0}.idfsReference' where idfsSearchField = 10080929	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'SettlementRef{0}.idfsReference' where idfsSearchField = 10080930	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'gl{0}.dblLatitude' where idfsSearchField = 10080931	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'gl{0}.dblLongitude' where idfsSearchField = 10080932	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.idfsFinalDiagnosis' where idfsSearchField = 10080933	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datTentativeDiagnosisDate' where idfsSearchField = 10080934	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datOnSetDate' where idfsSearchField = 10080935	

update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'IsNull(hc{0}.idfsFinalCaseStatus, hc{0}.idfsInitialCaseStatus)' where idfsSearchField = 10080936		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datEnteredDate' where idfsSearchField = 10080937	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'SentByOfficeRef{0}.idfsReference' where idfsSearchField = 10080938		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ReceivedByOfficeRef{0}.idfsReference' where idfsSearchField = 10080939	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.idfsYNHospitalization' where idfsSearchField = 10080940		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'Hospitalization{0}.idfsReference' where idfsSearchField = 10080941		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datHospitalizationDate' where idfsSearchField = 10080942		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datDischargeDate' where idfsSearchField = 10080943		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.idfsYNSpecificVaccinationAdministered' where idfsSearchField = 10080944		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'SpecificVaccinationAdministered{0}.[name]' where idfsSearchField = 10080945	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'at{0}.strDosage' where idfsSearchField = 10080946		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datFirstSoughtCareDate' where idfsSearchField = 10080947		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.idfsYNSpecificVaccinationAdministered' where idfsSearchField = 10080948	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'SpecificVaccinationAdministered{0}.[name]' where idfsSearchField = 10080949		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'Vaccination{0}.datVaccinationDate' where idfsSearchField = 10080950		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'InvestigateByOfficeRef{0}.LongName' where idfsSearchField = 10080952	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ISNULL(investigatedByPersonRef{0}.strFamilyName, '''') + ISNULL('''' + investigatedByPersonRef{0}.strFirstName, '''') + ISNULL('''' + investigatedByPersonRef{0}.strSecondName, '''')' where idfsSearchField = 10080953
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.datInvestigationStartDate' where idfsSearchField = 10080954	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.idfsYNSpecimenCollected' where idfsSearchField = 10080959		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'hc{0}.idfsNotCollectedReason' where idfsSearchField = 10080960		

/*outbreak human case contacts*/
update tasSearchField set idfsSearchFieldType=10081007, idfsReferenceType = NULL, strLookupTable=NULL where idfsSearchField =10080964
update tasFieldSourceForTable set strFieldText= 'occ{0}.ContactStatusID' where idfsSearchField =10080964
update tasSearchField set strSearchFieldAlias= 'ch_contactPersonId' where idfsSearchField =10080962
update tasSearchField set strSearchFieldAlias= 'ch_contactGender' where idfsSearchField = 10080971
update tasSearchField set strSearchFieldAlias= 'ch_contactDateOfBirth' where idfsSearchField = 10080972
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ccp{0}.idfsPersonContactType' where idfsSearchField = 10080961		
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ch{0}.strPersonID' where idfsSearchField = 10080962	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ccp{0}.intRowStatus' where idfsSearchField = 10080963	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ccp{0}.intRowStatus' where idfsSearchField = 10080964	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ccp{0}.idfsPersonContactType' where idfsSearchField = 10080965	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ccp{0}.datDateOfLastContact' where idfsSearchField = 10080966	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ccp{0}.strPlaceInfo' where idfsSearchField = 10080967	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'RegionRef{0}.idfsReference' where idfsSearchField = 10080968	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'RayonRef{0}.idfsReference' where idfsSearchField = 10080969	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'SettlementRef{0}.idfsReference' where idfsSearchField = 10080970	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ch{0}.idfsHumanGender' where idfsSearchField = 10080971	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ch{0}.datDateofBirth' where idfsSearchField = 10080972	
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'ch{0}.datDateofBirth' where idfsSearchField = 10080973	
/*outbreak human case samples*/
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.idfsSampleType' where idfsSearchField = 10080974
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.strFieldBarcode' where idfsSearchField = 10080975
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.datFieldCollectionDate' where idfsSearchField = 10080976
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.idfSendToOffice' where idfsSearchField = 10080977
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.datFieldSentDate' where idfsSearchField = 10080978
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.idfSendToOffice' where idfsSearchField = 10080979
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.datAccession' where idfsSearchField = 10080980
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.strCondition' where idfsSearchField = 10080981
/*OUTBREAK HUMAN CASE TEST*/

update tasSearchField set strSearchFieldAlias = 'sflHACD_StartDate' where idfsSearchField = 10080988
update tasSearchField set strSearchFieldAlias = 'outbHCTest_DateValidated' where idfsSearchField = 10080994
update tasSearchField set strSearchFieldAlias = 'outbHCTest_LabSampleID' where idfsSearchField = 10080984
update tasSearchField set strSearchFieldAlias = 'outbHCTest_FieldSampleID' where idfsSearchField = 10080983
update tasSearchField set strSearchFieldAlias = 'sflHCSample_SampleType_SampleType' where idfsSearchField = 10080982

update tasFieldSourceForTable set  strFieldText =N'tst{0}.datReceivedDate' where idfsSearchField = 10080988
update tasFieldSourceForTable set  strFieldText =N'm{0}.idfsAccessionCondition' where idfsSearchField = 10080993


update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.idfsSampleType' where idfsSearchField = 10080982
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.strBarcode' where idfsSearchField = 10080983
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.strFieldBarcode' where idfsSearchField = 10080984
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.idfsTestName' where idfsSearchField = 10080985
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.idfsTestResult' where idfsSearchField = 10080986
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.datConcludedDate' where idfsSearchField = 10080987
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst.datReceivedDate' where idfsSearchField = 10080988
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.idfsTestCategory' where idfsSearchField = 10080989
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.blnNonLaboratoryTest' where idfsSearchField = 10080990
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.datStartedDate' where idfsSearchField = 10080991
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.idfResultEnteredByPerson' where idfsSearchField = 10080992
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'm{0}.strCondition' where idfsSearchField = 10080993
update tasFieldSourceForTable set idfUnionSearchTable=4583090000123, idfSearchTable =4583090000123, strFieldText =N'tst{0}.datReceivedDate' where idfsSearchField = 10080994
ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL

/*VET AGGREGATE SANITARY ACTIONS */
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
update tasSearchTable set strFrom=N'{(}    dbo.tlbAggrCase ac{0}
LEFT JOIN dbo.tlbAggrVetCaseMTX mtx_vc{0} on mtx_vc{0}.idfVersion = ac{0}.idfVersion
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000019) D{0} on D{0}.idfsReference = mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosis trt_diag{0} on trt_diag{0}.idfsDiagnosis =  mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.tlbPerson eb_p{0} on eb_p{0}.idfPerson = ac{0}.idfEnteredByPerson
LEFT JOIN dbo.tlbOffice eb_o{0} on eb_o{0}.idfOffice = ac{0}.idfEnteredByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) eb_org_abbr{0} on  eb_org_abbr{0}.idfsReference = eb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) eb_org{0} on  eb_org{0}.idfsReference = eb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson sb_p{0} on sb_p{0}.idfPerson = ac{0}.idfSentByPerson
LEFT JOIN dbo.tlbOffice sb_o{0} on sb_o{0}.idfOffice = ac{0}.idfSentByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) sb_org_abbr{0} on  sb_org_abbr{0}.idfsReference = sb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) sb_org{0} on sb_org{0}.idfsReference = sb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson RBP{0} on RBP{0}.idfPerson = ac{0}.idfReceivedByPerson
LEFT JOIN dbo.tlbOffice rbo{0} on rbo{0}.idfOffice = ac{0}.idfReceivedByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) rb_org_abbr{0} on  rb_org_abbr{0}.idfsReference = rbo{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) rb_org{0} on rb_org{0}.idfsReference = rbo{0}.idfsOfficeName
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') loc{0} on loc{0}.idfsLocation = ac{0}.idfsAdministrativeUnit
LEFT JOIN dbo.tlbActivityParameters ap on ap.idfObservation = ac{0}.idfCaseObservation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000066) ffr{0} ON ffr{0}.idfsReference = ap{0}.idfsParameter
LEFT JOIN dbo.tlbAggrMatrixVersionHeader AMVH{0} ON AMVH{0}.idfVersion{0} = ac{0}.idfProphylacticVersion
{1}{)}', strExistenceCondition = N'ac{0}.idfsAggrCaseType = 10102003 AND ac{0}.intRowStatus = 0',strPKField='ac{0}.idfAggrCase'  where idfSearchTable = 4583090000120

update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.idfsAggrCaseType' where idfsSearchField = 10081267
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'trt_diag{0}.strIDC10' where idfsSearchField =10081269
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.idfsAggrCaseType' where idfsSearchField = 10081267
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'trt_diag{0}.strOIECode' where idfsSearchField =10081268
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'rbo{0}.strOrganizationID' where idfsSearchField = 10081273
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'rb_org{0}.name' where idfsSearchField = 10081274
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.strCaseID' where idfsSearchField = 10081265
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.datEnteredByDate' where idfsSearchField = 10081266
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.datReceivedByDate ' where idfsSearchField = 10081276
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.datFinishDate ' where idfsSearchField = 10081284
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.datStartDate' where idfsSearchField = 10081285
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.datSentByDate ' where idfsSearchField = 10081280
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'dbo.fnConcatFullName(eb_p{0}.strFamilyName, eb_p{0}.strFirstName, eb_p{0}.strSecondName)' where idfsSearchField = 10081270
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField = 10081275
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.datSentByDate ' where idfsSearchField = 10081280
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'eb_org_abbr{0}.name' where idfsSearchField = 10081271
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'eb_o{0}.strOrganizationID ' where idfsSearchField = 10081272   --o_ent_hc{0}.strOrganizationID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField = 10081275
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'sb_o{0}.strOrganizationID' where idfsSearchField = 10081277
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'sb_org{0}.name' where idfsSearchField = 10081278
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'dbo.fnConcatFullName(sb_p{0}.strFamilyName, sb_p{0}.strFirstName, sb_p{0}.strSecondName)' where idfsSearchField = 10081279
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'loc.AdminLevel3Name' where idfsSearchField = 10081281
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'loc{0}.AdminLevel2Name' where idfsSearchField = 10081282
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'loc{0}.AdminLevel4Name' where idfsSearchField = 10081288
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField = 10081275
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'sb_o{0}.strOrganizationID' where idfsSearchField = 10081277
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'sb_org{0}.idfsReference' where idfsSearchField = 10081278
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'dbo.fnConcatFullName(sb_p{0}.strFamilyName, sb_p{0}.strFirstName, sb_p{0}.strSecondName)' where idfsSearchField = 10081279
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'loc.AdminLevel3Name' where idfsSearchField = 10081281
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'loc{0}.AdminLevel2Name' where idfsSearchField = 10081282
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'loc{0}.AdminLevel4Name' where idfsSearchField = 10081288
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081283
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081286
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081287
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.idfsAdministrativeUnit' where idfsSearchField =10081264
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081289
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081290
update tasFieldSourceForTable set idfUnionSearchTable =4583090000120, idfSearchTable = 4583090000120, strFieldText = N'ac{0}.idfsAdministrativeUnit' where idfsSearchField =10081291

/*For Layout to work*/
 update tasFieldSourceForTable set strFieldText =N'loc{0}.AdminLevel4ID' where idfsSearchField = 10081288
 update tasFieldSourceForTable set strFieldText =N'eb_org_abbr{0}.idfsReference' where idfsSearchField = 10081271
 update tasFieldSourceForTable set strFieldText =N'rb_org{0}.idfsReference' where idfsSearchField = 10081274
 update tasFieldSourceForTable set strFieldText =N'sb_org{0}.idfsReference' where idfsSearchField = 10081278
 update tasFieldSourceForTable set strFieldText =N'loc{0}.AdminLevel2ID' where idfsSearchField = 10081282
 update tasFieldSourceForTable set strFieldText =N'loc.AdminLevel3ID' where idfsSearchField = 10081281
 
 /*Vet Aggregate Investigation Actions*/
 insert into tasMainTableForObject  (idfMainSearchTable, idfMandatorySearchTable,   idfsSearchObject, SourceSystemNameID)
Values(4583090000132,4583090000132,10082069,10519002)
Delete from tasMainTableForObject where idfsSearchObject = 10082069 and idfMainSearchTable =4583090000120

ALTER TABLE dbo.tasSearchTable ENABLE TRIGGER ALL
Select * from tasSearchTable where idfSearchTable = 4583090000132
update tasSearchTable set strFrom=N'{(}    dbo.tlbAggrCase ac{0}
LEFT JOIN dbo.tlbAggrVetCaseMTX mtx_vc{0} on mtx_vc{0}.idfVersion = ac{0}.idfVersion
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000019) D{0} on D{0}.idfsReference = mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosis trt_diag{0} on trt_diag{0}.idfsDiagnosis =  mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.tlbPerson eb_p{0} on eb_p{0}.idfPerson = ac{0}.idfEnteredByPerson
LEFT JOIN dbo.tlbOffice eb_o{0} on eb_o{0}.idfOffice = ac{0}.idfEnteredByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) eb_org_abbr{0} on  eb_org_abbr{0}.idfsReference = eb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) eb_org{0} on  eb_org{0}.idfsReference = eb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson sb_p{0} on sb_p{0}.idfPerson = ac{0}.idfSentByPerson
LEFT JOIN dbo.tlbOffice sb_o{0} on sb_o{0}.idfOffice = ac{0}.idfSentByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) sb_org_abbr{0} on  sb_org_abbr{0}.idfsReference = sb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) sb_org{0} on sb_org{0}.idfsReference = sb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson RBP{0} on RBP{0}.idfPerson = ac{0}.idfReceivedByPerson
LEFT JOIN dbo.tlbOffice rbo{0} on rbo{0}.idfOffice = ac{0}.idfReceivedByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) rb_org_abbr{0} on  rb_org_abbr{0}.idfsReference = rbo{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) rb_org{0} on rb_org{0}.idfsReference = rbo{0}.idfsOfficeName
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') loc{0} on loc{0}.idfsLocation = ac{0}.idfsAdministrativeUnit
LEFT JOIN dbo.tlbActivityParameters ap{0} on ap{0}.idfObservation = ac{0}.idfCaseObservation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000066) ffr{0} ON ffr{0}.idfsReference = ap{0}.idfsParameter
LEFT JOIN dbo.tlbAggrMatrixVersionHeader AMVH{0} ON AMVH{0}.idfVersion{0} = ac{0}.idfVersion
LEFT JOIN dbo.trtDiagnosis diag{0} on diag{0}.idfsDiagnosis = mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosisAgeGroupToDiagnosis diagag{0} on diagag{0}.idfsDiagnosis = diag{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosisAgeGroup dag{0} on dag{0}.idfsDiagnosisAgeGroup = diagag{0}.idfsDiagnosisAgeGroup 
{1}{)}', strExistenceCondition = N'ac{0}.idfsAggrCaseType = 10102003 AND ac{0}.intRowStatus = 0' where idfSearchTable = 4583090000132

update tasSearchField set idfsSearchFieldType = 10081007 where idfsSearchField = 10081222
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'eb_o{0}.idfsOfficeName' where idfsSearchField =10081216
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'rbo{0}.idfsOfficeName' where idfsSearchField =10081217
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'rb_org{0}.idfsReference' where idfsSearchField =10081218
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'sb_o{0}.idfsOfficeName' where idfsSearchField =10081221
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'sb_org{0}.idfsReference' where idfsSearchField =10081222
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'loc{0}.AdminLevel4ID' where idfsSearchField =10081232
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'loc{0}.AdminLevel3ID' where idfsSearchField =10081225
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'loc{0}.AdminLevel2ID' where idfsSearchField =10081226
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.strCaseID ' where idfsSearchField =10081208 --	sflVAIA_CaseID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datEnteredByDate' where idfsSearchField =10081209 --	sflVAIA_DateOfEntry
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'mtx_vc{0}.idfsDiagnosis' where idfsSearchField =10081212 --	sflVAIA_FinalDiagnosis
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'dbo.fnConcatFullName(eb_p{0}.strFamilyName, eb_p{0}.strFirstName, eb_p{0}.strSecondName)' where idfsSearchField =10081214 --	sflVAIA_EnteredByPerson
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.idfsSite' where idfsSearchField =10081215 --	sflVAIA_SiteID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'eb_o{0}.strOrganizationID' where idfsSearchField =10081216 --	sflVAIA_EnteredByOrganizationID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.idfsAggrCaseType' where idfsSearchField =10081210 --	sflVAIA_InvestigationType
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'rbo{0}.strOrganizationID ' where idfsSearchField =10081217 --	sflVAIA_ReceiveByInstitutionID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'rb_org{0}.name' where idfsSearchField =10081218 --	sflVAIA_ReceivedByInst
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'dbo.fnConcatFullName(RBP{0}.strFamilyName, RBP{0}.strFirstName, RBP{0}.strSecondName)' where idfsSearchField =10081219 --	sflVAIA_ReceivedByOfficer
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datReceivedByDate ' where idfsSearchField =10081220 --	sflVAIA_NotificationReceivDate
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'sb_o{0}.strOrganizationID' where idfsSearchField =10081221 --	sflVAIA_SentByInstitutionID
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'sb_org{0}.name ' where idfsSearchField =10081222 --	sflVAIA_SentByInstitution
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'dbo.fnConcatFullName(sb_p{0}.strFamilyName, sb_p{0}.strFirstName, sb_p{0}.strSecondName)' where idfsSearchField =10081223 --	sflVAIA_SentByOfficer
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datSentByDate ' where idfsSearchField =10081224 --	sflVAIA_NotificationSentDate
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'trt_diag{0}.strOIECode' where idfsSearchField =10081213 --	sflVAIA_OIAcode
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'loc.AdminLevel3Name' where idfsSearchField =10081225 --	sflVAIA_Rayon
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'loc{0}.AdminLevel2Name' where idfsSearchField =10081226 --	sflVAIA_Region
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'loc{0}.AdminLevel4Name' where idfsSearchField =10081232 --	sflVAIA_Settlement
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'mtx_vc{0}.idfsSpeciesType' where idfsSearchField =10081211 --	sflVAIA_AnimalSpecies
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datFinishDate ' where idfsSearchField =10081228 --	sflVAIA_EndDate
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datStartDate ' where idfsSearchField =10081229 --	sflVAIA_StartDate
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datStartDate ' where idfsSearchField =10081230 --	sflVAIA_TimeIntervalUnit
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datStartDate ' where idfsSearchField =10081231 --	sflVAIA_Total
update tasFieldSourceForTable set idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, strFieldText = N'ac{0}.datStartDate ' where idfsSearchField =10081227 --	sflVAIA_GroupingDate

update tasFieldSourceForTable set 	strFieldText = N'loc.AdminLevel3ID' where idfsSearchField = 10081225
update tasFieldSourceForTable set	strFieldText = N'	loc{0}.AdminLevel2ID' where idfsSearchField = 10081226
update tasFieldSourceForTable set 	strFieldText = N'	loc{0}.AdminLevel4ID' where idfsSearchField = 10081232
update tasFieldSourceForTable set	strFieldText = N'rb_org{0}.idfsReference' where idfsSearchField = 10081218
update tasFieldSourceForTable set 	strFieldText = N'sb_org{0}.idfsReference ' where idfsSearchField = 10081222
update tasFieldSourceForTable set	strFieldText = N'dag{0}.idfsAgeType' where idfsSearchField = 10081230
update tasFieldSourceForTable set 	strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081227
update tasFieldSourceForTable set  idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132, 	strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081233
update tasFieldSourceForTable set  idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132,	strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081234
update tasFieldSourceForTable set  idfUnionSearchTable =4583090000132, idfSearchTable = 4583090000132,	strFieldText = N'ap{0}.varValue' where idfsSearchField = 10081235
update tasFieldSourceForTable set idfUnionSearchTable=4583090000132,idfSearchTable=4583090000132, strFieldText = 'ac{0}.idfsAdministrativeUnit', AuditUpdateDTM=GETDATE() where idfsSearchField = 10081207

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
(   10081233,         -- idfsSearchField - bigint
    4583090000132,         -- idfUnionSearchTable - bigint
    4583090000132,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081234,         -- idfsSearchField - bigint
    4583090000132,         -- idfUnionSearchTable - bigint
    4583090000132,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081235,         -- idfsSearchField - bigint
    4583090000132,         -- idfUnionSearchTable - bigint
    4583090000132,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
Delete from tasSearchObjectToSearchObject where idfsRelatedSearchObject in (
10082071
,10082072
,10082073
,10082074) and idfsParentSearchObject = 10082069
ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL



	/*REMAINING */
update tasFieldSourceForTable set strFieldText ='as_cam{0}.idfCampaign' where idfsSearchField = 10081315
update tasFieldSourceForTable set strFieldText ='as_cam{0}.idfsCampaignType' where idfsSearchField = 10081317
update tasFieldSourceForTable set strFieldText ='eb_o{0}.idfsOfficeName ' where idfsSearchField = 10081245
update tasFieldSourceForTable set strFieldText ='rbo{0}.idfsOfficeName ' where idfsSearchField = 10081246
update tasFieldSourceForTable set strFieldText ='rb_org{0}.idfsReference ' where idfsSearchField = 10081247
update tasFieldSourceForTable set strFieldText ='sb_org{0}.idfsReference  ' where idfsSearchField = 10081250
update tasFieldSourceForTable set strFieldText ='loc{0}.AdminLevel3ID ' where idfsSearchField = 10081253
update tasFieldSourceForTable set strFieldText ='loc{0}.AdminLevel2ID' where idfsSearchField = 10081254
update tasFieldSourceForTable set strFieldText ='loc{0}.AdminLevel4ID' where idfsSearchField = 10081260
update tasFieldSourceForTable set strFieldText ='eb_org_abbr{0}.idfsReference' where idfsSearchField = 10081244


/*Vet Aggregate DISEASE REPORT*   4583090000144 */

EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint
begin transaction D_10082067_4583090000039
Delete from tasMainTableForObject where idfsSearchObject =10082067 and  idfMainSearchTable = 4583090000039 and idfMandatorySearchTable = 4583090000044
COMMIT	

ALTER TABLE dbo.tasMainTableForObject DISABLE TRIGGER ALL
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
(   4583090000144,--@idfSearchTable,         -- idfSearchTable - bigint
    N'',           -- strTableName - nvarchar(200) 
   N'{(}    dbo.tlbAggrCase ac{0}
LEFT JOIN dbo.tlbAggrVetCaseMTX mtx_vc{0} on mtx_vc{0}.idfVersion = ac{0}.idfVersion
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000019) D{0} on D{0}.idfsReference = mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosis trt_diag{0} on trt_diag{0}.idfsDiagnosis =  mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.tlbPerson eb_p{0} on eb_p{0}.idfPerson = ac{0}.idfEnteredByPerson
LEFT JOIN dbo.tlbOffice eb_o{0} on eb_o{0}.idfOffice = ac{0}.idfEnteredByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) eb_org_abbr{0} on  eb_org_abbr{0}.idfsReference = eb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) eb_org{0} on  eb_org{0}.idfsReference = eb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson sb_p{0} on sb_p{0}.idfPerson = ac{0}.idfSentByPerson
LEFT JOIN dbo.tlbOffice sb_o{0} on sb_o{0}.idfOffice = ac{0}.idfSentByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) sb_org_abbr{0} on  sb_org_abbr{0}.idfsReference = sb_o{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) sb_org{0} on sb_org{0}.idfsReference = sb_o{0}.idfsOfficeName
LEFT JOIN dbo.tlbPerson RBP{0} on RBP{0}.idfPerson = ac{0}.idfReceivedByPerson
LEFT JOIN dbo.tlbOffice rbo{0} on rbo{0}.idfOffice = ac{0}.idfReceivedByOffice
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000045) rb_org_abbr{0} on  rb_org_abbr{0}.idfsReference = rbo{0}.idfsOfficeAbbreviation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000046) rb_org{0} on rb_org{0}.idfsReference = rbo{0}.idfsOfficeName
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') loc{0} on loc{0}.idfsLocation = ac{0}.idfsAdministrativeUnit
LEFT JOIN dbo.tlbActivityParameters ap{0} on ap{0}.idfObservation = ac{0}.idfCaseObservation
LEFT JOIN dbo.FN_GBL_ReferenceRepair_GET(''en-us'', 19000066) ffr{0} ON ffr{0}.idfsReference = ap{0}.idfsParameter
LEFT JOIN dbo.tlbAggrMatrixVersionHeader AMVH{0} ON AMVH{0}.idfVersion{0} = ac{0}.idfVersion
LEFT JOIN dbo.trtDiagnosis diag{0} on diag{0}.idfsDiagnosis = mtx_vc{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosisAgeGroupToDiagnosis diagag{0} on diagag{0}.idfsDiagnosis = diag{0}.idfsDiagnosis
LEFT JOIN dbo.trtDiagnosisAgeGroup dag{0} on dag{0}.idfsDiagnosisAgeGroup = diagag{0}.idfsDiagnosisAgeGroup 
{1}{)}',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'ac.idfAggrCase',        -- strPKField - varchar(200)
    N'ac{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)
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
(   10082067,         -- idfsSearchObject - bigint
    4583090000144,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4583090000144,         -- idfMandatorySearchTable - bigint
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
(   10081179,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.idfsAdministrativeUnit',       -- strFieldText - nvarchar(2000)
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
(   10081180,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.strCaseID',       -- strFieldText - nvarchar(2000)
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
(   10081181,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.datEnteredByDate',       -- strFieldText - nvarchar(2000)
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
(   10081182,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'mtx_vc{0}.idfsDiagnosis',       -- strFieldText - nvarchar(2000)
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
(   10081183,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'trt_diag{0}.blnZoonotic',       -- strFieldText - nvarchar(2000)
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
(   10081184,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'trt_diag{0}.strOIECode',       -- strFieldText - nvarchar(2000)
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
(   10081185,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'dbo.fnConcatFullName(eb_p{0}.strFamilyName, eb_p{0}.strFirstName, eb_p{0}.strSecondName)',       -- strFieldText - nvarchar(2000)
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
(   10081186,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.idfsSite',       -- strFieldText - nvarchar(2000)
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
(   10081187,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'eb_o{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10081188,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'rbo{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10081189,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'rb_org{0}.idfsReference',       -- strFieldText - nvarchar(2000)
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
(   10081190,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'rb_org{0}.idfsReference',       -- strFieldText - nvarchar(2000)
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
(   10081191,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.datReceivedByDate ',       -- strFieldText - nvarchar(2000)
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
(   10081192,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'sb_o{0}.idfsOfficeName',       -- strFieldText - nvarchar(2000)
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
(   10081193,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'sb_org{0}.idfsReference',       -- strFieldText - nvarchar(2000)
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
(   10081194,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.datSentByDate ',       -- strFieldText - nvarchar(2000)
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
(   10081195,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.datSentByDate',       -- strFieldText - nvarchar(2000)
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
(   10081196,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'loc.AdminLevel3ID ',       -- strFieldText - nvarchar(2000)
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
(   10081197,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'loc{0}.AdminLevel2ID',       -- strFieldText - nvarchar(2000)
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
(   10081198,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081199,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.datFinishDate',       -- strFieldText - nvarchar(2000)
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
(   10081200,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ac{0}.datStartDate',       -- strFieldText - nvarchar(2000)
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
(   10081201,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081202,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081203,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'loc{0}.AdminLevel4ID',       -- strFieldText - nvarchar(2000)
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
(   10081204,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081205,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
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
(   10081206,         -- idfsSearchField - bigint
    4583090000144,         -- idfUnionSearchTable - bigint
    4583090000144,         -- idfSearchTable - bigint
    N'ap{0}.varValue',       -- strFieldText - nvarchar(2000)
    NEWID(),      -- rowguid - uniqueidentifier
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

update tasSearchTable set strFrom=N'{(}    dbo.tlbOutbreak outb{0} 
LEFT JOIN dbo.tlbGeoLocation gl{0}													ON outb{0}.idfGeoLocation = gl{0}.idfGeoLocation
LEFT JOIN dbo.gisLocation g{0}														ON g{0}.idfsLocation = gl{0}.idfsLocation
LEFT JOIN FN_GBL_LocationHierarchy_Flattened(''en-us'') outbLH{0}						 ON outbLH{0}.idfsLocation = g{0}.idfsLocation
INNER JOIN	dbo.FN_GBL_Repair(''en-us'', 19000019) D{0}								ON	D{0}.idfsReference = outb{0}.idfsDiagnosisOrDiagnosisGroup
INNER JOIN	dbo.FN_GBL_Repair(''en-us'',19000063) os{0}								ON	os{0}.idfsReference = outb{0}.idfsOutbreakStatus
INNER JOIN	dbo.FN_GBL_Repair(''en-us'',19000513) ot{0}								ON	ot{0}.idfsReference = outb{0}.OutbreakTypeId
LEFT JOIN	dbo.tlbStreet st{0}														ON st{0}.idfsLocation = gl{0}.idfsLocation AND st{0}.strStreetName = gl{0}.strStreetName
LEFT JOIN	dbo.tlbPostalCode pc{0}													ON pc{0}.idfsLocation = gl{0}.idfsLocation AND pc{0}.strPostCode = gl{0}.strPostCode
inner join OutbreakSpeciesParameter Species{0}										ON Species{0}.idfOutbreak = outb{0}.idfOutbreak
inner join FN_GBL_ReferenceRepair(''en-us'', 19000514) SA{0}						ON SA{0}.idfsReference = Species{0}.OutbreakSpeciesTypeID
inner join OutbreakCaseReport OCR{0}
on OCR{0}.idfOutbreak = outb{0}.idfOutbreak
inner join OutbreakCaseContact OCC{0}
on OCC{0}.OutBreakCaseReportUID = OCR{0}.OutbreakCaseReportUID
LEFT JOIN tlbHumanCase hc{0} on hc{0}.idfHumanCase = OCR{0}.idfHumanCase
LEFT JOIN tlbVetCase  vc{0} ON vc{0}.idfVetCase = OCR{0}.idfVetCase
LEFT JOIN dbo.tlbHuman h{0} ON h{0}.idfHuman = occ{0}.idfHuman
LEFT JOIN FN_GBL_LocationHierarchy_Flattened(''en-us'') hcLH{0}						 ON hcLH{0}.idfsLocation = h{0}.idfCurrentResidenceAddress
LEFT JOIN dbo.HumanActualAddlInfo haai{0} ON haai{0}.HumanActualAddlInfoUID = h{0}.idfHumanActual
LEFT JOIN dbo.tlbFarm f{0}  ON f{0}.idfHuman = occ{0}.idfHuman 
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000043) gender{0} ON gender{0}.idfsReference = h{0}.idfsHumanGender
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000054) citizenshipType{0} ON citizenshipType{0}.idfsReference = h{0}.idfsNationality
LEFT JOIN dbo.tlbGeoLocation geo{0} ON h{0}.idfCurrentResidenceAddress = geo{0}.idfGeoLocation
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') lh{0} ON lh{0}.idfsLocation = geo{0}.idfsLocation
LEFT JOIN dbo.gisLocation settlement{0} ON settlement{0}.idfsLocation = geo{0}.idfsLocation AND settlement{0}.idfsType IS NOT NULL
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000516) contactType{0}  ON contactType{0}.idfsReference = occ{0}.ContactTypeID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000517) contactStatusType{0} ON contactStatusType{0}.idfsReference = occ{0}.ContactStatusID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000014) contactRelationshipType{0} ON contactRelationshipType{0}.idfsReference = occ{0}.ContactRelationshipTypeID
LEFT JOIN tlbVectorSurveillanceSession vec{0} on vec{0}.idfOutbreak = outb{0}.idfOutbreak
LEFT JOIN dbo.tlbGeoLocation geovec{0} ON  geovec{0}.idfGeoLocation = vec{0}.idfLocation  
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-Us'') vec_lh{0} ON vec_lh{0}.idfsLocation = geovec{0}.idfsLocation
Left Join tlbMonitoringSession asms{0} on asms{0}.idfMonitoringSession = hc{0}.idfParentMonitoringSession
{1} {)}' where idfSearchTable = 4583090000143

update tasSearchField set strSearchFieldAlias  = 'sflOutbreakC_ID' where idfsSearchField = 10080892
update tasSearchField set strSearchFieldAlias  = 'sflOSC_Status' where idfsSearchField = 10080895
update tasSearchField set strSearchFieldAlias  = 'sflOSC_Type' where idfsSearchField = 10080894
update tasSearchField set strSearchFieldAlias  = 'sflOutbreak_LocationRayonV' where idfsSearchField = 10080917
update tasSearchField set strSearchFieldAlias  = 'sflOutbreak_LocationRegionV' where idfsSearchField = 10080916
update tasSearchField set strSearchFieldAlias  = 'sflHASS_EnteredDateT' where idfsSearchField = 10080991
update tasFieldSourceForTable set strFieldText = 'outb{0}.idfsDiagnosisOrDiagnosisGroup'  where idfSearchTable = 4583090000143 and idfsSearchField  = 10080887 
update tasFieldSourceForTable set strFieldText = 'ac{0}.idfsAdministrativeUnit'  where idfSearchTable = 4583090000144 and idfsSearchField  = 10081179 
update tasFieldSourceForTable set strFieldText = 'Hospitalization{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  = 10080941
update tasFieldSourceForTable set strFieldText = 'm{0}.idfSendToOffice'  where idfSearchTable = 4583090000123 and idfsSearchField  = 10080979
update tasFieldSourceForTable set strFieldText = 'InvestigateByOfficeRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080952
update tasFieldSourceForTable set strFieldText = 'InvestigateByOfficeRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080941
update tasFieldSourceForTable set strFieldText = 'ReceivedByOfficeRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080939
update tasFieldSourceForTable set strFieldText = 'SentByOfficeRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080938
update tasFieldSourceForTable set strFieldText = 'SettlementRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080970  
update tasFieldSourceForTable set strFieldText = 'RegionRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080968
update tasFieldSourceForTable set strFieldText = 'RayonRef{0}.idfsReference'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080969
update tasFieldSourceForTable set strFieldText = 'initialSyndromicSurveielanceDiseases{0}.blnZoonotic'  where idfSearchTable = 4583090000123 and idfsSearchField  =10080993
UPDATE tasFieldSourceForTable SET strFieldText = 'as_cam_to_dg{0}.idfsDiagnosis' WHERE idfsSearchField = 10080843 and idfSearchTable = 4582560000000 and idfUnionSearchTable = 4582550000000
Update tasSearchField set strSearchFieldAlias = 'sflASSession_DiagnosesString' where idfsSearchField = 10080843 and strSearchFieldAlias ='sflHASS_Diseases'
Update   tasSearchTable  set strPKField =N'ac{0}.idfAggrCase' where idfSearchTable = 4583090000132

/* Outbreak Veterinary  4583090000145*/

EXEC dbo.USP_GBL_NEXTKEYID_GET @tableName = 'tasSearchTable',           -- varchar(100)
                               @idfsKey = @idfSearchTable OUTPUT        -- bigint


/*Step 1. Insert into tasSearchTable, these values come from tasSearchTable look for similar values to find what you are looking for. */
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
(   4583090000145,--@idfSearchTable,         -- idfSearchTable - bigint
    N'Outbreak Veterinary Case',           -- strTableName - nvarchar(200) 
    N'{(}    dbo.tlbOutbreak outb{0} 
LEFT JOIN dbo.tlbGeoLocation gl{0}													ON outb{0}.idfGeoLocation = gl{0}.idfGeoLocation
LEFT JOIN dbo.gisLocation g{0}														ON g{0}.idfsLocation = gl{0}.idfsLocation
LEFT JOIN FN_GBL_LocationHierarchy_Flattened(''en-us'') outbLH{0}						 ON outbLH{0}.idfsLocation = g{0}.idfsLocation
INNER JOIN	dbo.FN_GBL_Repair(''en-us'', 19000019) D{0}								ON	D{0}.idfsReference = outb{0}.idfsDiagnosisOrDiagnosisGroup
INNER JOIN	dbo.FN_GBL_Repair(''en-us'',19000063) os{0}								ON	os{0}.idfsReference = outb{0}.idfsOutbreakStatus
INNER JOIN	dbo.FN_GBL_Repair(''en-us'',19000513) ot{0}								ON	ot{0}.idfsReference = outb{0}.OutbreakTypeId
LEFT JOIN	dbo.tlbStreet st{0}														ON st{0}.idfsLocation = gl{0}.idfsLocation AND st{0}.strStreetName = gl{0}.strStreetName
LEFT JOIN	dbo.tlbPostalCode pc{0}													ON pc{0}.idfsLocation = gl{0}.idfsLocation AND pc{0}.strPostCode = gl{0}.strPostCode
inner join OutbreakSpeciesParameter outb_sp_p{0}										ON outb_sp_p{0}.idfOutbreak = outb{0}.idfOutbreak
inner join FN_GBL_ReferenceRepair(''en-us'', 19000514) SA{0}						ON SA{0}.idfsReference = outb_sp_p{0}.OutbreakSpeciesTypeID
inner join OutbreakCaseReport OCR{0}
on OCR{0}.idfOutbreak = outb{0}.idfOutbreak
inner join OutbreakCaseContact OCC{0}
on OCC{0}.OutBreakCaseReportUID = OCR{0}.OutbreakCaseReportUID
LEFT JOIN tlbHumanCase hc{0} on hc{0}.idfHumanCase = OCR{0}.idfHumanCase
LEFT JOIN tlbVetCase  vc{0} ON vc{0}.idfVetCase = OCR{0}.idfVetCase
LEFT JOIN dbo.tlbHuman h{0} ON h{0}.idfHuman = occ{0}.idfHuman
LEFT JOIN FN_GBL_LocationHierarchy_Flattened(''en-us'') hcLH{0}						 ON hcLH{0}.idfsLocation = h{0}.idfCurrentResidenceAddress
LEFT JOIN dbo.HumanActualAddlInfo haai{0} ON haai{0}.HumanActualAddlInfoUID = h{0}.idfHumanActual
LEFT JOIN dbo.tlbFarm f{0}  ON f{0}.idfHuman = occ{0}.idfHuman 
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000043) gender{0} ON gender{0}.idfsReference = h{0}.idfsHumanGender
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000054) citizenshipType{0} ON citizenshipType{0}.idfsReference = h{0}.idfsNationality
LEFT JOIN dbo.tlbGeoLocation geo{0} ON h{0}.idfCurrentResidenceAddress = geo{0}.idfGeoLocation
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-us'') lh{0} ON lh{0}.idfsLocation = geo{0}.idfsLocation
LEFT JOIN dbo.gisLocation settlement{0} ON settlement{0}.idfsLocation = geo{0}.idfsLocation AND settlement{0}.idfsType IS NOT NULL
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000516) contactType{0}  ON contactType{0}.idfsReference = occ{0}.ContactTypeID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000517) contactStatusType{0} ON contactStatusType{0}.idfsReference = occ{0}.ContactStatusID
LEFT JOIN dbo.FN_GBL_Reference_GetList(''en-us'', 19000014) contactRelationshipType{0} ON contactRelationshipType{0}.idfsReference = occ{0}.ContactRelationshipTypeID
LEFT JOIN tlbVectorSurveillanceSession vec{0} on vec{0}.idfOutbreak = outb{0}.idfOutbreak
LEFT JOIN dbo.tlbGeoLocation geovec{0} ON  geovec{0}.idfGeoLocation = vec{0}.idfLocation  
LEFT JOIN dbo.FN_GBL_LocationHierarchy_Flattened(''en-Us'') vec_lh{0} ON vec_lh{0}.idfsLocation = geovec{0}.idfsLocation
Left JOIN tlbBasicSyndromicSurveillance bss{0}  on bss{0}.idfHuman = vc{0}.idfVetCase
Left Join tlbMonitoringSession asms{0} on asms{0}.idfMonitoringSession = vc{0}.idfParentMonitoringSession
LEFT JOIN trtDiagnosis diagnosis{0} on diagnosis{0}.idfsDiagnosis = vc{0}.idfsFinalDiagnosis
LEFT JOIN tlbActivityParameters hcs_ap{0}  on hcs_ap{0}.idfObservation = vc{0}.idfObservation 
Left JOIN tlbAnimal Animal{0} on 1=1
Left Join tlbSpecies Species{0} on Species{0}.idfSpecies = Animal{0}.idfSpecies
LEFT JOIN tlbHerd Herd{0} on Herd{0}.idfFarm = f{0}.idfFarm
LEFT JOIN tlbVaccination Vaccination{0} on Vaccination{0}.idfVetCase = vc{0}.idfVetCase
LEFT JOIN tlbTesting test{0} on test.idfVetCase = vc{0}.idfVetCase
LEFT JOIN tlbMaterial s{0} on s{0}.idfMaterial = test{0}.idfMaterial
RIGHT  JOIN tlbPerson p_inv_vc{0} on p_inv_vc{0} .idfPerson = vc{0} .idfPersonInvestigatedBy
{1} {)}',       -- strFrom - nvarchar(max)
    3,         -- intTableCount - int
    1,      -- blnPrimary - bit
    NEWID(),      -- rowguid - uniqueidentifier
    'vc{0}.idfVetCase',        -- strPKField - varchar(200)
    N'vc{0}.intRowStatus = 0',        -- strExistenceCondition - varchar(200)
    N'',       -- strReservedAttribute - nvarchar(max)
    10519001,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)

	
/* Step 4. Insert into tasMainTableForObject */
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
    4583090000145,         -- idfMainSearchTable - bigint
    NEWID(),      -- rowguid - uniqueidentifier
    4583090000145,         -- idfMandatorySearchTable - bigint
    N'',       -- strReservedAttribute - nvarchar(max)
    10519002,         -- SourceSystemNameID - bigint
    N'',       -- SourceSystemKeyValue - nvarchar(max)
    N'',       -- AuditCreateUser - nvarchar(200)
    GETDATE(), -- AuditCreateDTM - datetime
    N'',       -- AuditUpdateUser - nvarchar(200)
    GETDATE()  -- AuditUpdateDTM - datetime
	)




insert into tasFieldSourceForTable (
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
Select 
    idfsSearchField,
    4583090000145,
    4583090000145,
    strFieldText,
    NEWID(),
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    GETDATE(),
    AuditUpdateUser,
    GETDATE()
	from tasFieldSourceForTable  where idfsSearchField in (

10081110
,10081119
,10081118
,10081101
,10081100
,10081108
,10081111
,10081109
,10081107
,10080998
,10081115
,10081114
,10081105
,10081106
,10081113
,10081112
,10081120
,10080997
,10080995
,10080996
,10081117
,10081103
,10081102
,10081104
,10081116
,10081121
,10080999
	)







update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.ContactStatusID'				    where idfsSearchField =10081154
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.ContactRelationshipTypeID'		where idfsSearchField =10081151
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cch{0}.datDateofBirth'					where idfsSearchField =10081162
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.DateOfLastContact'				where idfsSearchField =10081156
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cf{0}.idfFarm'							where idfsSearchField =10081153
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cch{0}.idfsHumanGender'					where idfsSearchField =10081161
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cch{0}.strPersonID'						where idfsSearchField =10081152
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.PlaceOfLastContact'				where idfsSearchField =10081157
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cc_gn{0}.Level3Name'					where idfsSearchField =10081159
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cc_gn{0}.Level2Name'					where idfsSearchField =10081158
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.ContactRelationshipTypeID'		where idfsSearchField =10081155
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cc_gn{0}.Level4Name'					where idfsSearchField =10081160
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='datediff(year,getDate(),cch{0}.datDateofBirth)' where idfsSearchField =10081163
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081139
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081143
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081137
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081141
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081135
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081136
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081142
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081138
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081146
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081140
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081133
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081134
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081145
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081144
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081149
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081150
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081148
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081147
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081166
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081168
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081170
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081169
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081165
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081164
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081171
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081167
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081175
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081173
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081177
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081178
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081172
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081174
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081176
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081175
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081173
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081177
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081178
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081172
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081174
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField= 10081176
update tasFieldSourceForTable set strFieldText =N'vc{0}.strCaseID'  WHERE idfUnionSearchTable = 4583090000145 AND idfSearchTable =4583090000145 AND idfsSearchField= 10081117
update tasFieldSourceForTable set strFieldText =N'hcs_ap{0}.varValue'  WHERE idfUnionSearchTable = 4583090000145 AND idfSearchTable =4583090000145 AND idfsSearchField= 10081118
update tasFieldSourceForTable set strFieldText =N'vc{0}.idfParentMonitoringSession'  WHERE idfUnionSearchTable = 4583090000145 AND idfSearchTable =4583090000145 AND idfsSearchField= 10081119
update tasFieldSourceForTable set strFieldText =N'occ{0}.idfHuman'  WHERE idfUnionSearchTable = 4583090000145 AND idfSearchTable =4583090000145 AND idfsSearchField= 10081120
update tasFieldSourceForTable set strFieldText =N'hcs_ap{0}.varValue'  WHERE idfUnionSearchTable = 4583090000145 AND idfSearchTable =4583090000145 AND idfsSearchField= 10081136
update tasFieldSourceForTable set strFieldText =N'Animal{0}.idfsYNClinicalSigns'  WHERE idfUnionSearchTable = 4583090000145 AND idfSearchTable =4583090000145 AND idfsSearchField= 10081143





update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.ContactStatusID'				    where idfsSearchField =10081154
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.ContactRelationshipTypeID'		where idfsSearchField =10081151
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cch{0}.datDateofBirth'					where idfsSearchField =10081162
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.DateOfLastContact'				where idfsSearchField =10081156
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cf{0}.idfFarm'							where idfsSearchField =10081153
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cch{0}.idfsHumanGender'					where idfsSearchField =10081161
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cch{0}.strPersonID'						where idfsSearchField =10081152
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.PlaceOfLastContact'				where idfsSearchField =10081157
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cc_gn{0}.Level3Name'					where idfsSearchField =10081159
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cc_gn{0}.Level2Name'					where idfsSearchField =10081158
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='occ{0}.ContactRelationshipTypeID'		where idfsSearchField =10081155
update tasFieldSourceForTable set idfUnionSearchTable ='4583090000145', idfSearchTable='4583090000145', strFieldText ='cc_gn{0}.Level4Name'					where idfsSearchField =10081160


insert into tasFieldSourceForTable (
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
Select 
    idfsSearchField,
    4583090000145,
    4583090000145,
    strFieldText,
    NEWID(),
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    GETDATE(),
    AuditUpdateUser,
    GETDATE()
	from tasFieldSourceForTable  where idfsSearchField in (
 10081132
,10081131
,10081130
,10081125
,10081122
,10081124
,10081123
,10081126
,10081129
,10081128
,10081127
)



update tasMainTableForObject set idfMainSearchTable =4583090000145, idfMandatorySearchTable = 4583090000145 where idfsSearchObject =  10082062
update tasMainTableForObject set idfMainSearchTable =4583090000145, idfMandatorySearchTable = 4583090000145 where idfsSearchObject =  10082063
update tasMainTableForObject set idfMainSearchTable =4583090000145, idfMandatorySearchTable = 4583090000145 where idfsSearchObject =  10082064
update tasMainTableForObject set idfMainSearchTable =4583090000145, idfMandatorySearchTable = 4583090000145 where idfsSearchObject =  10082065
update tasMainTableForObject set idfMainSearchTable =4583090000145, idfMandatorySearchTable = 4583090000145 where idfsSearchObject =  10082066



update tasFieldSourceForTable  set strFieldText ='outb{0}.strOutbreakID'																					 where idfsSearchField =10080995 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145 
update tasFieldSourceForTable  set strFieldText ='outb{0}.OutbreakTypeID'																					 where idfsSearchField =10080996 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='outb{0}.strOutbreakID'																					 where idfsSearchField =10080997 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='f{0}.strFarmCode'																						 where idfsSearchField =10080998 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.idfsCaseType'																						 where idfsSearchField =10080999 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='asms{0}.datEnteredDate'																					 where idfsSearchField =10081100 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.idfsCaseClassification'																			 where idfsSearchField =10081101 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145

update tasFieldSourceForTable  set strFieldText ='lh{0}.AdminLevel1ID'																					 where idfsSearchField =10081102 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='lh{0}.AdminLevel2ID'																					 where idfsSearchField =10081103 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='lh{0}.AdminLevel3ID'																					 where idfsSearchField =10081104 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145

update tasFieldSourceForTable  set strFieldText ='gl{0}.dblLatitude'																						 where idfsSearchField =10081105 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='gl{0}.dblLongitude'																						 where idfsSearchField =10081106 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.idfsFinalDiagnosis'																				 where idfsSearchField =10081107 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.datFinalDiagnosisDate'																			 where idfsSearchField =10081108 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='bss{0}.datDateOfSymptomsOnset'																			 where idfsSearchField =10081109 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='IsNull(hc{0}.idfsFinalCaseStatus, hc{0}.idfsInitialCaseStatus)'											 where idfsSearchField =10081110 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='hc{0}.datEnteredDate'																					 where idfsSearchField =10081111 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.idfReportedByOffice'																				 where idfsSearchField =10081112 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.idfReceivedByOffice'																				 where idfsSearchField =10081113 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='vc{0}.idfReceivedByOffice'																				 where idfsSearchField =10081114 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='dbo.fnConcatFullName(p_inv_vc{0}.strFamilyName, p_inv_vc{0}.strFirstName, p_inv_vc{0}.strSecondName)'	 where idfsSearchField =10081115 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='hc{0}.datInvestigationStartDate'																		 where idfsSearchField =10081116 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='(IsNull(diagnosis{0}.blnZoonotic, 0) * 10100001 + (1 - IsNull(diagnosis{0}.blnZoonotic, 0)) * 10100002)' where idfsSearchField =10081121 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Species{0}.idfsSpeciesType'																				 where idfsSearchField =10081133 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.idfsAnimalCondition'																			 where idfsSearchField =10081134 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='(IsNull(diagnosis{0}.blnZoonotic, 0) * 10100001 + (1 - IsNull(diagnosis{0}.blnZoonotic, 0)) * 10100002)' where idfsSearchField =10081135 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.strAnimalCode' 																				 where idfsSearchField =10081137 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Herd{0}.strHerdCode'																					 where idfsSearchField =10081138 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.idfsAnimalAge'																				 where idfsSearchField =10081139 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.idfsAnimalGender'																				 where idfsSearchField =10081140 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.idfsAnimalCondition' 																			 where idfsSearchField =10081141 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='hcs_ap{0}.varValue'																						 where idfsSearchField =10081142 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.strNote'																					 where idfsSearchField =10081144 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.datVaccinationDate'																		 where idfsSearchField =10081145 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.intNumberVaccinated'																		 where idfsSearchField =10081146 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.idfsVaccinationType'																		 where idfsSearchField =10081147 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.idfsVaccinationRoute'																	 where idfsSearchField =10081148 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.strLotNumber'																			 where idfsSearchField =10081149 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Vaccination{0}.strLotNumber'																			 where idfsSearchField =10081150 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='m{0}.idfsSampleType'																					 where idfsSearchField =10081164 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='m{0}.strFieldBarcode'																					 where idfsSearchField =10081165 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.strAnimalCode'																				 where idfsSearchField =10081166 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Species{0}.idfsSpeciesType'																				 where idfsSearchField =10081167 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='outb{0}.idfsOutbreakStatus'																				 where idfsSearchField =10081168 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='m{0}.datFieldCollectionDate'																			 where idfsSearchField =10081169 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='s{0}.datFieldCollectionDate'																			 where idfsSearchField =10081170 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='s{0}.idfFieldCollectedByOffice'																			 where idfsSearchField =10081171 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='s{0}.idfsSampleType'																					 where idfsSearchField =10081172 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='s{0}.strFieldBarcode'																					 where idfsSearchField =10081173 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Species{0}.idfsSpeciesType'																				 where idfsSearchField =10081174 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='Animal{0}.strAnimalCode'																				 where idfsSearchField =10081175 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='test{0}.idfsTestName'																					 where idfsSearchField =10081176 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='test{0}.idfsTestResult'																					 where idfsSearchField =10081177 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145
update tasFieldSourceForTable  set strFieldText ='isnull(test{0}.datConcludedDate, test.datStartedDate)'													 where idfsSearchField =10081178 AND idfUnionSearchTable =4583090000145 AND idfSearchTable =4583090000145


/*HERD FLOCK*/
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='herd{0}.strHerdCode' where idfsSearchField= 10081122 --Herd{0}.strHerdCode
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='case when isnumeric(cast(hcs_ap{0}.varValue as nvarchar)) = 1 then cast(cast(hcs_ap{0}.varValue as nvarchar) as int) else null end' where idfsSearchField=10081123 --case when isnumeric(cast(hcs_ap.varValue as nvarchar)) = 1 then cast(cast(hcs_ap.varValue as nvarchar) as int) else null end																													   10081131
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Herd{0}.intSickAnimalQty' where idfsSearchField=	 10081124 --Herd{0}.intSickAnimalQty																													   10081130
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Herd{0}.intDeadAnimalQty' where idfsSearchField=	 10081125 --Herd{0}.intDeadAnimalQty																													   10081125
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Species{0}.idfsSpeciesType' where idfsSearchField=	 10081126 --Species{0}.idfsSpeciesType 																													   10081122
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Species{0}.intTotalAnimalQty' where idfsSearchField=	 10081127 --Species{0}.intTotalAnimalQty																													   10081124
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Species{0}.intSickAnimalQty' where idfsSearchField=	 10081128 --Species{0}.intSickAnimalQty																													   10081123
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Species{0}.intDeadAnimalQty'  where idfsSearchField=	 10081129 --Species{0}.intDeadAnimalQty																													   10081126
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='case when isnumeric(cast(hcs_ap{0}.varValue as nvarchar)) = 1 then cast(cast(hcs_ap{0}.varValue as nvarchar) as int) else null end' where idfsSearchField=	 10081130 --case when isnumeric(cast(hcs_ap.varValue as nvarchar)) = 1 then cast(cast(hcs_ap.varValue as nvarchar) as int) else null end' where idfsSearchField=	 10081130 --case when isnumeric(cast(ap_Total.varValue as nvarchar)) = 1 then cast(cast(ap_Total.varValue as nvarchar) as int) else null end																													   10081129
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Species{0}.intSickAnimalQty' where idfsSearchField=	 10081131 --Species{0}.intSickAnimalQty																													   10081128
update tasFieldSourceForTable set idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145, strfieldText='Species{0}.intDeadAnimalQty' where idfsSearchField=	 10081132 --Species{0}.intDeadAnimalQty																													   10081127
update tasSearchField set strSearchFieldAlias='outb_sflVC_AnimalSpecies' where idfsSearchField =10081126
/*SAMPLES*/
update tasFieldSourceForTable set strFieldText ='s{0}.idfsSampleType', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=     10081164
update tasFieldSourceForTable set strFieldText ='s{0}.strFieldBarcode', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=	 10081165																													   
update tasFieldSourceForTable set strFieldText ='s{0}.idfAnimal', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=	 10081166																													   
update tasFieldSourceForTable set strFieldText ='s{0}.idfSpecies', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=	 10081167																													   
update tasFieldSourceForTable set strFieldText ='s{0}.idfsBirdStatus', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=	 10081168																													   
update tasFieldSourceForTable set strFieldText ='s{0}.datFieldCollectionDate', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=	 10081169																													   
update tasFieldSourceForTable set strFieldText ='s{0}.idfSendToOffice' where idfsSearchField=	 10081170 and  idfUnionSearchTable =4583090000145 and  idfSearchTable = 4583090000145																													   
update tasFieldSourceForTable set strFieldText ='s{0}.idfFieldCollectedByOffice', idfUnionSearchTable =4583090000145, idfSearchTable =4583090000145 where idfsSearchField=	 10081171																													   


update tasSearchField set strSearchFieldAlias ='outbVet_sflVCSample_SampleType' where idfsSearchField    =	 10081164	
update tasSearchField set strSearchFieldAlias ='outbVet_sflVCSample_FieldSampleID' where idfsSearchField =   10081165


update tasFieldSourceForTable set strFieldText ='h{0}.idfsHumanGender'   where idfsSearchField=	 10081161	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='h{0}.datDateofBirth'   where idfsSearchField=	 10081162	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='datediff(year,getDate(),h{0}.datDateofBirth)'   where idfsSearchField=	 10081162	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='datediff(year,getDate(),h{0}.datDateofBirth)'   where idfsSearchField=	 10081163	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='f{0}.idfFarm'   where idfsSearchField=	 10081153	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='h{0}.strPersonID'   where idfsSearchField=	 10081152	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145

update tasFieldSourceForTable set strFieldText ='h{0}.strPersonID'   where idfsSearchField=	 10081152	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145

update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel2ID'   where idfsSearchField=	 10081158	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel3ID'   where idfsSearchField=	 10081159	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasFieldSourceForTable set strFieldText ='hcLH{0}.AdminLevel4ID'   where idfsSearchField=	 10081160	and idfSearchTable =4583090000145 and idfUnionSearchTable =4583090000145
update tasSearchField set strSearchFieldAlias =N'outb_vc_AnimalStatus' where idfsSearchField = 10081134 and idfsSearchObject = 10082063
update tasSearchField set strSearchFieldAlias =N'sflVC_AnimalSpeciesPST' where idfsSearchField = 10081174 and idfsSearchObject = 10082066
update tasSearchField set strSearchFieldAlias =N'sflVC_AnimalIDPST' where idfsSearchField = 10081175 and idfsSearchObject = 10082066
update tasSearchField set strLookupTable=NULL where idfsSearchField = 10081154 and idfsSearchObject = 10082064
update tasSearchField set strSearchFieldAlias =N'sflVC_CFarmID' where idfsSearchField = 10081153 and idfsSearchObject = 10082064
update tasFieldSourceForTable set strFieldText =N'case when isnumeric(cast(hcs_ap{0}.varValue as nvarchar)) = 1 then cast(cast(hcs_ap{0}.varValue as nvarchar) as int) else null end' where idfsSearchField =10081130 and idfSearchTable = 4583090000145
update tasFieldSourceForTable set strFieldText =N'case when isnumeric(cast(hcs_ap{0}.varValue as nvarchar)) = 1 then cast(cast(hcs_ap{0}.varValue as nvarchar) as int) else null end' where idfsSearchField =10081123 and idfSearchTable = 4583090000145


/*Livestock Animal CS-- this field should not have been a child object of human diseases report so we turned it off*/
update  trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10082013

/*Human EPI Investigations -- this field should not have been a child object of human diseases report so we turned it off*/
update  trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10082011

/*Livestock Species CS-- this field should not have been a child object of vet diseases report so we turned it off*/
update  trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10082015  and idfsReferenceType = 19000082

/*Livestock Farm EPI-- this field should not have been a child object of vet diseases report so we turned it off*/
update  trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10082014  and idfsReferenceType = 19000082


/*Human Disease Report -- Human CLinical Signs- this field should not have been a child object of vet diseases report so we turned it off*/
update  trtBaseReference set intRowStatus = 1 where idfsBaseReference = 10082010  and idfsReferenceType = 19000082

update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location as_floc{0}
 Left Join tlbGeoLocationShared gs{0} on gs{0}.idfsLocation = as_floc{0}.idfGeoLocation   {1}{)}' where idfSearchTable = 4583090000101

update tasFieldSourceForTable set strFieldText = N'gs{0}.strPostCode' where idfsSearchField = 10080805 and idfSearchTable = 4583090000101 and idfUnionSearchTable = 4582560000000
update tasFieldSourceForTable set strFieldText ='as_cam{0}.strCampaignID' where idfsSearchField = 10081315 and idfSearchTable = 4582550000000

Delete from  tasMainTableForObject where idfsSearchObject = 10082061 and idfMainSearchTable =4582900000000 and idfMandatorySearchTable = 4582900000000
ALTER TABLE dbo.tasSearchField ENABLE TRIGGER ALL
ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL
ALTER TABLE dbo.tasMainTableForObject ENABLE TRIGGER ALL


