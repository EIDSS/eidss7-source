ALTER TABLE dbo.tasSearchObjectToSearchObject DISABLE TRIGGER ALL
ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL

Update tasSearchObjectToSearchObject set idfsRelatedSearchObject =10082072 where idfsParentSearchObject = 10082071
update tasFieldSourceForTable set strFieldText =N'ap{0}.idfsParameter', idfUnionSearchTable=4583090000138 ,idfSearchTable =4583090000138 where idfsSearchField =10081261  -- was HAggrCaseCol{0}.idfsParameter  4583090000078	4583090000088

ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL
ALTER TABLE dbo.tasSearchObjectToSearchObject ENABLE TRIGGER ALL

--SELECT * FROM tasFieldSourceForTable fsft WHERE strFieldText =N'ap{0}.idfsParameter'