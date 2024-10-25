/*
Author:			Mani Govindarajan
Date:			10/04/2022
Description:	Update record in LkupEIDSSAppObject for SystemEventLog Menu in Administration
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF  EXISTS (select 1 from LkupEIDSSAppObject where AppObjectNameID=10506063)
BEGIN
   update LkupEIDSSAppObject   
set strAction='Index', 
Controller='SystemEventLog',
Area ='Administration',
SubArea='Security',
intRowStatus =0
where AppObjectNameID=10506063
END
GO
