-- Script for general bug fixes
-- jun.xiong <jun.xiong@peraton.com>	7/20/2022 7:29:05 PM +00:00	4572 AVR | Query | missing option "Both" in the Queries
Update trtBaseReference
Set intRowStatus = 0
Where idfsBaseReference = 50815490000000
GO

-- Fix to display human diseases name in AVR Human Disease Report.
update tasFieldSourceForTable set strFieldText = 'hc{0}.idfsFinalDiagnosis' where rowguid = 'D9BAFDE7-14F4-4961-B2CB-22AA798079D1' -- old value is d_init_hc{0}.idfsDiagnosis
GO

-- Fix object Human Disease Report (10082012) and ILI Aggregate Form (10082043) system functions not showing on fnReference('en', 19000094) return
update trtBaseReference set intRowStatus = 0 where idfsBaseReference =  10094027 -- previews value was 1
update trtBaseReference set intRowStatus = 0 where idfsBaseReference =  10094051 -- same problem for ILI Aggregate Form sytem function 
GO

-- Enable 'Basic Syndromic Surveillance Form' Ticket 5994
update trtBaseReference set intRowStatus = 0 where idfsBaseReference =  10082042