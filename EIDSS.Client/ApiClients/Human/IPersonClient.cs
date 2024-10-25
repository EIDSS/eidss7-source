using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public interface IPersonClient
    {
        Task<List<PersonViewModel>> GetPersonList(HumanPersonSearchRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportPersonInfoAsync(HumanPersonDetailsRequestModel request);
        Task<PersonSaveResponseModel> SavePerson(PersonSaveRequestModel request);
        Task<List<PersonForOfficeViewModel>> GetPersonListForOffice(GetPersonForOfficeRequestModel request);
        Task<APIPostResponseModel> DeletePerson(long HumanMasterID, long? idfDataAuditEvent, string AuditUserName);
        Task<APIPostResponseModel> DedupePersonFarm(PersonDedupeRequestModel request);
        Task<APIPostResponseModel> DedupePersonHumanDisease(PersonDedupeRequestModel request);
        Task<PersonSaveResponseModel> DedupePersonRecords(PersonRecordsDedupeRequestModel request, CancellationToken cancellationToken = default);
        Task<int> UpdatePersonAsync(UpdateHumanActualRequestModel request);
    }
}
