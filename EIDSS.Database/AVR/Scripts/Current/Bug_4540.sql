
if exists( select * from tasFieldSourceForTable where idfsSearchField = 10081317)
begin
update tasFieldSourceForTable set strFieldText = N'as_cam{0}.idfsCampaignType' where idfsSearchField =  10081317
end
if exists( select * from tasFieldSourceForTable where idfsSearchField = 10081322)
begin
update tasFieldSourceForTable set strFieldText = N'cd{0}.idfsSampleType' where idfsSearchField =  10081322
end

if exists( select * from tasSearchField where idfsSearchField = 10081322)
begin
update tasSearchField set idfsSearchFieldType = 10081006 where idfsSearchField =  10081322
end
if exists( select * from tasSearchField where idfsSearchField = 10081318)
begin
update tasSearchField set idfsSearchFieldType = 10081006 where idfsSearchField =  10081318
end
if exists( select * from tasSearchField where idfsSearchField = 10081317)
begin
update tasSearchField set idfsSearchFieldType = 10081006 where idfsSearchField =  10081317
end


if exists( select * from tasFieldSourceForTable where idfsSearchField = 10080843 and idfSearchTable = 4582560000000 and idfUnionSearchTable = 4582550000000)
begin
update tasFieldSourceForTable set strFieldText = N'as_cam_to_dg{0}.idfsDiagnosis' where idfsSearchField = 10080843 and idfSearchTable = 4582560000000 and idfUnionSearchTable = 4582550000000
end
if exists( select * from tasSearchField where idfsSearchField = 10080843)
begin
update tasSearchField set strCalculatedFieldText = N'cast((select  distinct ASSessionDiagnosis.[name] + ''; ''    from  tlbMonitoringSessionToDiagnosis SessionToDiagnosesString   inner join fnReferenceRepair(@LangID, 19000019) ASSessionDiagnosis on   ASSessionDiagnosis.idfsReference = SessionToDiagnosesString.idfsDiagnosis   where  SessionToDiagnosesString.idfMonitoringSession = {5}      and SessionToDiagnosesString.intRowStatus = 0   order by ASSessionDiagnosis.[name] + ''; ''    for xml path('''')     ) as nvarchar(max)) as [sflHASS_Diseases]' where idfsSearchField =  10080843
end