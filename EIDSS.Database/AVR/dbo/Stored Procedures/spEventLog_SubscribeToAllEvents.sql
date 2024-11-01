--##SUMMARY SSubscribes client application to all events.
--##SUMMARY Called by EIDSS Client Agent or by EIDSS Notification Service to force them receiving all events.

--##REMARKS Author: Zurin M.
--##REMARKS Create date: 17.12.2009

--##REMARKS UPDATED BY: Vorobiev E.
--##REMARKS Date: 14.07.2011

--##REMARKS UPDATED BY: Edgard Torres.
--##REMARKS Date: 24.04.2023
-- Added condition to only subscribe client to:
-- 'New AVR layout was published at your site' (10025115), New AVR layout folder was unpublished at your site' (10025132)
-- 'New AVR layout was published at your neighboring site' (10025116), 'New AVR layout was unpublished at third-party site' (10025133)
-- 'New AVR layout shared' (10025117), there is no unshared layout message

--##RETURNS Doesn't use

/*
--Example of a call of procedure:
EXEC spEventLog_SubscribeToAllEvents '12345'
*/




CREATE procedure [dbo].[spEventLog_SubscribeToAllEvents](
	@idfClientID as nvarchar(50)--##PARAM @ClientID - client application ID.
)
as

IF NOT EXISTS (SELECT strClient FROM tstLocalClient WHERE strClient = @idfClientID)  
	INSERT INTO tstLocalClient (strClient) VALUES (@idfClientID)  

INSERT tstEventSubscription (
	idfsEventTypeID, strClient
	)  
	SELECT idfsReference, @idfClientID  
	FROM fnReference('en', 19000025) as EventType --'rftEventType'  
	WHERE Not Exists(Select * From tstEventSubscription Where tstEventSubscription.idfsEventTypeID = EventType.idfsReference 
	And strClient = @idfClientID)
	And EventType.idfsReference in (10025115,10025116,10025117,10025132,10025133)

GO
