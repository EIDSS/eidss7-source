/*
Author:			Stephen Long
Date:			02/08/2023
Description:	Creation of new table entries for tauColumn for SAUC30 and 31.
*/

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000001)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000001, 52577590000000, 'ReportedAge', 'ReportedAge', '458489C8-7D52-45E2-9143-3FB1DFD1EE61', 10519002, '[{"idfColumn":51586590000001}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000002)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000002, 52577590000000, 'ReportedAgeUOMID', 'ReportedAgeUOMID', 'D334007D-403E-4100-8882-D75720306877', 10519002, '[{"idfColumn":51586590000002}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000003)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000003, 52577590000000, 'PassportNbr', 'Passport Number', '10A5C806-92B7-4A95-AC3F-EF5728DD566B', 10519002, '[{"idfColumn":51586590000003}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000004)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000004, 52577590000000, 'IsEmployedID', 'IsEmployedID', '73742F74-28AA-45BE-9E92-2A0A77453756', 10519002, '[{"idfColumn":51586590000004}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000005)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000005, 52577590000000, 'EmployerPhoneNbr', 'Employer Phone Number', '2B2F8D9F-600D-454C-9E51-85D008228B65', 10519002, '[{"idfColumn":51586590000005}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000006)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000006, 52577590000000, 'EmployedDTM', 'Date Employed', '192C35D6-FBDF-406F-BDC6-DBC05D3D403C', 10519002, '[{"idfColumn":51586590000006}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000007)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000007, 52577590000000, 'IsStudentID', 'IsStudentID', '3D60B15A-14EA-4C71-AD4A-C514CF188E85', 10519002, '[{"idfColumn":51586590000007}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000008)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000008, 52577590000000, 'SchoolName', 'School Name', '458489C8-7D52-45E2-9143-3FB1DFD1EE61', 10519002, '[{"idfColumn":51586590000008}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000009)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000009, 52577590000000, 'SchoolPhoneNbr', 'School Phone Number', 'A4A5AA5F-4204-4703-BFE0-076B1856499C', 10519002, '[{"idfColumn":51586590000009}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000010)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000010, 52577590000000, 'SchoolAddressID', 'SchoolAddressID', 'A39BBDD8-1D9C-4BAF-B080-70D6EFCA683B', 10519002, '[{"idfColumn":[{"idfColumn":51586590000010}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000011)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000011, 52577590000000, 'SchoolLastAttendDTM', 'Date Last Attended School', 'AA39511B-EA81-4F12-8BC0-5F16CE444FB5', 10519002, '[{"idfColumn":[{"idfColumn":51586590000011}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000012)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000012, 52577590000000, 'ContactPhoneCountryCode', 'Contact Phone Country Code', '35C250DF-2BC7-4237-AD89-77FA935A8419', 10519002, '[{"idfColumn":[{"idfColumn":51586590000012}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000013)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000013, 52577590000000, 'ContactPhoneNbr', 'Contact Phone Number', 'E5BBABA8-D817-4485-8810-399CCB63DE4D', 10519002, '[{"idfColumn":[{"idfColumn":51586590000013}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000014)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000014, 52577590000000, 'ContactPhoneNbrTypeID', 'ContactPhoneNbrTypeID', '9FFD1BFB-ADE4-488F-8639-2A7A556A96E2', 10519002, '[{"idfColumn":[{"idfColumn":51586590000014}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000015)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000015, 52577590000000, 'ContactPhone2CountryCode', 'ContactPhone2CountryCode', '72E61FA9-5A2D-4DA5-A2B1-073856FFAC6E', 10519002, '[{"idfColumn":[{"idfColumn":51586590000015}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000016)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000016, 52577590000000, 'ContactPhone2Nbr', 'Contact Phone 2 Number', '7513F971-C4D7-4F47-BFA4-6BD78C9C6725', 10519002, '[{"idfColumn":[{"idfColumn":51586590000016}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000017)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000017, 52577590000000, 'ContactPhone2NbrTypeID', 'ContactPhone2NbrTypeID', '49BFD675-BCAD-4136-B9E0-C8226A4EDEE9', 10519002, '[{"idfColumn":[{"idfColumn":51586590000017}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586590000018)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586590000018, 52577590000000, 'AltAddressID', 'AltAddressID', '225C3B45-5237-4554-906E-69DA6F86B73E', 10519002, '[{"idfColumn":[{"idfColumn":51586590000018}]}]', null, getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000001)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000001, 53577690000000, 'ReportedAge', 'ReportedAge', 10519002, '[{"idfColumn":51586890000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000002)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000002, 53577690000000, 'ReportedAgeUOMID', 'ReportedAgeUOMID', 10519002, '[{"idfColumn":51586890000002}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000003)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000003, 53577690000000, 'ContactPhoneCountryCode', 'ContactPhoneCountryCode', 10519002, '[{"idfColumn":51586890000003}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000004)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000004, 53577690000000, 'ContactPhoneNbr', 'ContactPhoneNbr', 10519002, '[{"idfColumn":51586890000004}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000005)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000005, 53577690000000, 'ContactPhoneNbrTypeID', 'ContactPhoneNbrTypeID', 10519002, '[{"idfColumn":51586890000005}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586890000006)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586890000006, 53577690000000, 'HumanAdditionalInfo', 'HumanAdditionalInfo', 10519002, '[{"idfColumn":51586890000006}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586690000001)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586690000001, 53577590000000, 'VaccinationName', 'VaccinationName', 10519002, '[{"idfColumn":51586690000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586690000002)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586690000002, 53577590000000, 'VaccinationDate', 'VaccinationDate', 10519002, '[{"idfColumn":51586690000002}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586790000001)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586790000001, 75740000000, 'idfHumanCase', 'idfHumanCase', 10519002, '[{"idfColumn":51586790000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51523700000000)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51523700000000, 75580000000, 'idfsLocation', 'idfsLocation', 10519002, '[{"idfColumn":51523700000000}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51523710000000)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51523710000000, 4572590000000, 'idfsLocation', 'idfsLocation', 10519002, '[{"idfColumn":51523710000000}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000001)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000001, 53577790000000, 'HumanDiseasereportRelnUID', 'HumanDiseasereportRelnUID', 10519002, '[{"idfColumn":51586990000001}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000018)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000018, 53577790000002, 'idfMonitoringSession', null, NEWID(), 10519002, '[{"idfTable":51586990000018}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000019)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000019, 53577790000002, 'intOrder', null, NEWID(), 10519002, '[{"idfTable":51586990000019}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000020)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000020, 53577790000002, 'intRowStatus', null, NEWID(), 10519002, '[{"idfTable":51586990000020}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000021)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000021, 53577790000002, 'idfsSampleType', null, NEWID(), 10519002, '[{"idfTable":51586990000021}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000022)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000022, 53577790000003, 'idfMaterial', null, NEWID(), 10519002, '[{"idfTable":51586990000022}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000023)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000023, 53577790000003, 'idfsSampleType', null, NEWID(), 10519002, '[{"idfTable":51586990000023}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000024)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000024, 53577790000003, 'idfMonitoringSession', null, NEWID(), 10519002, '[{"idfTable":51586990000024}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000025)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000025, 53577790000003, 'idfsDisease', null, NEWID(), 10519002, '[{"idfTable":51586990000025}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000026)
BEGIN
	INSERT INTO tauColumn (idfColumn, idfTable, strName, strDescription, rowguid, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000026, 53577790000003, 'intRowStatus', null, NEWID(), 10519002, '[{"idfTable":51586990000026}]', 'System', getdate(), null, null)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000002)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000002, 53577790000001, 'idfsReportFormType', 'idfsReportFormType', 10519002, '[{"idfColumn":51586990000002}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000003)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000003, 53577790000001, 'idfsAdministrativeUnit', 'idfsAdministrativeUnit', 10519002, '[{"idfColumn":51586990000003}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000004)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000004, 53577790000001, 'idfSentByOffice', 'idfSentByOffice', 10519002, '[{"idfColumn":51586990000004}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000005)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000005, 53577790000001, 'idfSentByPerson', 'idfSentByPerson', 10519002, '[{"idfColumn":51586990000005}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000006)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000006, 53577790000001, 'idfEnteredByOffice', 'idfEnteredByOffice', 10519002, '[{"idfColumn":51586990000006}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000007)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000007, 53577790000001, 'idfEnteredByPerson', 'idfEnteredByPerson', 10519002, '[{"idfColumn":51586990000007}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000008)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000008, 53577790000001, 'datSentByDate', 'datSentByDate', 10519002, '[{"idfColumn":51586990000008}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000009)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000009, 53577790000001, 'datEnteredByDate', 'datEnteredByDate', 10519002, '[{"idfColumn":51586990000009}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000010)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000010, 53577790000001, 'datStartDate', 'datStartDate', 10519002, '[{"idfColumn":51586990000010}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000011)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000011, 53577790000001, 'datFinishDate', 'datFinishDate', 10519002, '[{"idfColumn":51586990000011}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000012)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000012, 53577790000001, 'strReportFormID', 'strReportFormID', 10519002, '[{"idfColumn":51586990000012}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000013)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000013, 53577790000001, 'idfsSite', 'idfsSite', 10519002, '[{"idfColumn":51586990000013}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000014)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000014, 53577790000001, 'idfsDiagnosis', 'idfsDiagnosis', 10519002, '[{"idfColumn":51586990000014}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000015)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000015, 53577790000001, 'Total', 'Total', 10519002, '[{"idfColumn":51586990000015}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000016)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000016, 53577790000001, 'Notified', 'Notified', 10519002, '[{"idfColumn":51586990000016}]', 'System', GETDATE(), NULL, NULL)
END

IF NOT EXISTS (SELECT 1 FROM dbo.tauColumn WHERE idfColumn = 51586990000017)
BEGIN
	INSERT INTO dbo.tauColumn (idfColumn, idfTable, strName, strDescription, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM, AuditUpdateUser, AuditUpdateDTM)
	VALUES (51586990000017, 53577790000001, 'Comments', 'Comments', 10519002, '[{"idfColumn":51586990000017}]', 'System', GETDATE(), NULL, NULL)
END

GO