update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm f_adr{0}  {1}{)}' where idfSearchTable =  4582610000000
update tasSearchTable set strExistenceCondition =  N'fa{0}.intRowStatus = 0'  where idfSearchTable = 4583090000031
update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm fa_adr{0}  {1}{)}', strPKField=N'fa_adr{0}.idfGeoLocationShared', strExistenceCondition = N'fa_adr{0}.intRowStatus = 0' where idfSearchTable = 4583090000033
update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm f_adr{0}  {1}{)}', strPKField='f_adr{0}.idfGeoLocationShared' where idfSearchTable =  4582610000000

update tasSearchTable set strFrom =N'{(} tlbFarmActual fa{0} LEFT JOIN tlbHumanActual ha{0} 
			ON fa{0}.idfHumanActual = ha{0}.idfHumanActual AND ha{0}.intRowStatus = 0 
        LEFT JOIN dbo.HumanActualAddlInfo haai{0}
			ON haai{0}.HumanActualAddlInfoUID = ha{0}.idfHumanActual    {1}{)} ' WHERE idfSearchTable =  4583090000031

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel1ID' where idfsSearchField =10080535 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel2ID' where idfsSearchField =10080536 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel3ID' where idfsSearchField =10080537 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080538 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033
update tasFieldSourceForTable set idfSearchTable = 4583090000031,strFieldText=N'dbo.fnConcatFullName(ha{0}.strLastName, ha{0}.strFirstName, ha{0}.strSecondName)'  where idfsSearchField = 10080534 and idfUnionSearchTable= 4583090000031 and idfSearchTable = 4583090000032
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10080186
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel2ID' where idfsSearchField =10080188
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel4ID' where idfsSearchField =10080191
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel1ID' where idfsSearchField =10080151
update tasSearchTableJoinRule set strJoinCondition =N'ON f_adr{0}.idfGeoLocationShared = f_vc{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0'
where idfMainSearchTable = 4582900000000 and idfSearchTable =4582610000000 and idfParentSearchTable = 4583010000000 and idfUnionSearchTable = 4582900000000
update tasSearchTable set strFrom = N'  {(} AVR_VW_Location_Farm f_loc{0}   {1}{)}' where idfSearchTable = 4582630000000
update tasSearchTable set strPKField = N'f_loc{0}.idfGeoLocationShared' where idfSearchTable = 4582630000000
update tasSearchTableJoinRule set strJoinCondition =N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement'
where idfMainSearchTable = 4582560000000 and idfSearchTable =4583090000047 and idfParentSearchTable = 4582610000000 and idfUnionSearchTable = 4582560000000
update tasSearchTableJoinRule set strJoinCondition =N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement'
where idfMainSearchTable = 4582900000000 and idfSearchTable =4583090000047 and idfParentSearchTable = 4582610000000 and idfUnionSearchTable = 4582900000000
update tasSearchTableJoinRule set strJoinCondition =N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement'
where idfMainSearchTable = 4583010000000 and idfSearchTable =4583090000047 and idfParentSearchTable = 4582610000000 and idfUnionSearchTable = 4583010000000

update tasSearchTableJoinRule set strJoinCondition =N'ON  f_loc{0}.AdminLevel4ID = stlm_vc_farmloc{0}.idfsSettlement'
where idfMainSearchTable = 4582900000000 and idfSearchTable =4583090000057 and idfParentSearchTable = 4582630000000 and idfUnionSearchTable = 4582900000000


update tasSearchTableJoinRule set strJoinCondition =N'ON  f_loc{0}.AdminLevel4ID = stlm_vc_farmloc{0}.idfsSettlement'
where idfMainSearchTable = 4583010000000 and idfSearchTable =4583090000057 and idfParentSearchTable = 4582630000000 and idfUnionSearchTable = 4583010000000







 update tasSearchTableJoinRule  set strJoinCondition =N'ON f_adr{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0' WHERE
 idfMainSearchTable = 4582900000000 AND idfSearchTable = 4582610000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4582900000000
 update tasSearchTableJoinRule  set strJoinCondition =N'ON f_loc{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_loc{0}.intRowStatus = 0 ' WHERE
 idfMainSearchTable = 4582900000000 AND idfSearchTable = 4582630000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4582900000000
 update tasSearchTableJoinRule  set strJoinCondition =N'ON outb{0}.idfGeoLocation = gl_outb{0}.idfGeoLocation AND gl_outb{0}.intRowStatus = 0 ' WHERE
 idfMainSearchTable = 4582900000000 AND idfSearchTable = 4582910000000 AND idfParentSearchTable = 4582900000000 AND idfUnionSearchTable =  4582900000000
 update tasSearchTableJoinRule  set strJoinCondition =N'ON f_adr{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0 ' WHERE
 idfMainSearchTable = 4583010000000 AND idfSearchTable = 4582610000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4583010000000
 update tasSearchTableJoinRule  set strJoinCondition =N'ON f_loc{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_loc{0}.intRowStatus = 0 ' WHERE
 idfMainSearchTable = 4583010000000 AND idfSearchTable = 4582630000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4583010000000
 update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10081203 and idfUnionSearchTable = 4582900000000 and idfSearchTable = 4582610000000
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10081104 and idfUnionSearchTable = 4582900000000 and idfSearchTable = 4582610000000
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080463 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080332 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000
update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080482 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000

Update tasSearchTable set strFrom =N'  {(}   tlbVetCase vc{0}    inner join tlbFarm f_vc{0}    on   f_vc{0}.idfFarm = vc{0}.idfFarm       and f_vc{0}.intRowStatus = 0 Join tlbFarmActual fa 
	on fa.idfFarmActual = f_vc.idfFarmActual   {1}{)}   ' WHERE idfSearchTable=4583010000000

Update tasSearchTable set strExistenceCondition=N'asms{0}.intRowStatus = 0 AND asms{0}.SessionCategoryID = 10502001' where idfSearchTable = 4582560000000

Update tasFieldSourceForTable set strFieldText =N'as_cam_to_dg{0}.idfsSampleType'where idfsSearchField = 10081322 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4583090000111
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.datCampaignDateStart' where idfsSearchField = 10081319 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.datCampaignDateEnd' where idfsSearchField = 10081320 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.idfsCampaignStatus' where idfsSearchField = 10081318 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.strCampaignAdministrator' where idfsSearchField = 10081321 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000


 update trtBaseReference  set intRowStatus = 0 where intRowStatus = 1 and idfsBaseReference = 10082010
 update trtBaseReference  set intRowStatus = 0 where intRowStatus = 1 and idfsBaseReference = 10082011


update  tasSearchTableJoinRule set strJoinCondition =N'  ON gl_cr_hc{0}.idfGeoLocationShared = ha{0}.idfCurrentResidenceAddress AND gl_cr_hc{0}.intRowStatus = 0 ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4582700000000 and idfParentSearchTable= 4582670000000
update  tasSearchTableJoinRule set strJoinCondition =N'  ON gl_cr_hc{0}.idfGeoLocationShared = ha{0}.idfCurrentResidenceAddress AND gl_cr_hc{0}.intRowStatus = 0 ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4582700000000 and idfParentSearchTable= 4582670000000
