
--Lamont geo changes

update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm f_adr{0}  {1}{)}', strPKField='f_adr{0}.idfGeoLocationShared' where idfSearchTable =  4582610000000

update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm f_adr{0}  {1}{)}' where idfSearchTable =  4582610000000
update tasSearchTable set strExistenceCondition =  N'fa{0}.intRowStatus = 0'  where idfSearchTable = 4583090000031
update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm fa_adr{0}  {1}{)}', strPKField=N'fa_adr{0}.idfGeoLocationShared', strExistenceCondition = N'fa_adr{0}.intRowStatus = 0' where idfSearchTable = 4583090000033
update tasSearchTable set strFrom =N'{(} AVR_VW_Location_Farm f_adr{0}  {1}{)}', strPKField='f_adr{0}.idfGeoLocationShared' where idfSearchTable =  4582610000000


update tasSearchTable set strFrom =N'{(} tlbFarmActual fa{0} LEFT JOIN tlbHumanActual ha{0}
            ON fa{0}.idfHumanActual = ha{0}.idfHumanActual AND ha{0}.intRowStatus = 0 
        LEFT JOIN dbo.HumanActualAddlInfo haai{0}
            ON haai{0}.HumanActualAddlInfoUID = ha{0}.idfHumanActual    {1}{)} ' WHERE idfSearchTable =  4583090000031


update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel1ID' where idfsSearchField =10080535 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel2ID' where idfsSearchField =10080536 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel3ID' where idfsSearchField =10080537 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080538 and idfUnionSearchTable = 4583090000031 and idfSearchTable = 4583090000033
update tasFieldSourceForTable set idfSearchTable = 4583090000031,strFieldText=N'dbo.fnConcatFullName(ha{0}.strLastName, ha{0}.strFirstName, ha{0}.strSecondName)'  where idfsSearchField = 10080534 and idfUnionSearchTable= 4583090000031 and idfSearchTable = 4583090000032

update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10080186

update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel2ID' where idfsSearchField =10080188

update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel4ID' where idfsSearchField =10080191

update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel1ID' where idfsSearchField =10080151

update tasSearchTableJoinRule set strJoinCondition =N'ON f_adr{0}.idfGeoLocationShared = f_vc{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0'

where idfMainSearchTable = 4582900000000 and idfSearchTable =4582610000000 and idfParentSearchTable = 4583010000000 and idfUnionSearchTable = 4582900000000
update tasSearchTable set strFrom = N'  {(} AVR_VW_Location_Farm f_loc{0}   {1}{)}' where idfSearchTable = 4582630000000

update tasSearchTable set strPKField = N'f_loc{0}.idfGeoLocationShared' where idfSearchTable = 4582630000000
update tasSearchTableJoinRule set strJoinCondition =N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement'

where idfMainSearchTable = 4582560000000 and idfSearchTable =4583090000047 and idfParentSearchTable = 4582610000000 and idfUnionSearchTable = 4582560000000
update tasSearchTableJoinRule set strJoinCondition =N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement'

where idfMainSearchTable = 4582900000000 and idfSearchTable =4583090000047 and idfParentSearchTable = 4582610000000 and idfUnionSearchTable = 4582900000000
update tasSearchTableJoinRule set strJoinCondition =N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement'

where idfMainSearchTable = 4583010000000 and idfSearchTable =4583090000047 and idfParentSearchTable = 4582610000000 and idfUnionSearchTable = 4583010000000

update tasSearchTableJoinRule set strJoinCondition =N'ON  f_loc{0}.AdminLevel4ID = stlm_vc_farmloc{0}.idfsSettlement'

where idfMainSearchTable = 4582900000000 and idfSearchTable =4583090000057 and idfParentSearchTable = 4582630000000 and idfUnionSearchTable = 4582900000000

update tasSearchTableJoinRule set strJoinCondition =N'ON  f_loc{0}.AdminLevel4ID = stlm_vc_farmloc{0}.idfsSettlement'

where idfMainSearchTable = 4583010000000 and idfSearchTable =4583090000057 and idfParentSearchTable = 4582630000000 and idfUnionSearchTable = 4583010000000

 update tasSearchTableJoinRule  set strJoinCondition =N'ON f_adr{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0' WHERE
idfMainSearchTable = 4582900000000 AND idfSearchTable = 4582610000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4582900000000
update tasSearchTableJoinRule  set strJoinCondition =N'ON f_loc{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_loc{0}.intRowStatus = 0 ' WHERE
idfMainSearchTable = 4582900000000 AND idfSearchTable = 4582630000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4582900000000
update tasSearchTableJoinRule  set strJoinCondition =N'ON outb{0}.idfGeoLocation = gl_outb{0}.idfGeoLocation AND gl_outb{0}.intRowStatus = 0 ' WHERE
idfMainSearchTable = 4582900000000 AND idfSearchTable = 4582910000000 AND idfParentSearchTable = 4582900000000 AND idfUnionSearchTable =  4582900000000
update tasSearchTableJoinRule  set strJoinCondition =N'ON f_adr{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0 ' WHERE
idfMainSearchTable = 4583010000000 AND idfSearchTable = 4582610000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4583010000000
update tasSearchTableJoinRule  set strJoinCondition =N'ON f_loc{0}.idfGeoLocationShared = fa{0}.idfFarmAddress AND f_loc{0}.intRowStatus = 0 ' WHERE
idfMainSearchTable = 4583010000000 AND idfSearchTable = 4582630000000 AND idfParentSearchTable = 4583010000000 AND idfUnionSearchTable =  4583010000000

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10081203 and idfUnionSearchTable = 4582900000000 and idfSearchTable = 4582610000000

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10081104 and idfUnionSearchTable = 4582900000000 and idfSearchTable = 4582610000000

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080463 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080332 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000

update tasFieldSourceForTable set strFieldText = N'fa_adr{0}.AdminLevel4ID' where idfsSearchField =10080482 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000


Update tasSearchTable set strFrom =N'  {(}   tlbVetCase vc{0}    inner join tlbFarm f_vc{0}    on   f_vc{0}.idfFarm = vc{0}.idfFarm       and f_vc{0}.intRowStatus = 0 Join tlbFarmActual fa 
    on fa.idfFarmActual = f_vc.idfFarmActual   {1}{)}   ' WHERE idfSearchTable=4583010000000

Update tasSearchTable set strExistenceCondition=N'asms{0}.intRowStatus = 0 AND asms{0}.SessionCategoryID = 10502001' where idfSearchTable = 4582560000000

Update tasFieldSourceForTable set strFieldText =N'as_cam_to_dg{0}.idfsSampleType'where idfsSearchField = 10081322 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4583090000111
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.datCampaignDateStart' where idfsSearchField = 10081319 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.datCampaignDateEnd' where idfsSearchField = 10081320 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.idfsCampaignStatus' where idfsSearchField = 10081318 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
Update tasFieldSourceForTable set strFieldText =N'as_cam{0}.strCampaignAdministrator' where idfsSearchField = 10081321 and idfUnionSearchTable = 4582550000000 and idfSearchTable = 4582550000000
update trtBaseReference  set intRowStatus = 0 where intRowStatus = 1 and idfsBaseReference = 10082010
update trtBaseReference  set intRowStatus = 0 where intRowStatus = 1 and idfsBaseReference = 10082011

--Keith Changes

update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location_human gl_cr_hc{0}   {1}{)}' where idfSearchTable = 4582700000000  --was   {(}  AVR_VW_Location gl_cr_hc{0}   {1}{)}
update tasSearchTable set strFrom = N'  {(}  AVR_VW_Location_human gl_emp_hc{0}   {1}{)}' where idfSearchTable = 4582710000000  --was   {(}  AVR_VW_Location gl_emp_hc{0}   {1}{)}

update tasSearchTable set strPKField = N'gl_cr_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582700000000   --was  gl_cr_hc{0}.idfGeoLocation
update tasSearchTable set strPKField = N'gl_emp_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582710000000   --was  gl_emp_hc{0}.idfGeoLocation

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_hc{0}   {1}{)}' where idfSearchTable = 4582770000000 
update tasSearchTable set strPKField = N'gl_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582770000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000 
update tasSearchTable set strPKField = N'gl_reg_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582780000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000 
update tasSearchTable set strPKField = N'gl_reg_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582780000000 


  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.idfGeoLocationShared' where idfsSearchField = 10080023 and idfUnionSearchTable = 4582670000000   --was  gl_cr_hc{0}.idfGeoLocation
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.idfGeoLocationShared' where idfsSearchField = 10080023 and idfUnionSearchTable = 4582900000000   --was  gl_cr_hc{0}.idfGeoLocation
  update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.idfGeoLocationShared' where idfsSearchField = 10080054 and idfUnionSearchTable = 4582670000000   --was  gl_cr_hc{0}.idfGeoLocation
  update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.idfGeoLocationShared' where idfsSearchField = 10080054 and idfUnionSearchTable = 4582900000000   --was  gl_cr_hc{0}.idfGeoLocation
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.idfGeoLocationShared' where idfsSearchField = 10080503 and idfUnionSearchTable = 4582670000000   --was  gl_reg_hc{0}.idfGeoLocation
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.idfGeoLocationShared' where idfsSearchField = 10080503 and idfUnionSearchTable = 4582900000000   --was  gl_reg_hc{0}.idfGeoLocation

  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel3ID' where idfsSearchField =10080068  and idfUnionSearchTable = 4582670000000   --was  gl_hc{0}.idfsRayon
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel3ID' where idfsSearchField =10080068  and idfUnionSearchTable = 4582900000000   --was  gl_hc{0}.idfsRayon
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel2ID' where idfsSearchField =10080070  and idfUnionSearchTable = 4582670000000   --was  gl_hc{0}.idfsRegion
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel2ID' where idfsSearchField =10080070  and idfUnionSearchTable = 4582900000000   --was  gl_hc{0}.idfsRegion
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel4ID' where idfsSearchField =10080231  and idfUnionSearchTable = 4582670000000   --was  gl_hc{0}.idfsSettlement
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel4ID' where idfsSearchField =10080231  and idfUnionSearchTable = 4582900000000   --was  gl_hc{0}.idfsSettlement
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel1ID' where idfsSearchField =10080601  and idfUnionSearchTable = 4582670000000   --was  gl_hc{0}.idfsCountry
  update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel1ID' where idfsSearchField =10080601  and idfUnionSearchTable = 4582900000000   --was  gl_hc{0}.idfsCountry

  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel3ID' where idfsSearchField =10080083  and idfUnionSearchTable = 4582670000000   --was  gl_cr_hc{0}.idfsRayon
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel3ID' where idfsSearchField =10080083  and idfUnionSearchTable = 4582900000000   --was  gl_cr_hc{0}.idfsRayon
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel2ID' where idfsSearchField =10080085  and idfUnionSearchTable = 4582670000000   --was  gl_cr_hc{0}.idfsRegion
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel2ID' where idfsSearchField =10080085  and idfUnionSearchTable = 4582900000000   --was  gl_cr_hc{0}.idfsRegion
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel4ID' where idfsSearchField =10080087  and idfUnionSearchTable = 4582670000000   --was  gl_cr_hc{0}.idfsSettlement
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel4ID' where idfsSearchField =10080087  and idfUnionSearchTable = 4582900000000   --was  gl_cr_hc{0}.idfsSettlement
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel1ID' where idfsSearchField =10080460  and idfUnionSearchTable = 4582670000000   --was  gl_cr_hc{0}.idfsCountry
  update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel1ID' where idfsSearchField =10080460  and idfUnionSearchTable = 4582900000000   --was  gl_cr_hc{0}.idfsCountry

  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel3ID' where idfsSearchField =10080501  and idfUnionSearchTable = 4582670000000   --was  gl_reg_hc{0}.idfsRayon
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel3ID' where idfsSearchField =10080501  and idfUnionSearchTable = 4582900000000   --was  gl_reg_hc{0}.idfsRayon
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel2ID' where idfsSearchField =10080500  and idfUnionSearchTable = 4582670000000   --was  gl_reg_hc{0}.idfsRegion
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel2ID' where idfsSearchField =10080500  and idfUnionSearchTable = 4582900000000   --was  gl_reg_hc{0}.idfsRegion
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel4ID' where idfsSearchField =10080502  and idfUnionSearchTable = 4582670000000   --was  gl_reg_hc{0}.idfsSettlement
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel4ID' where idfsSearchField =10080502  and idfUnionSearchTable = 4582900000000   --was  gl_reg_hc{0}.idfsSettlement
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel1ID' where idfsSearchField =10080504  and idfUnionSearchTable = 4582670000000   --was  gl_reg_hc{0}.idfsCountry
  update tasFieldSourceForTable set strFieldText = N'gl_reg_hc{0}.AdminLevel1ID' where idfsSearchField =10080504  and idfUnionSearchTable = 4582900000000   --was  gl_reg_hc{0}.idfsCountry
  
  update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_hc{0}   {1}{)}' where idfSearchTable = 4582770000000 
update tasSearchTable set strPKField = N'gl_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582770000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000 
update tasSearchTable set strPKField = N'gl_reg_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582780000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000 
update tasSearchTable set strPKField = N'gl_reg_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582780000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location gl_primary_hc{0}   {1}{)}' where idfSearchTable = 4583090000002 
update tasSearchTable set strPKField = N'  {(}  AVR_VW_Location_Human gl_primary_hc{0}   {1}{)}' where idfSearchTable = 4583090000002 

update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel3ID' where idfsSearchField =10080331  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRayon
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel2ID' where idfsSearchField =10080330  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRegion
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel1ID' where idfsSearchField =10080329  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsCountry
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel4ID' where idfsSearchField =10080332  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsSettlement

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_hc{0}   {1}{)}' where idfSearchTable = 4582770000000 
update tasSearchTable set strPKField = N'gl_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582770000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000 
update tasSearchTable set strPKField = N'gl_reg_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582780000000 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_reg_hc{0}   {1}{)}' where idfSearchTable = 4582780000000 
update tasSearchTable set strPKField = N'gl_reg_hc{0}.idfGeoLocationShared' where idfSearchTable = 4582780000000 

update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel3ID' where idfsSearchField =10080331  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRayon
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel2ID' where idfsSearchField =10080330  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRegion
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel1ID' where idfsSearchField =10080329  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsCountry
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel4ID' where idfsSearchField =10080332  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsSettlement

--new changes 4-24-23
update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human gl_primary_hc{0}   {1}{)}' where idfSearchTable = 4583090000002 
update tasSearchTable set strPKField = N'gl_primary_hc{0}.idfGeoLocationShared' where idfSearchTable = 4583090000002
update tasSearchTable set strfrom = N'{(} tlbContactedCasePerson ccp{0} INNER JOIN tlbHuman AS ccp_h{0} ON ccp_h{0}.idfHuman = ccp{0}.idfHuman LEFT JOIN AVR_VW_Location_Human AS ccp_gl{0} ON ccp_gl{0}.idfGeoLocationShared = ccp_h{0}.idfCurrentResidenceAddress AND ccp_gl{0}.intRowStatus = 0 {1}{)}' where idfSearchTable = 4582690000000

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human glve_hc{0}   {1}{)}' where idfSearchTable = 4583090000058 
update tasSearchTable set strPKField = N'glve_hc{0}.idfGeoLocationShared' where idfSearchTable = 4583090000058

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_Human as_floc{0}   {1}{)}' where idfSearchTable = 4583090000101 
update tasSearchTable set strPKField = N'as_floc{0}.idfGeoLocationShared' where idfSearchTable = 4583090000101

update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel3ID' where idfsSearchField =10080800  and idfUnionSearchTable = 4582560000000   --was  gl_primary_hc{0}.idfsRayon
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel2ID' where idfsSearchField =10080801  and idfUnionSearchTable = 4582560000000   --was  gl_primary_hc{0}.idfsRegion
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel1ID' where idfsSearchField =10080802  and idfUnionSearchTable = 4582560000000   --was  gl_primary_hc{0}.idfsCountry
update tasFieldSourceForTable set strFieldText = N'gl_primary_hc{0}.AdminLevel4ID' where idfsSearchField =10080798  and idfUnionSearchTable = 4582560000000   --was  gl_primary_hc{0}.idfsSettlement
--4/25/2023
update tasSearchTableJoinRule set strJoinCondition = N'ON human_bss{0}.idfCurrentResidenceAddress = glcra_human_bss{0}.idfGeoLocationShared' where idfSearchTable =4583090000069  and idfMainSearchTable = 4583090000064   --was  gl_primary_hc{0}.idfsSettlement
  
update tasFieldSourceForTable set strFieldText = N'glcra_human_bss{0}.AdminLevel3ID' where idfsSearchField =10080639  and idfUnionSearchTable = 4583090000064   --was  gl_primary_hc{0}.idfsRayon
update tasFieldSourceForTable set strFieldText = N'glcra_human_bss{0}.AdminLevel2ID' where idfsSearchField =10080638  and idfUnionSearchTable = 4583090000064   --was  gl_primary_hc{0}.idfsRegion
update tasFieldSourceForTable set strFieldText = N'glcra_human_bss{0}.AdminLevel4ID' where idfsSearchField =10080640  and idfUnionSearchTable = 4583090000064   --was  gl_primary_hc{0}.idfsSettlement 

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_human glcra_human_bss{0}   {1}{)}' where idfSearchTable = 4583090000069 
update tasSearchTable set strPKField = N'glcra_human_bss{0}.idfGeoLocationShared' where idfSearchTable = 4583090000069

--new
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel2ID' where idfsSearchField =10080058  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRegion
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel2ID' where idfsSearchField =10080058  and idfUnionSearchTable = 4582900000000   --was  gl_primary_hc{0}.idfsRegion
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel2ID' where idfsSearchField =10080485  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRegion

update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel3ID' where idfsSearchField =10080056  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRayon
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel3ID' where idfsSearchField =10080056  and idfUnionSearchTable = 4582900000000   --was  gl_primary_hc{0}.idfsRayon
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel3ID' where idfsSearchField =10080486  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsRayon

update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel4ID' where idfsSearchField =10080060  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsSettlement 
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel4ID' where idfsSearchField =10080060  and idfUnionSearchTable = 4582900000000   --was  gl_primary_hc{0}.idfsSettlement 
update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel4ID' where idfsSearchField =10080487  and idfUnionSearchTable = 4582670000000   --was  gl_primary_hc{0}.idfsSettlement 

--Need Level change check
update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_human gl_outb{0}   {1}{)}' where idfSearchTable = 4582910000000 
update tasSearchTable set strPKField = N'gl_outb{0}.idfGeoLocationShared' where idfSearchTable = 4582910000000

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_human v_loc{0}   {1}{)}' where idfSearchTable = 4583090000011 
update tasSearchTable set strPKField = N'v_loc{0}.idfGeoLocationShared' where idfSearchTable = 4583090000011

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_human gl_vss{0}   {1}{)}' where idfSearchTable = 4583090000014 
update tasSearchTable set strPKField = N'gl_vss{0}.idfGeoLocationShared' where idfSearchTable = 4583090000014

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location_human vss_loc{0}   {1}{)}' where idfSearchTable = 4583090000016 
update tasSearchTable set strPKField = N'vss_loc{0}.idfGeoLocationShared' where idfSearchTable = 4583090000016

update tasSearchTable set strfrom = N'  {(}  AVR_VW_Location vss_sum_gl{0}   {1}{)}' where idfSearchTable = 4583090000060 
update tasSearchTable set strPKField = N'vss_sum_gl{0}.idfGeoLocationShared' where idfSearchTable = 4583090000060

update tasSearchTableJoinRule set strJoinCondition = N'ON f_adr{0}.idfGeoLocationShared = farm{0}.idfFarmAddress AND f_adr{0}.intRowStatus = 0 ' where idfSearchTable =4582610000000  and idfMainSearchTable = 4582560000000  
update tasSearchTableJoinRule set strJoinCondition = N'ON farm{0}.idfFarmAddress = as_floc{0}.idfGeoLocationShared AND as_floc{0}.intRowStatus = 0 ' where idfSearchTable =4583090000101  and idfMainSearchTable = 4582560000000  
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_cr_hc{0}.idfGeoLocationShared = h_hc{0}.idfCurrentResidenceAddress AND gl_cr_hc{0}.intRowStatus = 0  ' where idfSearchTable =4582700000000  and idfMainSearchTable = 4582670000000  
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_emp_hc{0}.idfGeoLocationShared = h_hc{0}.idfEmployerAddress AND gl_emp_hc{0}.intRowStatus = 0 ' where idfSearchTable =4582710000000  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_hc{0}.idfGeoLocationShared = hc{0}.idfPointGeoLocation AND gl_hc{0}.intRowStatus = 0 ' where idfSearchTable =4582770000000  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_reg_hc{0}.idfGeoLocationShared = h_hc{0}.idfRegistrationAddress AND gl_reg_hc{0}.intRowStatus = 0  ' where idfSearchTable =4582780000000  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_primary_hc{0}.idfGeoLocationShared = case when glve_hc{0}.idfsRayon is not null then hc{0}.idfPointGeoLocation else h_hc{0}.idfCurrentResidenceAddress end ' where idfSearchTable =4583090000002  and 4582670000000 = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON glve_hc{0}.idfGeoLocationShared = hc_cve{0}.idfPointGeoLocation' where idfSearchTable =4583090000058  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_cr_hc{0}.idfGeoLocationShared = h_hc{0}.idfCurrentResidenceAddress AND gl_cr_hc{0}.intRowStatus = 0 ' where idfSearchTable =4582700000000  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_emp_hc{0}.idfGeoLocationShared = h_hc{0}.idfEmployerAddress AND gl_emp_hc{0}.intRowStatus = 0  ' where idfSearchTable =4582710000000  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_hc{0}.idfGeoLocationShared = hc{0}.idfPointGeoLocation AND gl_hc{0}.intRowStatus = 0 ' where idfSearchTable =4582770000000  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_reg_hc{0}.idfGeoLocationShared = h_hc{0}.idfRegistrationAddress AND gl_reg_hc{0}.intRowStatus = 0 ' where idfSearchTable =4582780000000  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON outb{0}.idfGeoLocationShared = gl_outb{0}.idfGeoLocation AND gl_outb{0}.intRowStatus = 0 ' where idfSearchTable =4582910000000  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON vss_loc{0}.idfGeoLocationShared = vss{0}.idfLocation AND vss_loc{0}.intRowStatus = 0  ' where idfSearchTable =4583090000016  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_vss{0}.idfGeoLocationShared = vss_diag{0}.idfLocation AND gl_vss{0}.intRowStatus = 0 ' where idfSearchTable =4583090000014  and idfMainSearchTable = 4583090000013 
update tasSearchTableJoinRule set strJoinCondition = N'ON v_loc{0}.idfGeoLocationShared = v{0}.idfLocation AND v_loc{0}.intRowStatus = 0  ' where idfSearchTable =4583090000011  and idfMainSearchTable = 4583090000015 
update tasSearchTableJoinRule set strJoinCondition = N'ON vss_loc{0}.idfGeoLocationShared = vss{0}.idfLocation AND vss_loc{0}.intRowStatus = 0 ' where idfSearchTable =4583090000016  and idfMainSearchTable = 4583090000015 
update tasSearchTableJoinRule set strJoinCondition = N'ON vss_sum{0}.idfGeoLocationShared = vss_sum_gl{0}.idfGeoLocation  ' where idfSearchTable =4583090000060  and idfMainSearchTable = 4583090000015 
update tasSearchTableJoinRule set strJoinCondition = N'ON v_loc{0}.idfGeoLocationShared = v{0}.idfLocation AND v_loc{0}.intRowStatus = 0  ' where idfSearchTable =4583090000011  and idfMainSearchTable = 4582900000000 

update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel1ID' where idfsSearchField =10080329  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel2ID' where idfsSearchField =10080330  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10080331  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel1ID' where idfsSearchField =10080460  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel2ID' where idfsSearchField =10080461  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10080462  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel1ID' where idfsSearchField =10080479  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel2ID' where idfsSearchField =10080480  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10080481  and idfUnionSearchTable = 4583010000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel2ID' where idfsSearchField =10081102  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10081103  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'f_adr{0}.AdminLevel3ID' where idfsSearchField =10081196  and idfUnionSearchTable = 4582900000000

update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel2ID' where idfsSearchField =10080461  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel3ID' where idfsSearchField =10080462  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel4ID' where idfsSearchField =10080463  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'gl_cr_hc{0}.AdminLevel2ID' where idfsSearchField =10081197  and idfUnionSearchTable = 4582670000000

update tasFieldSourceForTable set strFieldText = N'gl_emp_hc{0}.AdminLevel1ID' where idfsSearchField =10080484  and idfUnionSearchTable = 4582670000000

update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel1ID' where idfsSearchField =10080479  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel2ID' where idfsSearchField =10080480  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.' where idfsSearchField =10080481  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'gl_hc{0}.AdminLevel4ID' where idfsSearchField =10080482  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'case when gl_hc{0}.idfsGeoLocationType = 10036001 /*Foreign Address*/ then null else isnull(district_HCLoc{0}.idfsParent, gl_hc{0}.AdminLevel3ID) end ' where idfsSearchField =10080816  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'case when gl_hc{0}.idfsGeoLocationType = 10036001 /*Foreign Address*/ then null else isnull(district_HCLoc{0}.idfsParent, gl_hc{0}.AdminLevel3ID) end  ' where idfsSearchField =10080816  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'case when gl_hc{0}.idfsGeoLocationType = 10036001 /*Foreign Address*/ then null else isnull(district_HCLoc{0}.idfsParent, gl_hc{0}.AdminLevel3ID) end ' where idfsSearchField =10080816  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'case when gl_hc{0}.idfsGeoLocationType = 10036001 /*Foreign Address*/ or isnull(district_HCLoc{0}.idfsParent, gl_hc{0}.AdminLevel3ID) = gl_hc{0}.AdminLevel3ID then null else district_HCLoc{0}.idfsGeoObject end  ' where idfsSearchField =10080817  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'case when gl_hc{0}.idfsGeoLocationType = 10036001 /*Foreign Address*/ or isnull(district_HCLoc{0}.idfsParent, gl_hc{0}.AdminLevel3ID) = gl_hc{0}.AdminLevel3ID then null else district_HCLoc{0}.idfsGeoObject end  ' where idfsSearchField =10080817  and idfUnionSearchTable = 4582900000000

update tasFieldSourceForTable set strFieldText = N'isnull(district_HC_PPR{0}.idfsParent, gl_reg_hc{0}.AdminLevel3ID) ' where idfsSearchField =10080822  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'isnull(district_HC_PPR{0}.idfsParent, gl_reg_hc{0}.AdminLevel3ID) ' where idfsSearchField =10080822  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'case when isnull(district_HC_PPR{0}.idfsParent, gl_reg_hc{0}.AdminLevel3ID) = gl_reg_hc{0}.AdminLevel3ID then null else district_HC_PPR{0}.idfsGeoObject end  ' where idfsSearchField =10080823  and idfUnionSearchTable = 4582670000000
update tasFieldSourceForTable set strFieldText = N'case when isnull(district_HC_PPR{0}.idfsParent, gl_reg_hc{0}.AdminLevel3ID) = gl_reg_hc{0}.AdminLevel3ID then null else district_HC_PPR{0}.idfsGeoObject end  ' where idfsSearchField =10080823  and idfUnionSearchTable = 4582900000000

update tasFieldSourceForTable set strFieldText = N'gl_outb{0}.AdminLevel1ID' where idfsSearchField =10080106  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'gl_outb{0}.AdminLevel3ID' where idfsSearchField =10080111  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'gl_outb{0}.AdminLevel2ID' where idfsSearchField =10080113  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'gl_outb{0}.AdminLevel4ID' where idfsSearchField =10080115  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'case when gl_outb{0}.idfsGeoLocationType = 10036001 /*Foreign Address*/ then null else isnull(district_otb_prloc{0}.idfsParent, gl_outb{0}.AdminLevel3ID) end ' where idfsSearchField =10080824  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'case when gl_outb{0}.idfsGeoLocationType = 10036001  /*Foreign Address*/ or isnull(district_otb_prloc{0}.idfsParent, gl_outb{0}.AdminLevel3ID) = gl_outb{0}.AdminLevel3ID then null else district_otb_prloc{0}.idfsGeoObject end  ' where idfsSearchField =10080825  and idfUnionSearchTable = 4582900000000

update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel1ID' where idfsSearchField =10080340  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel1ID' where idfsSearchField =10080340  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel2ID' where idfsSearchField =10080341  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel2ID' where idfsSearchField =10080341  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel3ID' where idfsSearchField =10080342  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel3ID' where idfsSearchField =10080342  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel4ID' where idfsSearchField =10080343  and idfUnionSearchTable = 4582900000000
update tasFieldSourceForTable set strFieldText = N'vss_loc{0}.AdminLevel4ID' where idfsSearchField =10080343  and idfUnionSearchTable = 4583090000015

update tasFieldSourceForTable set strFieldText = N'v_loc{0}.AdminLevel1ID' where idfsSearchField =10080351  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'v_loc{0}.AdminLevel2ID' where idfsSearchField =10080352  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'v_loc{0}.AdminLevel3ID' where idfsSearchField =10080353  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'v_loc{0}.AdminLevel4ID' where idfsSearchField =10080354  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'v_loc{0}.AdminLevel1ID' where idfsSearchField =10080915  and idfUnionSearchTable = 4583090000015

update tasFieldSourceForTable set strFieldText = N'gl_vss{0}.AdminLevel1ID' where idfsSearchField =10080329  and idfUnionSearchTable = 4583090000013
update tasFieldSourceForTable set strFieldText = N'gl_vss{0}.AdminLevel2ID' where idfsSearchField =10080330  and idfUnionSearchTable = 4583090000013
update tasFieldSourceForTable set strFieldText = N'gl_vss{0}.AdminLevel3ID' where idfsSearchField =10080331  and idfUnionSearchTable = 4583090000013
update tasFieldSourceForTable set strFieldText = N'gl_vss{0}.AdminLevel4ID' where idfsSearchField =10080332  and idfUnionSearchTable = 4583090000013

update tasFieldSourceForTable set strFieldText = N'vss_sum_gl{0}.AdminLevel1ID' where idfsSearchField =10080605  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'vss_sum_gl{0}.AdminLevel2ID' where idfsSearchField =10080606  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'vss_sum_gl{0}.AdminLevel3ID' where idfsSearchField =10080607  and idfUnionSearchTable = 4583090000015
update tasFieldSourceForTable set strFieldText = N'vss_sum_gl{0}.AdminLevel4ID' where idfsSearchField =10080608  and idfUnionSearchTable = 4583090000015

update  tasSearchTableJoinRule set strJoinCondition =N'  ON gl_cr_hc{0}.idfGeoLocationShared = ha{0}.idfCurrentResidenceAddress AND gl_cr_hc{0}.intRowStatus = 0 ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4582700000000 and idfParentSearchTable= 4582670000000
update  tassearchTable  set strFrom =N'  {(} tlbHumanCase hc{0}  inner join tlbHuman h_hc{0} on  h_hc{0}.idfHuman = hc{0}.idfHuman and h_hc{0}.intRowStatus = 0 inner join tlbHumanActual ha{0} on ha{0}.idfHumanActual = h_hc{0}.idfHumanActual  {1}{)}'  where idfsearchtable = 4582670000000

update tasSearchTableJoinRule set strJoinCondition = N'ON as_floc{0}.AdminLevel4ID = stlm_as_floc{0}.idfsSettlement ' where idfSearchTable =4583090000102  and idfMainSearchTable = 4582560000000  
update tasSearchTableJoinRule set strJoinCondition = N'ON gl_primary_hc{0}.AdminLevel4ID = stlm_primary_hc{0}.idfsSettlement  ' where idfSearchTable =4583090000046  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_hc{0}.AdminLevel4ID = stlm_HCLoc{0}.idfsSettlement  ' where idfSearchTable =4583090000050  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_cr_hc{0}.AdminLevel4ID = stlm_HC_PCR{0}.idfsSettlement ' where idfSearchTable =4583090000051  and idfMainSearchTable = 4582670000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_emp_hc{0}.AdminLevel4ID = stlm_HC_PEmp{0}.idfsSettlement ' where idfSearchTable =4583090000052  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_reg_hc{0}.AdminLevel4ID = stlm_HC_PPR{0}.idfsSettlement ' where idfSearchTable =4583090000053  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_hc{0}.AdminLevel4ID = stlm_HCLoc{0}.idfsSettlement ' where idfSearchTable =4583090000050  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_cr_hc{0}.AdminLevel4ID = stlm_HC_PCR{0}.idfsSettlement ' where idfSearchTable =4583090000051  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  f_adr{0}.AdminLevel4ID = stlm_farm{0}.idfsSettlement' where idfSearchTable =4583090000047  and idfMainSearchTable = 4583010000000 

update tasSearchTableJoinRule set strJoinCondition = N'ON asms{0}.AdminLevel4ID = stlm_asms{0}.idfsSettlement ' where idfSearchTable = 4583090000045  and idfMainSearchTable = 4582550000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON asms{0}.AdminLevel4ID = stlm_asms{0}.idfsSettlement ' where idfSearchTable = 4583090000045  and idfMainSearchTable = 4582560000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_outb{0}.AdminLevel4ID = stlm_otb_prloc{0}.idfsSettlement ' where idfSearchTable = 4583090000054  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  f_loc{0}.AdminLevel4ID = stlm_vc_farmloc{0}.idfsSettlement ' where idfSearchTable = 4583090000057  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  f_loc{0}.AdminLevel4ID = stlm_vc_farmloc{0}.idfsSettlement' where idfSearchTable = 4583090000057  and idfMainSearchTable = 4583010000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_vss{0}.AdminLevel4ID = stlm_vssl{0}.idfsSettlement ' where idfSearchTable = 4583090000048  and idfMainSearchTable = 4583090000013 
update tasSearchTableJoinRule set strJoinCondition = N'ON  v_loc{0}.AdminLevel4ID = stlm_v_loc{0}.idfsSettlement ' where idfSearchTable = 4583090000055  and idfMainSearchTable = 4583090000015 
update tasSearchTableJoinRule set strJoinCondition = N'ON  vss_loc{0}.AdminLevel4ID = stlm_vss_loc{0}.idfsSettlement ' where idfSearchTable = 4583090000056  and idfMainSearchTable = 4582900000000 
update tasSearchTableJoinRule set strJoinCondition = N'ON stlm_vss_sum_gl{0}.AdminLevel4ID = vss_sum_gl{0}.idfsSettlement ' where idfSearchTable = 4583090000061  and idfMainSearchTable = 4583090000015 
update tasSearchTableJoinRule set strJoinCondition = N'ON   fa_adr{0}.AdminLevel4ID = stlm_actual_farm{0}.idfsSettlement ' where idfSearchTable = 4583090000049  and idfMainSearchTable = 4583090000031 
update tasSearchTableJoinRule set strJoinCondition = N'ON s_glcra_human_bss{0}.AdminLevel4ID = glcra_human_bss{0}.idfsSettlement ' where idfSearchTable = 4583090000070  and idfMainSearchTable = 4583090000064 
update tasSearchTableJoinRule set strJoinCondition = N'ON  gl_emp_hc{0}.AdminLevel4ID = stlm_HC_PEmp{0}.idfsSettlement  ' where idfSearchTable = 4583090000052  and idfMainSearchTable = 4582670000000 

--New 4-27-23

update  tasSearchTableJoinRule set strJoinCondition =N'  ON gl_cr_hc{0}.idfGeoLocationShared = ha{0}.idfCurrentResidenceAddress AND gl_cr_hc{0}.intRowStatus = 0 ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4582700000000 and idfParentSearchTable= 4582670000000
update  tassearchTable  set strFrom =N'  {(} tlbHumanCase hc{0}  inner join tlbHuman h_hc{0} on  h_hc{0}.idfHuman = hc{0}.idfHuman and h_hc{0}.intRowStatus = 0 inner join tlbHumanActual ha{0} on ha{0}.idfHumanActual = h_hc{0}.idfHumanActual  {1}{)}'  where idfsearchtable = 4582670000000 


--Problem Fixed 5-1-23

update tasSearchTable set strfrom = N'  {(}    AVR_VW_Location_human gl_reg_hc{0}   {1}{)}   ' where idfSearchTable = 4582780000000 
update tasSearchTable set strfrom = N'   {(}     gisSettlement stlm_HC_PPR{0}    {1}{)}      ' where idfSearchTable = 4583090000053 
update tasSearchTable set strPKField = N'stlm_HC_PPR{0}.idfsSettlement' where idfSearchTable = 4583090000053
update  tasSearchTableJoinRule set strJoinCondition =N'ON  gl_cr_hc{0}.AdminLevel4ID = stlm_HC_PCR{0}.idfsSettlement  ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4583090000051 and idfParentSearchTable= 4582700000000
update  tasSearchTableJoinRule set strJoinCondition =N'ON  gl_emp_hc{0}.AdminLevel4ID = stlm_HC_PEmp{0}.idfsSettlement   ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4583090000052 and idfParentSearchTable= 4582710000000
update  tasSearchTableJoinRule set strJoinCondition =N'ON  gl_reg_hc{0}.AdminLevel4ID = stlm_HC_PPR{0}.idfsSettlement  ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4583090000053 and idfParentSearchTable= 4582780000000

update  tasSearchTableJoinRule set strJoinCondition =N'ON  gl_cr_hc{0}.AdminLevel4ID = stlm_HC_PCR{0}.idfsSettlement  ' where idfMainSearchTable = 4582900000000 and idfSearchTable = 4583090000051 and idfParentSearchTable= 4582700000000
update  tasSearchTableJoinRule set strJoinCondition =N'ON  gl_emp_hc{0}.AdminLevel4ID = stlm_HC_PEmp{0}.idfsSettlement   ' where idfMainSearchTable = 4582900000000 and idfSearchTable = 4583090000052 and idfParentSearchTable= 4582710000000
update  tasSearchTableJoinRule set strJoinCondition =N'ON  gl_reg_hc{0}.AdminLevel4ID = stlm_HC_PPR{0}.idfsSettlement  ' where idfMainSearchTable = 4582900000000 and idfSearchTable = 4583090000053 and idfParentSearchTable= 4582780000000

---Problem Fixed  5-4-23

update tasSearchTable set strfrom = N'   {(}     gisSettlement stlm_asms{0}    {1}{)}      ' where idfSearchTable = 4583090000045 
update  tasSearchTableJoinRule set strJoinCondition =N'ON asms{0}.idfsSettlement = stlm_asms{0}.idfsSettlement ' where idfMainSearchTable = 4582550000000 and idfSearchTable = 4583090000045 and idfParentSearchTable= 4582560000000
update  tasSearchTableJoinRule set strJoinCondition =N'ON asms{0}.idfsSettlement = stlm_asms{0}.idfsSettlement ' where idfMainSearchTable = 4582560000000 and idfSearchTable = 4583090000045 and idfParentSearchTable= 4582560000000
  
update tasSearchTable set strfrom = N' {(} tlbMonitoringSession asms{0} inner join AVR_VW_Location_Human asmsg{0} on  asmsg{0}.idfsLocation = asms{0}.idfsLocation   {1}{)} ' where idfSearchTable = 4582560000000 

update tasFieldSourceForTable set strFieldText = N'asmsg{0}.AdminLevel2ID' where idfsSearchField =10080315  and idfUnionSearchTable = 4582550000000
update tasFieldSourceForTable set strFieldText = N'asmsg{0}.AdminLevel3ID' where idfsSearchField =10080316  and idfUnionSearchTable = 4582550000000

update tasFieldSourceForTable set strFieldText = N'asmsg{0}.AdminLevel2ID' where idfsSearchField =10080315  and idfUnionSearchTable = 4582560000000
update tasFieldSourceForTable set strFieldText = N'asmsg{0}.AdminLevel3ID' where idfsSearchField =10080316  and idfUnionSearchTable = 4582560000000


GO