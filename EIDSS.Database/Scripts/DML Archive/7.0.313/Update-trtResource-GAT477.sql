/*
Author:			Mike Kornegay
Date:			10/25/2022
Description:	Update trtResource for validation messages for in vector module - detailed collections.

*/

--correct misspellings
update trtResource set strResourceName = 'Collection date shall be on or after the session start date.' where idfsResource = 3120
go

--change resource set from 21 (Vector Aggregate) to 85 (Vector Session)
update trtResourceSetToResource set idfsResourceSet = 85 where idfsResource = 3120
go


