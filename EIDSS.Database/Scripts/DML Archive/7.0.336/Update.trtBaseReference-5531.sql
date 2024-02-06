/*
	Updates to convert the order of Outbreak Status to guide the initial Session Listing in Outbreak.


	IMPORTANT! This is necessary for the master DB, so that migration will have these items on a new install.
*/

update trtBaseReference set intOrder = 2 where idfsBaseReference = 10063501
update trtBaseReference set intOrder = 1 where idfsBaseReference = 10063502
update trtBaseReference set intOrder = 0 where idfsBaseReference = 10063503