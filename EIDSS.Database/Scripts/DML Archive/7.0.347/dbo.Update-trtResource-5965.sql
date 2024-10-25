/*
	Update to the trtResource table. Should be run on all existing databases, and the master.

	Changes the label of "Duration" to "Duration (Dasy")

	Author: Doug Albanese
*/

update trtResource
set strResourceName = 'Duration (Days)'
where idfsResource = 1009
