-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Import script to refresh LkupRoleSystemFunctionAccess table with system functions to Operation mapping for E7 standard roles. 
-- Insert script for inserting default dashboard icon and gird records into LkupRoleDashboardObject for E7 standard roles. 
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*

DELETE FROM dbo.LkupRoleSystemFunctionAccess WHERE idfEmployee between -529 and -513

select * FROM dbo.LkupRoleSystemFunctionAccess WHERE idfEmployee between -529 and -513

*/

GO

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -501)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-501,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-501}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-501}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -501
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -506)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-506,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-506}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-506}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -506
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -513)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-513,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-513}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-513}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -513
END

----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -514)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-514,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-514}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-514}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -514
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -515)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-515,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-515}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-515}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -515
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -516)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-516,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-516}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-516}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -516
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -517)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-517,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-517}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-517}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -517
END

----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -518)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-518,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-518}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-518}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -518
END

----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -519)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-519,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-519}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-519}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -519
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -520)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-520,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-520}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-520}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -520
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -521)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-521,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-521}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-521}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -521
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -522)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-522,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-522}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-522}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -522
END

----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -523)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-523,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-523}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-523}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -523
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -524)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-524,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-524}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-524}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -524
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -525)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-525,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-525}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-525}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -525
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -526)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-526,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-526}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-526}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -526
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -527)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-527,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-527}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-527}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -527
END

----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -528)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-528,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-528}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-528}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

WHERE idfEmployee = -528
END
----------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployee WHERE idfEmployee = -529)
BEGIN
	INSERT INTO dbo.tlbEmployee
	(
	    idfEmployee,
	    idfsEmployeeType,
	    idfsSite,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditCreateUser,
	    AuditCreateDTM,
	    idfsEmployeeCategory
	)

	VALUES
	(
		-529,
		10023001,
		dbo.FN_GBL_SITEID_GET(),
		0,
		NEWID(),
		10519001,
		'[{"idfEmployee":-529}]',
		'System',
		GETDATE(),
		10526002
)
END
ELSE 
BEGIN
	UPDATE dbo.tlbEmployee
	SET idfsEmployeeType = 10023001,
		idfsSite = dbo.FN_GBL_SITEID_GET(),
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployee":-529}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE(),
		idfsEmployeeCategory = 10526002

	WHERE idfEmployee = -529

END


---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -501)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-501,
		-501,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-501}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -501
END
ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -501,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-501}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

	WHERE idfEmployeeGroup = -501
END
----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -513)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-513,
		-513,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-513}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -513
END
ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -513,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-513}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

	WHERE idfEmployeeGroup = -513

END
----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -514)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-514,
		-514,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-514}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -514

END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -514,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-514}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

	WHERE idfEmployeeGroup = -514

END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -515)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-515,
		-515,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-515}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -515
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -515,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-515}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -515
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -516)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-516,
		-516,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-516}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -516
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -516,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-516}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -516
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -517)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-517,
		-517,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-517}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -517
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -517,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-517}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -517
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -518)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-518,
		-518,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-518}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -518
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -518,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-518}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -518
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -519)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-519,
		-519,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-519}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -519
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -519,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-519}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -519
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -520)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-520,
		-520,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-520}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -520
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -520,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-520}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -520
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -521)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-521,
		-521,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-521}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -521
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -521,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-521}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -521
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -522)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-522,
		-522,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-522}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -522
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -522,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-522}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -522
END

---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -523)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-523,
		-523,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-523}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -523
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -523,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-523}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -523
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -524)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-524,
		-524,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-524}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -524
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -524,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-524}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -524
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -525)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-525,
		-525,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-525}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -525
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -525,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-525}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -525
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -526)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-526,
		-526,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-526}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -526
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -526,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-526}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -526
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -527)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-527,
		-527,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-527}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -527
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -527,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-527}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -527
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -528)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-528,
		-528,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-528}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -528
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -528,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-528}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -528
END
---------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM dbo.tlbEmployeeGroup WHERE idfEmployeeGroup = -529)
BEGIN
	INSERT INTO dbo.tlbEmployeeGroup
	(
	    idfEmployeeGroup,
	    idfsEmployeeGroupName,
	    idfsSite,
		strName,
		strDescription,
	    intRowStatus,
	    rowguid,
	    SourceSystemNameID,
	    SourceSystemKeyValue,
	    AuditUpdateUser,
	    AuditUpdateDTM
	)

	SELECT
		-529,
		-529,
		dbo.FN_GBL_SITEID_GET(),
		strDefault,
		strDefault,
		0,
		NEWID(),
		10519001,
		'[{"idfEmployeeGroup":-529}]',
		'System',
		GETDATE()
	FROM dbo.trtBaseReference
	WHERE idfsBaseReference = -529
END

ELSE 
BEGIN
	UPDATE T
	SET T.idfsEmployeeGroupName = -529,
		T.idfsSite = dbo.FN_GBL_SITEID_GET(),
		T.strDescription = S.strDefault,
		strName = S.strDefault,
		intRowStatus = 0,
		SourceSystemNameID = 10519001,
		SourceSystemKeyValue = '[{"idfEmployeeGroup":-529}]',
		AuditUpdateUser = 'System',
		AuditUpdateDTM = GETDATE()

	FROM dbo.tlbEmployeeGroup T
	INNER JOIN dbo.trtBaseReference S ON S.idfsBaseReference = T.idfEmployeeGroup

WHERE idfEmployeeGroup = -529
END

GO

UPDATE dbo.trtBaseReference SET strDefault = 'GG Zoo Entomologist (Human)' WHERE idfsBaseReference = -523

GO

-- Create temporary procedure for insert update into LkupSystemFunctionToOperation
-- AND LkupRoleSystemFunctionAccess
-- Updated by MCW to include all Audit info
--
CREATE OR ALTER PROCEDURE dbo.zz_RoleSystemFunctionAccess_SET
(
	@Role_ID BIGINT,
	@Function_Name_ID BIGINT,
	@Operation_ID BIGINT,
	@intRowStatus INT,
	@intRowStatusForOperation INT,
	@ErrorCode INT = 0 OUTPUT
)

AS
BEGIN
	BEGIN TRY
		-- Insert update in LkupRoleSystemFunctionAccess
		IF NOT EXISTS (SELECT * FROM dbo.LkupRoleSystemFunctionAccess
					   WHERE SystemFunctionID = @Function_Name_ID AND idfEmployee = @Role_ID AND SystemFunctionOperationID = @Operation_ID)
		BEGIN
		PRINT 'Inserting for System Function '+  CAST(@Function_Name_ID AS NVARCHAR(200)) +
				' for Operation ' + CAST(@Operation_ID AS NVARCHAR(200)) + ' for Role '+ CAST(@Role_ID AS NVARCHAR(200))
			INSERT INTO dbo.LkupRoleSystemFunctionAccess
			(
				idfEmployee, 
				SystemFunctionID, 
				SystemFunctionOperationID, 
				rowguid, 
				intRowStatus, 
				intRowStatusForSystemFunction, 
				SourceSystemNameID,
				SourceSystemKeyValue,
				AuditCreateDTM,
				AuditCreateUser
			)
			VALUES
			(
				@Role_ID, 
				@Function_Name_ID, 
				@Operation_ID,
				NEWID(),
				@intRowStatus,
				@intRowStatusForOperation,
				10519001,
				N'{"idfEmployee":' + CAST(@Role_ID AS NVARCHAR(24)) + ',"SystemFunctionID":' + CAST(@Function_Name_ID AS NVARCHAR(24)) + ',"SystemFunctionOperationID":' + CAST(@Operation_ID AS NVARCHAR(24)) + '}',
				GETDATE(),
				'SYSTEM')
		END
		ELSE -- update existing mappings for the role
		BEGIN
			PRINT 'Updating for System Function '+  CAST(@Function_Name_ID AS NVARCHAR(24)) + ' for Operation ' + CAST(@Operation_ID AS NVARCHAR(24)) + ' for Role '+ CAST(@Role_ID AS NVARCHAR(24))
			UPDATE dbo.LkupRoleSystemFunctionAccess
			SET intRowStatus = @intRowStatus,
				intRowStatusForSystemFunction = @intRowStatusForOperation,
				AuditUpdateUser = 'System',
				AuditUpdateDTM = GETDATE()
			WHERE SystemFunctionID = @Function_Name_ID 
			AND idfEmployee = @Role_ID
			AND SystemFunctionOperationID = @Operation_ID
		END
		SET @ErrorCode = 0
	END TRY
	BEGIN CATCH
	PRINT ERROR_MESSAGE()  
		SET @ErrorCode = -1
	END CATCH
END

GO

-- Create temporary procedure for insert update into LkupRoleDashboardObject
-- Updated by MCW to include all Audit info
--ZZZ_DashboardMapping table is created to store the e7 standard roles applicable dashboard icons and grids based on 06-User Group with functions list
--
CREATE OR ALTER PROCEDURE dbo.zz_RoleDashboardObject_SET
AS
BEGIN
	BEGIN TRY
		declare @ErrorCode INT = 0;
		declare @idfsEmployeeGroupName bigint;
		declare @strName NVARCHAR(255);
		declare @DashboardIcon1 as NVARCHAR(100) =null;
		declare @DashboardIcon2 as NVARCHAR(100) =null;
		declare @DashboardIcon3 as NVARCHAR(100) =null;
		declare @DashboardIcon4 as NVARCHAR(100) =null;
		declare @DashboardIcon5 as NVARCHAR(100) =null;
		declare @DashboardIcon6 as NVARCHAR(100) =null;
		declare @DashboardGrid as NVARCHAR(100) =null;
		declare @DashboardIcon1id as bigint= null;
		declare @DashboardIcon2id as bigint= null;
		declare @DashboardIcon3id as bigint= null;
		declare @DashboardIcon4id as bigint= null;
		declare @DashboardIcon5id as bigint = null;
		declare @DashboardIcon6id as bigint= null;
		declare @DashboardGridid as bigint= null;

	DECLARE @Dashboard TABLE
	(
		strRole NVARCHAR(250),
		idfsRole BIGINT,
		strDBObject1 NVARCHAR(250),
		idfsDBObject1 BIGINT,
		strDBObject2 NVARCHAR(250),
		idfsDBObject2 BIGINT,
		strDBObject3 NVARCHAR(250),
		idfsDBObject3 BIGINT,
		strDBObject4 NVARCHAR(250),
		idfsDBObject4 BIGINT,
		strDBObject5 NVARCHAR(250),
		idfsDBObject5 BIGINT,
		strDBObject6 NVARCHAR(250),
		idfsDBObject6 BIGINT,
		strDBObject7 NVARCHAR(250),
		idfsDBObject7 BIGINT

	)

	INSERT INTO @Dashboard
	(
		strRole,
		idfsRole,
		strDBObject1,
		strDBObject2,
		strDBObject3,
		strDBObject4,
		strDBObject5,
		strDBObject6,
		strDBObject7
	)

	SELECT 
		DM.[EmployeeGroup]
		,EG.idfsBaseReference
		,DM.[1]
		,DM.[2]
		,DM.[3]
		,DM.[4]
		,DM.[5]
		,DM.[6]
		,DM.[7]

	FROM dbo.ZZZ_DashboardMapping DM
	inner JOIN dbo.trtBaseReference EG ON EG.idfsReferenceType = 19000022 AND EG.strDefault = DM.EmployeeGroup AND EG.idfsBaseReference BETWEEN -529 AND -501


	UPDATE T
	SET T.idfsDBObject1 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBicon%' AND S.strDefault = T.strDBObject1

	UPDATE T
	SET T.idfsDBObject2 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBicon%' AND S.strDefault = T.strDBObject2

	UPDATE T
	SET T.idfsDBObject3 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBicon%' AND S.strDefault = T.strDBObject3

	UPDATE T
	SET T.idfsDBObject4 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBicon%' AND S.strDefault = T.strDBObject4

	UPDATE T
	SET T.idfsDBObject5 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBicon%' AND S.strDefault = T.strDBObject5

	UPDATE T
	SET T.idfsDBObject6 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBicon%' AND S.strDefault = T.strDBObject6

	UPDATE T
	SET T.idfsDBObject7 = S.idfsBaseReference
	FROM @Dashboard T
	INNER JOIN dbo.trtBaseReference S ON S.idfsReferenceType = 19000506 AND S.strBaseReferenceCode LIKE 'dashBGrid%' AND S.strDefault = T.strDBObject7

	--SELECT * FROM @Dashboard

	DECLARE Cursor_customRolesCursor
	CURSOR FOR
	SELECT  
		idfsRole, 
		idfsDBObject1, 
		idfsDBObject2, 
		idfsDBObject3, 
		idfsDBObject4, 
		idfsDBObject5, 
		idfsDBObject6, 
		idfsDBObject7
	
	FROM  @Dashboard


	OPEN Cursor_customRolesCursor
	FETCH NEXT FROM Cursor_customRolesCursor
	INTO 
		@idfsEmployeeGroupName,
		@DashboardIcon1id,
		@DashboardIcon2id,
		@DashboardIcon3id,
		@DashboardIcon4id,
		@DashboardIcon5id,
		@DashboardIcon6id,
		@DashboardGridid;

	WHILE @@FETCH_STATUS = 0
	BEGIN

	-- Insert
		IF (@DashboardIcon1id is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardIcon1id)
		BEGIN
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				SELECT
					@idfsEmployeeGroupName, 
					@DashboardIcon1id,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardIcon1id AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM'
		END

		-- Insert
		IF (@DashboardIcon2id is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardIcon2id)
		Begin
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				VALUES
				(
					@idfsEmployeeGroupName, 
					@DashboardIcon2id,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardIcon2id AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM')
		END

		IF (@DashboardIcon3id is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardIcon3id)
		Begin
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				VALUES
				(
					@idfsEmployeeGroupName, 
					@DashboardIcon3id,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardIcon3id AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM')
		END

		IF (@DashboardIcon4id is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardIcon4id)
		Begin
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				VALUES
				(
					@idfsEmployeeGroupName, 
					@DashboardIcon4id,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardIcon4id AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM')
		END

		IF (@DashboardIcon5id is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardIcon5id)
		Begin
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				VALUES
				(
					@idfsEmployeeGroupName, 
					@DashboardIcon5id,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardIcon5id AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM')
		ENd

		IF (@DashboardIcon6id is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardIcon6id)
		Begin
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				VALUES
				(
					@idfsEmployeeGroupName, 
					@DashboardIcon6id,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardIcon6id AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM')
		END


		IF (@DashboardGridid is not null) AND NOT EXISTS (SELECT * FROM dbo.LkupRoleDashboardObject WHERE idfEmployee = @idfsEmployeeGroupName AND DashboardObjectID = @DashboardGridid)
		Begin
				
			INSERT INTO dbo.LkupRoleDashboardObject
			(
					idfEmployee, 
					DashboardObjectID, 
					rowguid, 
					intRowStatus, 
					SourceSystemNameID,
					SourceSystemKeyValue,
					AuditCreateDTM,
					AuditCreateUser
				)
				VALUES
				(
					@idfsEmployeeGroupName, 
					@DashboardGridid,
					NEWID(),
					0,
					10519001,
					N'{"idfEmployee":' + CAST(@idfsEmployeeGroupName AS NVARCHAR(24)) + ',"DashboardObjectID":' + CAST(@DashboardGridid AS NVARCHAR(24))  + '}',
					GETDATE(),
					'SYSTEM')
		End

		FETCH NEXT FROM Cursor_customRolesCursor
		INTO 
			@idfsEmployeeGroupName,
			@DashboardIcon1id,
			@DashboardIcon2id,
			@DashboardIcon3id,
			@DashboardIcon4id,
			@DashboardIcon5id,
			@DashboardIcon6id,
			@DashboardGridid;

		END

		CLOSE Cursor_customRolesCursor
		DEALLOCATE Cursor_customRolesCursor

		SET @ErrorCode = 0
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()  
		SET @ErrorCode = -1
	END CATCH
END

GO


-- Block to process the temporary table 'Cursor_lkupRoleToSystemFunctionAccessGG' created 
-- from EXCEL import. 
BEGIN

	BEGIN TRY
		DECLARE 
			--@ID [FLOAT],
			@Role_ID BIGINT,
			@Function_Name [NVARCHAR](2000),
			@Function_Name_ID BIGINT,
			@Operation_Name [NVARCHAR](255),
			@GG_Admin_Human [NVARCHAR](255),
			@GG_Admin_Vet [NVARCHAR](255),
			@GG_Epidemiologist [NVARCHAR](255),
			@GG_Chief_Epizootologist [NVARCHAR](255),
			@GG_Chief_Epidemiologist [NVARCHAR](255),
			@GG_Epizootologist [NVARCHAR](255),
			@GG_Chief_of_Laboratory_Human [NVARCHAR](255),
			@GG_Chief_of_Laboratory_Vet [NVARCHAR](255),
			@GG_Lab_Technician_Human [NVARCHAR](255),
			@GG_Lab_Technician_Vet [NVARCHAR](255),
			@GG_Zoo_Entomologist_Human [NVARCHAR](255),
			@GG_Zoo_Entomologist_Vet [NVARCHAR](255),
			@GG_Food_Safety_Spec [NVARCHAR](255),
			@GG_Form_03_Signer [NVARCHAR](255),
			@GG_Sentinel_Serv_Spe [NVARCHAR](255),
			@GG_Director_Human [NVARCHAR](255),
			@GG_Director_Vet [NVARCHAR](255),
			@Operation_ID BIGINT,
			@intRowStatus INT,
			@intRowStatusForOperation INT

		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  
		DECLARE @ErrorCode INT = 0

		-- Declare cursor to process row at a time.
		DECLARE Cursor_lkupRoleToSystemFunctionAccessGG 
		CURSOR FOR
		SELECT 
			FunctionName70,
			OperationName,
			[GG Administrator Human],
			[GG Administrator Vet],
			[GG Chief Epidemiologist],
			[GG Chief Epizootologist],
			[GG Chief of Laboratory (Human)],
			[GG Chief of Laboratory (Vet)],
			[GG Epidemiologist],
			[GG Epizooltologist],
			[GG Lab Technician (Human)],
			[GG Lab Technician (Vet)],
			[GG Zoo Entomoligist (Human)],
			[GG Zoo Entomologist (Vet)],
			[GG Food Safety Specialist],
			[GG Form 03 Signer],
			[GG Sentinel Surv# Spe],
			[GG Director Human],
			[GG Director Vet]

 		FROM ZZZ_09Feb2023__LkupRoleToSystemFunctionAccess
		WHERE FunctionName70 IS NOT NULL
	 --   WHERE [Function Name 7#0] NOT IN ('Access to AVR','?Access to Veterinary Disease Reports','Access to Organizations List','?Can Add Test Result For a Human Case/Session',
		--'Can Manage Reference Tables','Can modify status of Rejected sample') 

		OPEN Cursor_lkupRoleToSystemFunctionAccessGG
		FETCH NEXT FROM Cursor_lkupRoleToSystemFunctionAccessGG
		INTO 
			@Function_Name,
			@Operation_Name,
			@GG_Admin_Human,
			@GG_Admin_Vet,
			@GG_Chief_Epidemiologist,
			@GG_Chief_Epizootologist,
			@GG_Chief_of_Laboratory_Human,
			@GG_Chief_of_Laboratory_Vet,
			@GG_Epidemiologist,
			@GG_Epizootologist,
			@GG_Lab_Technician_Human,
			@GG_Lab_Technician_Vet,
			@GG_Zoo_Entomologist_Human,
			@GG_Zoo_Entomologist_Vet,
			@GG_Food_Safety_Spec,
			@GG_Form_03_Signer,
			@GG_Sentinel_Serv_Spe,
			@GG_Director_Human,
			@GG_Director_Vet

		--Loop through all the cursor rows
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Check if function name from excel is found in the database.
			SET @Function_Name_ID =  (SELECT a.idfsBaseReference
						FROM dbo.trtBaseReference a
						WHERE a.idfsReferenceType = 19000094 AND a.intRowStatus = 0
						AND dbo.FN_GBL_RemoveSpecialChars(a.strDefault) = dbo.FN_GBL_RemoveSpecialChars(@Function_Name))
			-- If matching function name is found
			IF @Function_Name_ID IS NOT NULL
			BEGIN
				-- Get the operation Id from the database for the row we are currentlly processing 
				SET @Operation_ID = (SELECT a.idfsBaseReference
				FROM dbo.trtBaseReference a
				WHERE a.idfsReferenceType = 19000059 AND a.intRowStatus = 0
				AND a.strDefault = @Operation_name)

				-- If operation id is found create mapping for Administrator role
				IF @Operation_ID IS NOT NULL
					BEGIN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Administrator Human role 
						BEGIN
							IF @GG_Admin_Human IS NULL
							BEGIN
								SET @Role_ID = -513
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -513
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)

							END

						END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Administrator Vet role 
						BEGIN
							IF @GG_Admin_Vet IS NULL
								BEGIN
									SET @Role_ID = -514
									SET @intRowStatus = 1
									SET @intRowStatusForOperation = 1
								END
							ELSE
								BEGIN
									SET @Role_ID = -514
									SET @intRowStatus = 0
									SET @intRowStatusForOperation = 0
								END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END

						END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for @GG_Chief_Epidemiologist role 
						BEGIN
						IF @GG_Chief_Epidemiologist IS NULL
							BEGIN
								SET @Role_ID = -515
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -515
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for Chief Epizootologist role 
						BEGIN
							IF @GG_Chief_Epizootologist IS NULL
							BEGIN
								SET @Role_ID = -516
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -516
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END

						END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Chief of Lab (Human) role 
						BEGIN
							IF @GG_Chief_of_Laboratory_Human IS NULL
							BEGIN
								SET @Role_ID = -517
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -517
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for Chief of Laboratory (Vet) role 
						BEGIN
							IF @GG_Chief_of_Laboratory_Vet IS NULL
							BEGIN
								SET @Role_ID = -518
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -518
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Epidemiologist role 
						BEGIN
							IF @GG_Epidemiologist IS NULL
							BEGIN
								SET @Role_ID = -519
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -519
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Epizootologist role 
						BEGIN
							IF @GG_Epizootologist IS NULL
							BEGIN
								SET @Role_ID = -520
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -520
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)

							END

						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Lab Technician (Human) role 
						BEGIN
							IF @GG_Lab_Technician_Human IS NULL
							BEGIN
								SET @Role_ID = -521
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -521
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Lab Technician (Vet) role 
						BEGIN
							IF @GG_Chief_of_Laboratory_Vet IS NULL
							BEGIN
								SET @Role_ID = -522
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -522
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for Zoo Entomologist (Human) role 
						BEGIN
							IF @GG_Zoo_Entomologist_Human IS NULL
							BEGIN
								SET @Role_ID = -523
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -523
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for Zoo Entomologist (Vet) role 
						BEGIN
							IF @GG_Zoo_Entomologist_Vet IS NULL
							BEGIN
								SET @Role_ID = -524
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -524
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Food Safety Specialist role 
						BEGIN
							IF @GG_Food_Safety_Spec IS NULL
							BEGIN
								SET @Role_ID = -525
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -525
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Form 03 Signer role 
						BEGIN
							IF @GG_Form_03_Signer IS NULL
							BEGIN
								SET @Role_ID = -526
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -526
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Sentinel Surv# Spe role 
						BEGIN
							IF @GG_Sentinel_Serv_Spe IS NULL
							BEGIN
								SET @Role_ID = -527
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -527
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)

							END

						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Director Human role 
						BEGIN
							IF @GG_Director_Human IS NULL
								BEGIN
									SET @Role_ID = -528
									SET @intRowStatus = 1
									SET @intRowStatusForOperation = 1
								END
							ELSE
								BEGIN
									SET @Role_ID = -528
									SET @intRowStatus = 0
									SET @intRowStatusForOperation = 0
								END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	@Role_ID,
																			@Function_Name_ID, 
																			@Operation_ID, 
																			@intRowStatus, 
																			@intRowStatusForOperation, 
																			@ErrorCode OUTPUT
							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)
							END
						END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						-- Process for GG Director Vet role 
						BEGIN
							IF @GG_Director_Vet IS NULL
							BEGIN
								SET @Role_ID = -529
								SET @intRowStatus = 1
								SET @intRowStatusForOperation = 1
							END
							ELSE
							BEGIN
								SET @Role_ID = -529
								SET @intRowStatus = 0
								SET @intRowStatusForOperation = 0
							END
							-- Call a temporary stored procedure created above to
							-- either insert or update in the LkupRoleSystemFunctionAccess
							EXEC dbo.zz_RoleSystemFunctionAccess_SET	
								@Role_ID,
								@Function_Name_ID,
								@Operation_ID,
								@intRowStatus,
								@intRowStatusForOperation,
								@ErrorCode OUTPUT

							IF @ErrorCode <> 0
							BEGIN
								SET @ErrorMessage = 'Insert or Update failed for '+ CAST(@Role_ID AS NVARCHAR(100)) + ' and Function Name ' 
													+ @Function_Name + ' operation name '+ @Operation_Name +'.'
								RAISERROR (@ErrorMessage,16,1)

							END

						END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

					END

					ELSE
					-- Raise the error if the operation name is not found in the database.
					BEGIN
						SET @ErrorMessage = 'System Operation '+ @Operation_Name +' not found in the database'
						RAISERROR (@ErrorMessage,16,1)
					END

				END

				ELSE
				-- Raise the error if the function name is not found in the database.
				BEGIN
					SET @ErrorMessage = 'System function '+ @Function_Name +' not found in the database'
					RAISERROR (@ErrorMessage,16,1)
				END

			FETCH NEXT FROM Cursor_lkupRoleToSystemFunctionAccessGG
			INTO 
				@Function_Name,
				@Operation_Name,
				@GG_Admin_Human,
				@GG_Admin_Vet,
				@GG_Chief_Epidemiologist,
				@GG_Chief_Epizootologist,
				@GG_Chief_of_Laboratory_Human,
				@GG_Chief_of_Laboratory_Vet,
				@GG_Epidemiologist,
				@GG_Epizootologist,
				@GG_Lab_Technician_Human,
				@GG_Lab_Technician_Vet,
				@GG_Zoo_Entomologist_Human,
				@GG_Zoo_Entomologist_Vet,
				@GG_Food_Safety_Spec,
				@GG_Form_03_Signer,
				@GG_Sentinel_Serv_Spe,
				@GG_Director_Human,
				@GG_Director_Vet

		END

		CLOSE Cursor_lkupRoleToSystemFunctionAccessGG
		DEALLOCATE Cursor_lkupRoleToSystemFunctionAccessGG

	END TRY

	BEGIN CATCH
		CLOSE Cursor_lkupRoleToSystemFunctionAccessGG
		DEALLOCATE Cursor_lkupRoleToSystemFunctionAccessGG
		PRINT @Role_ID
		PRINT @Function_Name
		PRINT @Operation_Name
		SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE();  
  
		-- Use RAISERROR inside the CATCH block to return error  
		-- information about the original error that caused  
		-- execution to jump to the CATCH block.  
		RAISERROR (@ErrorMessage, -- Message text.  
				   @ErrorSeverity, -- Severity.  
				   @ErrorState -- State.  
				   );  
	END CATCH

END
GO


DROP PROCEDURE IF EXISTS dbo.zz_RoleSystemFunctionAccess_SET
GO

EXEC zz_RoleDashboardObject_SET

DROP PROCEDURE IF EXISTS dbo.zz_RoleDashboardObject_SET
GO

DROP TABLE IF EXISTS [dbo].[ZZZ_09Feb2023__LkupRoleToSystemFunctionAccess]
GO

DROP TABLE IF EXISTS [dbo].[ZZZ_DashboardMapping]
GO

