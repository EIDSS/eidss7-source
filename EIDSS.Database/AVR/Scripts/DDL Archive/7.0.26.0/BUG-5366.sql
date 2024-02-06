IF EXISTS(SELECT * FROM tasSearchTable where idfSearchTable = 4583090000033 )
begin
Update tasSearchTable set strExistenceCondition =N'fa_adr{0}.intRowStatus = 0 AND fa_adr{0}.AdminLevel1ID IS NOT NULL fa_adr{0}.AdminLevel2ID IS NOT NULL fa_adr{0}.AdminLevel3ID IS NOT NULL ' where idfSearchTable = 4583090000033
end