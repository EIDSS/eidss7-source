/*
	Creates a new entry, for the ffParameterType table to help in the identification of a new object used, instead of the Decor Element.

	Must be ran on all existing DBs, and then created on the master reference.


	RUN THIS BEFORE executing Decor-To-Parameter-Converter.sql
*/




IF NOT EXISTS(SELECT 1 FROM ffParameterType WHERE idfsParameterType = 10071504)
   BEGIN
	  INSERT INTO ffParameterType (idfsParameterType, idfsReferenceType, intRowStatus, rowguid, strMaintenanceFlag, SourceSystemNameID, SourceSystemKeyValue, AuditCreateUser, AuditCreateDTM)
	  VALUES (10071504, NULL, 0, NEWID(), NULL, 10519001, '[{"idfsParameterType":10071504}]', 'system', GETDATE())
   END