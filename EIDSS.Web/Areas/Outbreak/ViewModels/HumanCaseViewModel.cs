using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.ViewModels.Human;
using System;

namespace EIDSS.Web.Areas.Outbreak.ViewModels
{
    public class HumanCaseViewModel
    {
        public long idfOutbreak { get; set; }
        public bool IsReadOnly { get; set; }
        public long HumanMasterID { get; set; }
        public long OutbreakCaseReportUID { get; set; } = -1;
        public string RelatedToIdentifiers { get; set; }
        public string RelatedToReportIdentifiers { get; set; }
        public OutbreakSessionDetailsResponseModel SessionDetails { get; set; }
        public OutbreakSessionParametersListModel SessionParameters { get; set; }
        public OutbreakCaseDetailsModel CaseDetails { get; set; }
        public OutbreakCaseSummaryModel CaseSummaryDetails { get; set; }
        public DiseaseReportComponentViewModel diseaseReportComponentViewModel { get; set; }
        public DiseaseReportSummaryPageViewModel ReportSummary { get; set; }
        public string CancelURL { get; set; }
        public CaseGetDetailViewModel Case { get; set; }
        public DiseaseReportPrintViewModel CaseReportPrintViewModal { get; set; }
    }

    public class OutbreakCaseSummaryModel 
    {
        public string EIDSSPersonID { get; set; }
        public long HumanMasterID { get; set; }
        public string Name { get; set; }
        private string _dateEntered;
        public string DateEntered
        {
            get
            {
                return _dateEntered;
            }
            set
            {
                _dateEntered = DateTime.Parse(value).ToShortDateString();

            }
        }

        private DateTime? _lastUpdated;
        public DateTime? LastUpdated
        {
            get
            {
                return _lastUpdated;
            }
            set
            {
                _lastUpdated = value;
                DateTime returnValue;
                if (DateTime.TryParse(value.ToString(), out returnValue))
                {
                    strLastUpdated = returnValue.ToShortDateString();
                }
            }
        }

        public string strLastUpdated { get; set; }
        public string CaseClassification { get; set; }
    }
}
