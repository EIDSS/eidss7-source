set nocount on

update		o
set			o.OrganizationTypeID = 10504001 /*Laboratory*/
from		[Giraffe].[dbo].tlbOffice o
where		exists
			(	select	1
				from	[Giraffe].[dbo].tlbMaterial m
				where	m.idfSendToOffice = o.idfOffice
						and m.intRowStatus = 0
			)

update		o
set			o.OrganizationTypeID = 10504002 /*Hospital*/
from		[Giraffe].[dbo].tlbOffice o
where		(o.OrganizationTypeID is null or o.OrganizationTypeID = 10504003 /*Other*/)
			and exists
			(	select	1
				from	[Giraffe].[dbo].tlbHumanCase hc
				where	hc.idfHospital = o.idfOffice
						and hc.intRowStatus = 0
			)


update		o
set			o.OrganizationTypeID = 10504003 /*Other*/
from		[Giraffe].[dbo].tlbOffice o
where		o.OrganizationTypeID is null
			and o.intRowStatus = 0

update		o_arch
set			o_arch.OrganizationTypeID = o.OrganizationTypeID
from		[Giraffe].[dbo].tlbOffice o
join		[Giraffe_Archive].[dbo].tlbOffice o_arch
on			o_arch.idfOffice = o.idfOffice
where		o.OrganizationTypeID is not null
			and (o_arch.OrganizationTypeID is null or o_arch.OrganizationTypeID <> o.OrganizationTypeID)


update		o_arch
set			o_arch.OrganizationTypeID = 10504003 /*Other*/
from		[Giraffe_Archive].[dbo].tlbOffice o_arch
where		o_arch.OrganizationTypeID is null
			and o_arch.intRowStatus = 0

set nocount off


