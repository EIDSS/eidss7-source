UPDATE tasFieldSourceForTable set strFieldText =N'f_adr{0}.AdminLevel4ID' where idfsSearchField = 10080332 and idfUnionSearchTable = 4583010000000 and idfSearchTable = 4582610000000

GO


update  tasSearchTableJoinRule set strJoinCondition =N'ON glve_hc{0}.AdminLevel1ID =  country_cve{0}.idfsCountry ' where idfMainSearchTable = 4582670000000 and idfSearchTable = 4583090000104 and idfParentSearchTable= 4583090000058
GO
