using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class ReportCrossCuttingClientMock : BaseClientMock<IReportCrossCuttingClient>, IReportCrossCuttingClient
    {
        public Task<List<CurrentCountryViewModel>> GetCurrentCountryList(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<HumanComparitiveCounterViewModel>> GetHumanComparitiveCounter(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<HumanComparitiveCounterGGViewModel>> GetHumanComparitiveCounterGG(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<WhoMeaslesRubellaDiagnosisViewModel>> GetHumanWhoMeaslesRubellaDiagnosis()
        {
            throw new NotImplementedException();
        }

        public Task<List<HumDateFieldSourceViewModel>> GetHumDateFieldSourceList(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<LABAssignmentDiagnosticAZSendToViewModel>> GetLABAssignmentDiagnosticAZSendToList(string languageId, string caseId)
        {
            throw new NotImplementedException();
        }

        public Task<List<LABTestingResultsDepartmentViewModel>> GetLABTestingResultsDepartmentList(string languageId, string sampleId)
        {
            throw new NotImplementedException();
        }

        public Task<List<ReportListViewModel>> GetReportList()
        {
            throw new NotImplementedException();
        }

        public Task<List<ReportOrganizationViewModel>> GetReportOrganizationList(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<ReportingPeriodViewModel>> GetReportPeriod(string languageId, string year, string reportingPeriodType)
        {
            throw new NotImplementedException();
        }

        public Task<List<ReportingPeriodTypeViewModel>> GetReportPeriodType(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<SpeciesTypeViewModel>> GetSpeciesTypes(string languageId, long? idfsDiagnosis)
        {
            throw new NotImplementedException();
        }

        public Task<List<TuberculosisDiagnosisViewModel>> GetTuberculosisDiagnosisList(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<VetDateFieldSourceViewModel>> GetVetDateFieldSourceList(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<VetNameOfInvestigationOrMeasureViewModel>> GetVetNameOfInvestigationOrMeasure(string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<VetSummarySurveillanceTypeViewModel>> GetVetSummarySurveillanceType(string languageId)
        {
            throw new NotImplementedException();
        }
    }
}
