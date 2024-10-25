---Problem Fixed  5-30-23

update  tasSearchTableJoinRule set strJoinCondition =N'ON  vss_loc{0}.AdminLevel4ID = stlm_vss_loc{0}.idfsSettlement ' where idfMainSearchTable = 4583090000015 and idfSearchTable = 4583090000056 and idfParentSearchTable= 4583090000016
update tasSearchTable set strFrom =N'', strPKField='f_adr{0}.idfGeoLocationShared' where idfSearchTable =  4582610000000
