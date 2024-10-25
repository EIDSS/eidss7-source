

UPDATE dbo.trtResourceTranslation 
SET strResourceString = 'ყოველკვირეული ანგარიშგების ფორმა'
WHERE idfsResource = 747 AND idfsLanguage = 10049004


--already run in QA-GG for build 321 - run only in Regression, Auto2 and BV Stand
insert into tautable(idfTable, strName, rowguid, SourceSystemNameID, SourceSystemKeyValue)

Values
(52577590000000,'HumanActualAddlInfo', NEWID(),	10519001, '[{"idfTable":53577590000000}]'),			
(53577590000000,'HumanDiseaseReportVaccination',NEWID(), 10519001,'[{"idfTable":53577590000000}]'),
(53577690000000,'HumanAddlInfo',	NEWID(), 10519001,'[{"idfTable":53577690000000}]'),	
(53577790000000,'HumanDiseaseReportRelationship',NEWID(), 10519001, '[{"idfTable":53577790000000}]'),	
(53577790000004,'VetDiseaseReportRelationship',	NEWID(), 10519001, '[{"idfTable":53577790000004}]')

--already run in QA-GG for build 321 - run only in Regression, Auto2 and BV Stand
insert into taucolumn(idfColumn, idfTable, strName, strDescription, rowGuid, SourceSystemNameID, SourceSystemKeyValue)
values
(51523700000000,75580000000		,'idfsLocation',				'idfsLocation',					NEWID(), 10519001,'[{"idfColumn":51523700000000}]'),
(51523710000000,4572590000000	,'idfsLocation',				'idfsLocation',					NEWID(), 10519001,'[{"idfColumn":51523710000000}]'),
(51586590000001,52577590000000	,'ReportedAge',					'ReportedAge',					NEWID(), 10519001,'[{"idfColumn":51586590000001}]'),
(51586590000002,52577590000000	,'ReportedAgeUOMID',			'ReportedAgeUOMID',				NEWID(), 10519001,'[{"idfColumn":51586590000002}]'),
(51586590000003,52577590000000	,'PassportNbr',					'Passport Number',				NEWID(), 10519001,'[{"idfColumn":51586590000003}]'),
(51586590000004,52577590000000	,'IsEmployedID',				'IsEmployedID',					NEWID(), 10519001,'[{"idfColumn":51586590000004}]'),
(51586590000005,52577590000000	,'EmployerPhoneNbr',			'Employer Phone Number',		NEWID(), 10519001,'[{"idfColumn":51586590000005}]'),
(51586590000006,52577590000000	,'EmployedDTM',					'Date Employed',				NEWID(), 10519001,'[{"idfColumn":51586590000006}]'),
(51586590000007,52577590000000	,'IsStudentID',					'IsStudentID',					NEWID(), 10519001,'[{"idfColumn":51586590000007}]'),
(51586590000008,52577590000000	,'SchoolName',					'School Name',					NEWID(), 10519001,'[{"idfColumn":51586590000008}]'),
(51586590000009,52577590000000	,'SchoolPhoneNbr',				'School Phone Number',			NEWID(), 10519001,'[{"idfColumn":51586590000009}]'),
(51586590000010,52577590000000	,'SchoolAddressID',				'SchoolAddressID',				NEWID(), 10519001,'[{"idfColumn":51586590000010}]'),
(51586590000011,52577590000000	,'SchoolLastAttendDTM',			'Date Last Attended School',	NEWID(), 10519001,'[{"idfColumn":51586590000011}]'),
(51586590000012,52577590000000	,'ContactPhoneCountryCode',		'Contact Phone Country Code',	NEWID(), 10519001,'[{"idfColumn":51586590000012}]'),
(51586590000013,52577590000000	,'ContactPhoneNbr',				'Contact Phone Number',			NEWID(), 10519001,'[{"idfColumn":51586590000013}]'),
(51586590000014,52577590000000	,'ContactPhoneNbrTypeID',		'ContactPhoneNbrTypeID',		NEWID(), 10519001,'[{"idfColumn":51586590000014}]'),
(51586590000015,52577590000000	,'ContactPhone2CountryCode',	'ContactPhone2CountryCode',		NEWID(), 10519001,'[{"idfColumn":51586590000015}]'),
(51586590000016,52577590000000	,'ContactPhone2Nbr',			'Contact Phone 2 Number',		NEWID(), 10519001,'[{"idfColumn":51586590000016}]'),
(51586590000017,52577590000000	,'ContactPhone2NbrTypeID',		'ContactPhone2NbrTypeID',		NEWID(), 10519001,'[{"idfColumn":51586590000017}]'),
(51586590000018,52577590000000	,'AltAddressID',				'AltAddressID',					NEWID(), 10519001,'[{"idfColumn":51586590000018}]'),
(51586690000001,53577590000000	,'VaccinationName',				'VaccinationName',				NEWID(), 10519001,'[{"idfColumn":51586690000001}]'),
(51586690000002,53577590000000	,'VaccinationDate',				'VaccinationDate',				NEWID(), 10519001,'[{"idfColumn":51586690000002}]'),
(51586790000001,75740000000		,'idfHumanCase',				'idfHumanCase',					NEWID(), 10519001,'[{"idfColumn":51586790000001}]'),
(51586890000001,53577690000000	,'ReportedAge',					'ReportedAge	',				NEWID(), 10519001,'[{"idfColumn":51586890000001}]'),
(51586890000002,53577690000000	,'ReportedAgeUOMID',			'ReportedAgeUOMID',				NEWID(), 10519001,'[{"idfColumn":51586890000002}]'),
(51586890000003,53577690000000	,'ContactPhoneCountryCode',		'ContactPhoneCountryCode',		NEWID(), 10519001,'[{"idfColumn":51586890000003}]'),
(51586890000004,53577690000000	,'ContactPhoneNbr',				'ContactPhoneNbr',				NEWID(), 10519001,'[{"idfColumn":51586890000004}]'),
(51586890000005,53577690000000	,'ContactPhoneNbrTypeID',		'ContactPhoneNbrTypeID',		NEWID(), 10519001,'[{"idfColumn":51586890000005}]'),
(51586890000006,53577690000000	,'HumanAdditionalInfo',			'HumanAdditionalInfo',			NEWID(), 10519001,'[{"idfColumn":51586890000006}]'),
(51586990000001,53577790000000	,'HumanDiseasereportRelnUID',	'HumanDiseasereportRelnUID',	NEWID(), 10519001,'[{"idfColumn":51586990000001}]')



-- Accession Out is now obsolete
UPDATE dbo.trtBaseReference
SET intRowStatus = 1
WHERE idfsBaseReference = 10017002

UPDATE dbo.trtBaseReference SET strDefault = N'Aliquot' WHERE idfsBaseReference = 10017008



-- disable old objects
UPDATE dbo.trtBaseReference
SET intRowStatus = 1
WHERE idfsBaseReference IN (10017026, 10017027,10017032,10017054,10017059,10017035,10017072,10017070,10017013,10017011)
--10017006,
--10017005,
--10017071,

--already run in QA-GG for build 321 - run only in Regression, Auto2 and BV Stand
-------------------------------------------------------------------------------------------------------------------
-- new audit objects
-------------------------------------------------------------------------------------------------------------------
INSERT INTO dbo.trtBaseReference
(
    idfsBaseReference,
    idfsReferenceType,
    strBaseReferenceCode,
    strDefault,
    intRowStatus,
    rowguid,
    SourceSystemNameID,
    SourceSystemKeyValue,
    AuditCreateUser,
    AuditCreateDTM
)
VALUES
(   
	10017076,
	19000017,
	N'daoFarmDedup',
	N'Farm Deduplication',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017076}]',
	N'System',
	GETDATE()

),
(   
	10017077,
	19000017,
	N'daoHumAggDisRep',
	N'Human Aggregate Disease Report',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017077}]',
	N'System',
	GETDATE()

),
(   
	10017078,
	19000017,
	N'daoHumDisRep',
	N'Human Disease Report',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017078}]',
	N'System',
	GETDATE()

),
(   
	10017079,
	19000017,
	N'daoHumDisRepDedup',
	N'Human Disease Report Deduplication',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017079}]',
	N'System',
	GETDATE()

),
(   
	10017080,
	19000017,
	N'daoHumOutbreakCase',
	N'Human Outbreak Case',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017080}]',
	N'System',
	GETDATE()

)
,
(   
	10017081,
	19000017,
	N'daoOutbreakSession',
	N'Outbreak Session',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017081}]',
	N'System',
	GETDATE()

),
(   
	10017082,
	19000017,
	N'daoPersonDedup',
	N'Person Deduplication',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017082}]',
	N'System',
	GETDATE()

),
(   
	10017083,
	19000017,
	N'daoSampleTypeDisMatx',
	N'Sample Types to Disease Matrix',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017083}]',
	N'System',
	GETDATE()

),
(   
	10017084,
	19000017,
	N'daoTestTypeDisMatx',
	N'Test Types to Disease Matrix',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017084}]',
	N'System',
	GETDATE()

),
(   
	10017088,
	19000017,
	N'daoVetAggDisRep',
	N'Veterinary Aggregate Disease Report',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017088}]',
	N'System',
	GETDATE()

),
(   
	10017085,
	19000017,
	N'daoVetDisRep',
	N'Veterinary Disease Report',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017085}]',
	N'System',
	GETDATE()

),
(   
	10017086,
	19000017,
	N'daoVetDisRepDedup',
	N'Veterinary Disease Report Deduplication',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017086}]',
	N'System',
	GETDATE()

),
(   
	10017087,
	19000017,
	N'daoVetDisRepDedup',
	N'Veterinary Disease Report Deduplication',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017087}]',
	N'System',
	GETDATE()

)

--already run in QA-GG for build 321 - run only in Regression, Auto2 and BV Stand
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
	10017061,
	10049004,
	N'ადამიანის აქტიური ზედამხეველობის კამპანია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017061,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),
(   
	10017063,
	10049004,
	N'ადამიანის აქტიური ზედამხეველობის სესია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017063,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),
(   
	10017073,
	10049004,
	N'ვეტერინარული აქტიური ზედამხედველობის კამპანია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017073,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),
(   
	10017062,
	10049004,
	N'ვეტერინარული აქტიური ზედამხედველობის სესია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017062,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),
(   
	10017075,
	10049004,
	N'გმდ აგრეგირებული ფორმა',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017075,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),

-- Human Outbreak Case = N'დედუპლიკაცია'
(   
	10017080,
	10049004,
	N'ფერმის დედუპლიკაცია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017080,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),
-- Veterinary Disease Report = N'ვეტერინარულ დაავადებათა ანგარიში'
(   
	10017085,
	10049004,
	N'ფერმის დედუპლიკაცია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017085,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),


-- Weekly Reporting Form = N'ყოველკვირეული ანგარიშგების ფორმა'
(   
	10017074,
	10049004,
	N'ყოველკვირეული ანგარიშგების ფორმა',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10017074,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),




-- dashboard translation
(   
	10502009,
	10049004,
	N'ვეტერინარული აქტიური ზედამხედველობის სესია',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10502009,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

),
---- dashboard translation
(   
	10502002,
	10049004,
	N'ადამიანის დაავადების აფეთქების შემთხვევა',
	0,
	NEWID(),
	10519001,
	N'[{"idfsBaseReference":10502002,"idfsLanguage":10049004}]',
	N'System',
	GETDATE()

)


