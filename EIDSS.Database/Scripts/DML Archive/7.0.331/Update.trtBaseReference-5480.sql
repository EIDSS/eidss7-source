/*
	This needs to be ran on all environments, because the existing content is incorrect.

	This also needs to be ran on the master script, during the migration of any EIDSS 6.1 database.
*/

Update trtBaseReference
set strDefault = 'Total'
where idfsBaseReference = 10067010

Update trtBaseReference
set strDefault = 'Summing'
where idfsBaseReference = 10067011