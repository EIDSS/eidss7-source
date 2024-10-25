if exists (select * from tasSearchTable where idfSearchTable = 4582560000000)
Begin
update tasSearchTable set strExistenceCondition =N'asms{0}.intRowStatus = 0 AND asms{0}.SessionCategoryID = 10502002' where idfSearchTable = 4582560000000
End