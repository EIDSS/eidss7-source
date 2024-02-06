-------------------------------------------------------------------
-- Script for Vet Active Surveillance Session fields
-------------------------------------------------------------------

-- Fix to 'VAS Session - Start Date' and 'VAS Session - End Date' breaking save query
--ALTER TABLE dbo.tasFieldSourceForTable DISABLE TRIGGER ALL
--update tasFieldSourceForTable set idfUnionSearchTable = 4582560000000 where idfsSearchField = 10080811 -- previews value 4582550000000
--update tasFieldSourceForTable set idfUnionSearchTable = 4582560000000 where idfsSearchField = 10080812 -- previews value 4582550000000
--ALTER TABLE dbo.tasFieldSourceForTable ENABLE TRIGGER ALL