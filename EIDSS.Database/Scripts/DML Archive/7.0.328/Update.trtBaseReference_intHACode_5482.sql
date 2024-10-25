/*
	This script MUST be applied to the master DB, so that migration will automatically update the base reference items for the intHACode column.

	Since this is an update, it can be ran on all environments, especially Regression...since it is the environment that this was discovered.
*/

	
update trtBaseReference set intHACode = 64 where idfsBaseReference = 10034007
update trtBaseReference set intHACode = 64 where idfsBaseReference = 10034008
update trtBaseReference set intHACode = 2 where idfsBaseReference = 10034010
update trtBaseReference set intHACode = 2 where idfsBaseReference = 10034011
update trtBaseReference set intHACode = 2 where idfsBaseReference = 10034012
update trtBaseReference set intHACode = 32 where idfsBaseReference = 10034013
update trtBaseReference set intHACode = 32 where idfsBaseReference = 10034014
update trtBaseReference set intHACode = 32 where idfsBaseReference = 10034015
update trtBaseReference set intHACode = 32 where idfsBaseReference = 10034016
update trtBaseReference set intHACode = 510 where idfsBaseReference = 10034018
update trtBaseReference set intHACode = 510 where idfsBaseReference = 10034019
update trtBaseReference set intHACode = 96 where idfsBaseReference = 10034021
update trtBaseReference set intHACode = 96 where idfsBaseReference = 10034022
update trtBaseReference set intHACode = 96 where idfsBaseReference = 10034023
update trtBaseReference set intHACode = 96 where idfsBaseReference = 10034024
update trtBaseReference set intHACode = 128 where idfsBaseReference = 10034025

GO