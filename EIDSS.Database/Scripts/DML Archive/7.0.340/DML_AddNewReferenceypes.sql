

-----------------------------------------------------------------------------------------------------------------------------
--
-- Add baseline reference data to Reftype Ownership Form
--
-----------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.trtBaseReference
(
    idfsBaseReference,
    idfsReferenceType,
    strBaseReferenceCode,
    strDefault,
    intOrder,
    intRowStatus,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM

)
VALUES
(  
	10521000,
	19000521,
	N'ofPrivateOwnership',
	N'Private ownership',
	0,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10521000}]',
	N'System',
	GETDATE()
),
(  
	10521001,
	19000521,
	N'ofCorporateOwnership',
	N'Corporate ownership',
	10,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10521001}]',
	N'System',
	GETDATE()
),
(  
	10521002,
	19000521,
	N'ofGovernmentOwnership',
	N'Government ownership',
	20,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10521002}]',
	N'System',
	GETDATE()
),
(  
	10521003,
	19000521,
	N'ofUnknown',
	N'Unknown',
	30,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10521003}]',
	N'System',
	GETDATE()
)

GO

-----------------------------------------------------------------------------------------------------------------------------
--
-- Add baseline reference data to Reftype Legal Form
--
-----------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.trtBaseReference
(
    idfsBaseReference,
    idfsReferenceType,
    strBaseReferenceCode,
    strDefault,
    intOrder,
    intRowStatus,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM

)
VALUES
(  
	10522000,
	19000522,
	N'lfPhysicalEntity',
	N'Physical Entity',
	0,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10522000}]',
	N'System',
	GETDATE()
),
(  
	10522001,
	19000522,
	N'lfLegalEntity',
	N'Legal entity',
	10,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10522001}]',
	N'System',
	GETDATE()
),
(  
	10522002,
	19000522,
	N'lfCorporateEntity',
	N'Corporate entity',
	20,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10522002}]',
	N'System',
	GETDATE()
),
(  
	10522003,
	19000522,
	N'lfCorporateEntity',
	N'Government entity',
	30,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10522003}]',
	N'System',
	GETDATE()
)


-----------------------------------------------------------------------------------------------------------------------------
--
-- Add baseline reference data to Reftype Main Form of Activity
--
-----------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.trtBaseReference
(
    idfsBaseReference,
    idfsReferenceType,
    strBaseReferenceCode,
    strDefault,
    intOrder,
    intRowStatus,
    rowguid,
    strReservedAttribute,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM

)
VALUES
(  
	10523000,
	19000523,
	N'mfaMfg',
	N'Manufacturing',
	0,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10523000}]',
	N'System',
	GETDATE()
),
(  
	10523001,
	19000523,
	N'ofSvcs',
	N'Services',
	10,
	0,
	NEWID(),
	N'V7 Reference Data',
	10519001,
	N'[{"idfsBaseReference":10523001}]',
	N'System',
	GETDATE()
)


-------------------------------------------------------------------------------------------------------------------------
--
-- add translation for 'Unknown'
--
-------------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.trtStringNameTranslation
(
    idfsBaseReference,
    idfsLanguage,
    strTextString,
    intRowStatus,
    rowguid,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM
)
VALUES
(   
	10521003,
	10049004,
	N'უცნობი',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10521003,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()
)
GO
