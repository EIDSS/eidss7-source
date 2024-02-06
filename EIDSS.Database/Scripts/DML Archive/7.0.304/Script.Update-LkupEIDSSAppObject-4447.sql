/*
Author:			Mani Govindarajan
Date:			10/19/2022
Description:	Update record in LkupEIDSSAppObject ticket 4447
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF  EXISTS (select 1 from LkupEIDSSAppObject where AppObjectNameID =10506218)
BEGIN
update LkupEIDSSAppObject set Controller ='LivestockDiseaseInvestigationForm' ,intRowStatus=0   where AppObjectNameID =10506218
END
GO
