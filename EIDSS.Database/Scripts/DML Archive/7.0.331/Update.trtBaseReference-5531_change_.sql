/*
	Master DB updates for new deployments
*/

update trtBaseReference set intOrder = 2 where idfsBaseReference = 10063501
update trtBaseReference set intOrder = 1 where idfsBaseReference = 10063502
update trtBaseReference set intOrder = 0 where idfsBaseReference = 10063503
GO