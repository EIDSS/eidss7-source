-- Fix to incorrect system functions permissions in AVR
alter table dbo.tasSearchObjectToSystemFunction disable trigger all
insert into trtSystemFunction (idfsSystemFunction, idfsObjectType) values (10094547,10094547) -- create new system function relation Access to Outbreak Human Case Data
update tasSearchObjectToSystemFunction set idfsSystemFunction = 10094547 where idfsSearchObject = 10082057 -- update system function from 10094506 to 10094547
update tasSearchObjectToSystemFunction set idfsSystemFunction = 10094033 where idfsSearchObject = 10082053 -- update system function from 10094506 to 10094033
insert into trtSystemFunction (idfsSystemFunction, idfsObjectType) values (10094548,10082061) -- create new system function relation Access to Outbreak Veterinary Case Data
update tasSearchObjectToSystemFunction set idfsSystemFunction = 10094548 where idfsSearchObject = 10082061 -- update system function from 10094506 to 10094548
update tasSearchObjectToSystemFunction set idfsSystemFunction = 10094053 where idfsSearchObject = 10082067 -- update system function from 10094506 to 10094053
update tasSearchObjectToSystemFunction set idfsSystemFunction = 10094054 where idfsSearchObject = 10082069 -- update system function from 10094506 to 10094054
update tasSearchObjectToSystemFunction set idfsSystemFunction = 10094054 where idfsSearchObject = 10082073 -- update system function from 10094506 to 10094054
alter table dbo.tasSearchObjectToSystemFunction enable trigger all

GO