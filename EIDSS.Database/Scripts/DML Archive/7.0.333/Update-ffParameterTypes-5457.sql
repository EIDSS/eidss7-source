/*
	Mike Kornegay
	2/10/2023
	Update ffParamterTypes so that the migrated paramter types
	have the correct idfsReferenceType instead of 1900069

*/

/*

	Query run to select parameter types that were not correct.
	For documentation only!  No need to run this query.

		SELECT 
			AP.varValue,
			P.idfsParameterType,
			PT.idfsReferenceType AS CurrentReferenceType,
			(SELECT idfsReferenceType FROM trtBaseReference WHERE AP.varValue = idfsBaseReference) AS ShouldBeReferenceType
		FROM dbo.tlbActivityParameters AP
		LEFT JOIN dbo.ffParameter P	ON P.idfsParameter = AP.idfsParameter AND P.intRowStatus = 0
		LEFT JOIN dbo.ffParameterType PT ON PT.idfsParameterType = P.idfsParameterType
		WHERE 
			P.idfsParameterType NOT IN (10071059, 10071045,10071029, 52628110000000,10071060,10071025)
			AND varValue IS NOT NULL
			AND PT.idfsReferenceType <> (SELECT idfsReferenceType FROM trtBaseReference WHERE AP.varValue = idfsBaseReference)
		GROUP BY
			AP.varValue,
			P.idfsParameterType,
			PT.idfsReferenceType


*/
update ffParameterType 
set 
	idfsReferenceType = 19000100,
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = '[{"idfsParameterType":217140000000}]',
	AuditCreateUser = 'system',
	AuditCreateDTM = '2023-01-05'
where idfsParameterType = 217140000000

update ffParameterType 
set 
	idfsReferenceType = 19000160, 
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = '[{"idfsParameterType":10071501}]',
	AuditCreateUser = 'system',
	AuditCreateDTM = '2023-01-05'
where idfsParameterType = 10071501

update ffParameterType 
set 
	idfsReferenceType = 19000162, 
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = '[{"idfsParameterType":10071503}]',
	AuditCreateUser = 'system',
	AuditCreateDTM = '2023-01-05'
where idfsParameterType = 10071503

update ffParameterType 
set 
	idfsReferenceType = 19000064, 
	SourceSystemNameID = 10519001,
	SourceSystemKeyValue = '[{"idfsParameterType":10071502}]',
	AuditCreateUser = 'system',
	AuditCreateDTM = '2023-01-05'
where idfsParameterType = 10071502

