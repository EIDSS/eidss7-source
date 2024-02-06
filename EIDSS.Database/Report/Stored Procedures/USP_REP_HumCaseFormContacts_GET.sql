--##SUMMARY Select Contacts data for Human report.
--##REMARKS Author: Srini Goli.
--##REMARKS Create date: 03/22/2022
--Srini Goli 10/20/2022 Updated to get Relation_Type 


--##RETURNS Doesn't use

/*
--Example of a call of procedure:

exec report.USP_REP_HumCaseFormContacts_GET @LangID=N'en-US',@ObjID=90723


*/

create  Procedure [Report].[USP_REP_HumCaseFormContacts_GET]
    (
        @LangID as nvarchar(10),
        @ObjID	as bigint
    )
as
begin
	
	select 
	dbo.fnConcatFullName(tHuman.strLastName, 
							tHuman.strFirstName, 
							tHuman.strSecondName) as ContactName,
	rfContactType.[name]			as Relation_Type,
	datDateOfLastContact			as ContactDate,
	tContacted.strPlaceInfo			as PlaceOfContact,
	(
		IsNull(dbo.FN_GBL_AddressString(@LangID, tHuman.idfCurrentResidenceAddress) + ', ', '') + 
		IsNull(tHuman.strHomePhone, '')
	)								as ContactInformation,
	dbo.FN_GBL_AddressStringDenyRigths(@LangID, tHuman.idfCurrentResidenceAddress, 1)		
									as ContactInformationDenyRightsSettlement,
	dbo.FN_GBL_AddressStringDenyRigths(@LangID, tHuman.idfCurrentResidenceAddress, 0)		
									as ContactInformationDenyRightsDetailed		,
	tContacted.strComments			as Comments

	from		dbo.tlbContactedCasePerson	as tContacted
	 inner join	dbo.tlbHuman				as tHuman
			on	tHuman.idfHuman	= tContacted.idfHuman
				AND tHuman.intRowStatus = 0
	 LEFT JOIN dbo.FN_GBL_ReferenceRepair(@LangID, 19000014) AS rfContactType ON rfContactType.idfsReference = tContacted.idfsPersonContactType
	 --left join	dbo.FN_GBL_GIS_ReferenceRepair_GET(@LangID, 19000014 /*rftPartyRelationType */) as rfContactType
		--	on	rfContactType.idfsReference = tContacted.idfsPersonContactType
		 where	tContacted.idfHumanCase = @ObjID

end			



GO


