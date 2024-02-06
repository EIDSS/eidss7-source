/*
Author:		Ann Xiong
Date:			12/21/2022
Description:	Update record in trtBaseReference to remove Animal Disease Reports from Dashboard Icons list
Note:           -Be sure the record exists in table
                -Also be sure that you add your script to the PostDeploy.sql script or it will not execute!
*/

IF  EXISTS (select 1 from trtBaseReference where idfsBaseReference = 10506118)
BEGIN
	Update trtBaseReference
	Set intRowStatus = 1
	Where idfsBaseReference = 10506118
END
GO