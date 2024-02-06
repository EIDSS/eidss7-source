using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Components.Administration.Deduplication;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.Services
{
    public class FarmDeduplicationSessionStateContainerService
    {
        #region backing fields
        private IList<Field> infoList { get; set; }
        private IList<Field> infoList2 { get; set; }
        private IEnumerable<int> infoValues { get; set; }
        private IEnumerable<int> infoValues2 { get; set; }

        private IList<VeterinaryDiseaseReportViewModel> diseaseReports;
        private IList<VeterinaryDiseaseReportViewModel> diseaseReports2;
        private IList<VeterinaryDiseaseReportViewModel> survivorDiseaseReports;

        #endregion
        #region Globals

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;

        public long FarmMasterID { get; set; }
        public long FarmMasterID2 { get; set; }

        public IList<FarmViewModel> Records { get; set; }
        public IList<FarmViewModel> SelectedRecords { get; set; }
        public IList<FarmViewModel> SearchRecords { get; set; }
        public bool TabChangeIndicator { get; set; }
        public FarmDeduplicationTabEnum Tab { get; set; }

        public IList<Field> InfoList { get => infoList; set { infoList = value; NotifyStateChanged("InfoList"); } }
        public IList<Field> InfoList2 { get => infoList2; set { infoList2 = value; NotifyStateChanged("InfoList2"); } }
        public IList<Field> InfoList0 { get; set; }
        public IList<Field> InfoList02 { get; set; }

        public IEnumerable<int> InfoValues { get => infoValues; set { infoValues = (IEnumerable<int>)value; NotifyStateChanged("InfoValues"); } }
        public IEnumerable<int> InfoValues2 { get => infoValues2; set { infoValues2 = (IEnumerable<int>)value; NotifyStateChanged("InfoValues2"); } }

        public IList<VeterinaryDiseaseReportViewModel> DiseaseReports { get => diseaseReports; set { diseaseReports = value; NotifyStateChanged("DiseaseReports"); } }
        public IList<VeterinaryDiseaseReportViewModel> DiseaseReports2 { get => diseaseReports2; set { diseaseReports2 = value; NotifyStateChanged("DiseaseReports2"); } }
        public int DiseaseReportCount { get; set; }
        public int DiseaseReportCount2 { get; set; }

        public int RecordSelection { get; set; }
        public int Record2Selection { get; set; }

        public bool chkCheckAll { get; set; }
        public bool chkCheckAll2 { get; set; }

        public long SurvivorFarmMasterID { get; set; }
        public long SupersededFarmMasterID { get; set; }

        public IList<Field> SurvivorInfoList { get; set; }
        public IEnumerable<int> SurvivorInfoValues { get; set; }

        public int SurvivorDiseaseReportCount { get; set; }
        public IList<VeterinaryDiseaseReportViewModel> SurvivorDiseaseReports { get => survivorDiseaseReports; set { survivorDiseaseReports = value; NotifyStateChanged("SurvivorDiseaseReports"); } }

        #endregion

        #region Methods


        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);


        #endregion
    }
}
