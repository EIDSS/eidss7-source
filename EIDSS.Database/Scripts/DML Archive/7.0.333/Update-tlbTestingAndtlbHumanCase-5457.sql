/*

	Mike Kornegay
	02/13/2023
	This script corrects migrated basic syndromic surveillance sessions by doing the following:
	1.  Joins entries in tlbTesting to their corresponding entries in tlbMaterial by attaching idfMaterial to the test.
	2.  Changes the idfsYNSpecimenCollected field to be the correct yes value instead of the reference type.

	Note:  The select statements are only for testing to verify counts before running updates and are not necessary

*/

--basic syndromic records with tests that are not tied to their samples
select			*
from			tlbTesting t
inner join		tlbMaterial m
on				t.idfHumanCase = m.idfHumanCase
inner join		tlbHumanCase hc
on				hc.idfHumanCase = t.idfHumanCase
where			hc.LegacyCaseID is not null
--and				hc.idfsFinalDiagnosis = 10019001
and				hc.SourceSystemKeyValue like '%idfBasicSyndromicSurveillance%'
and				t.idfMaterial is null


--basic syndromic records that have 19000100 for the 'yes' value instead of the proper 10100001
select			*
from			tlbHumanCase hc
inner join		tlbMaterial m
on				m.idfHumanCase = hc.idfHumanCase
where			hc.LegacyCaseID is not null
--and				hc.idfsFinalDiagnosis = 10019001
and				hc.SourceSystemKeyValue like '%idfBasicSyndromicSurveillance%'
and				hc.idfsYNSpecimenCollected = 19000100


begin tran
update			t
set				t.idfMaterial = m.idfMaterial
from			tlbTesting t
inner join		tlbMaterial m
on				t.idfHumanCase = m.idfHumanCase
inner join		tlbHumanCase hc
on				hc.idfHumanCase = t.idfHumanCase
where			hc.LegacyCaseID is not null
--and				hc.idfsFinalDiagnosis = 10019001
and				hc.SourceSystemKeyValue like '%idfBasicSyndromicSurveillance%'
and				t.idfMaterial is null
commit tran

begin tran
update			hc
set				hc.idfsYNSpecimenCollected = 10100001
from			tlbHumanCase hc
inner join		tlbMaterial m
on				m.idfHumanCase = hc.idfHumanCase
where			hc.LegacyCaseID is not null
--and				hc.idfsFinalDiagnosis = 10019001
and				hc.SourceSystemKeyValue like '%idfBasicSyndromicSurveillance%'
and				hc.idfsYNSpecimenCollected = 19000100
commit tran
