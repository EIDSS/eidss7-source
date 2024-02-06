

if NOT EXISTS(select  EIDSSMenuId from tlbxSiteDocumentMap where EIDSSMenuId=10506219 and LanguageCode ='en')
BEGIN
	insert into tlbxSiteDocumentMap (EIDSSMenuId, xSiteGUID,LanguageCode,inRowStatus, AuditUpdateUser, AuditCreateDTM)
	values (10506219,'A13ECFF0-DE15-40D9-807C-25A8EE33B81B','en',0,'System', getDate())
end