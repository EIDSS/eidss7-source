using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Veterinary;
using System;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Administration;

namespace EIDSS.Web.Services
{
    public class FarmStateContainer
    {
        #region Private Members

        private long? farmMasterID;
        private long? farmTypeID;
        private string farmTypeName;
        private long? ownershipStructureTypeID;
        private long? avianFarmTypeID;
        private string eidssFarmOwnerID;
        private long? farmOwnerID;
        private string eidssPersonID;
        private string farmOwner;
        private string farmOwnerLastName;
        private string farmOwnerFirstName;
        private string farmOwnerSecondName;
        private string farmName;
        private string eidssFarmID;
        private string legacyID;
        private string fax;
        private string email;
        private string phone;
        private int? totalLivestockAnimalQuantity;
        private int? totalAvianAnimalQuantity;
        private int? sickLivestockAnimalQuantity;
        private int? sickAvianAnimalQuantity;
        private int? deadLivestockAnimalQuantity;
        private int? deadAvianAnimalQuantity;
        private int? numberOfBuildings;
        private int? numberOfBirdsPerBuilding;
        private string note;
        private DateTime? dateEntered;
        private DateTime? dateModified;
        private long? farmAddressID;
        private long? avianProductionTypeID;
        private bool isAvianDisabled;
        private bool isOwnershipDisabled;
        private bool isReadOnly;
        private bool isEdit;
        private bool _isReview;
        private int rowStatus;
        private int rowAction;
        private IEnumerable<long> selectedFarmTypes;
        private PersonViewModel personModel;
        private List<VeterinaryDiseaseReportViewModel> diseaseReports;
        private List<VeterinaryDiseaseReportViewModel> outbreakCases;
        private LocationViewModel farmLocationModel;
        private UserPermissions farmAddSessionPermissions;
        private UserPermissions veterinaryDiseaseResultPermissions;
    
        #endregion

        public FarmStateContainer()
        {
            FarmLocationModel = new LocationViewModel();
            FarmAddSessionPermissions = new UserPermissions();
        }

        #region Drop Down Collections

        public List<BaseReferenceViewModel> SessionStatuses { get; set; }
        public List<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public List<BaseReferenceAdvancedListResponseModel> Species { get; set; }
        public List<BaseReferenceViewModel> SpeciesTypes { get; set; }
        public List<DiseaseSampleTypeByDiseaseResponseModel> SampleTypes { get; set; }

        #endregion region

        #region Properties  

        public long? FarmMasterID { get => farmMasterID; set { farmMasterID = value; NotifyStateChanged("FarmMasterID"); } }
        public long? FarmTypeID { get => farmTypeID; set { farmTypeID = value; NotifyStateChanged("FarmTypeID"); } }
        public string FarmTypeName { get => farmTypeName; set { farmTypeName = value; NotifyStateChanged("FarmTypeName"); } }
        public long? OwnershipStructureTypeID { get => ownershipStructureTypeID; set { ownershipStructureTypeID = value; NotifyStateChanged("OwnershipStructureTypeID"); } }
        public long? AvianFarmTypeID { get => avianFarmTypeID; set { avianFarmTypeID = value; NotifyStateChanged("AvianFarmTypeID"); } }
        public long? AvianProductionTypeID { get => avianProductionTypeID; set { avianProductionTypeID = value; NotifyStateChanged("AvianProductionTypeID"); } }
        public string EidssFarmOwnerID { get => eidssFarmOwnerID; set { eidssFarmOwnerID = value; NotifyStateChanged("EidssFarmOwnerID"); } }
        public long? FarmOwnerID { get => farmOwnerID; set { farmOwnerID = value; NotifyStateChanged("FarmOwnerID"); } }
        public string EidssPersonID { get => eidssPersonID; set { eidssPersonID = value; NotifyStateChanged("EidssPersonID"); } }
        public string FarmOwner { get => farmOwner; set { farmOwner = value; NotifyStateChanged("FarmOwner"); } }
        public string FarmOwnerLastName { get => farmOwnerLastName; set { farmOwnerLastName = value; NotifyStateChanged("FarmOwnerLastName"); } }
        public string FarmOwnerFirstName { get => farmOwnerFirstName; set { farmOwnerFirstName = value; NotifyStateChanged("FarmOwnerFirstName"); } }
        public string FarmOwnerSecondName { get => farmOwnerSecondName; set { farmOwnerSecondName = value; NotifyStateChanged("FarmOwnerSecondName"); } }
        public string FarmName { get => farmName; set { farmName = value; NotifyStateChanged("FarmName"); } }
        public string EidssFarmID { get => eidssFarmID; set { eidssFarmID = value; NotifyStateChanged("EidssFarmID"); } }
        public string LegacyID { get => legacyID; set { legacyID = value; NotifyStateChanged("LegacyID"); } }
         public string Fax { get => fax; set { fax = value; NotifyStateChanged("Fax"); } }
        public string Email { get => email; set { email = value; NotifyStateChanged("Email"); } }
        public string Phone { get => phone; set { phone = value; NotifyStateChanged("Phone"); } }
        public int? TotalLivestockAnimalQuantity { get => totalLivestockAnimalQuantity; set { totalLivestockAnimalQuantity = value; NotifyStateChanged("TotalLivestockAnimalQuantity"); } }
        public int? TotalAvianAnimalQuantity { get => totalAvianAnimalQuantity; set { totalAvianAnimalQuantity = value; NotifyStateChanged("TotalAvianAnimalQuantity"); } }
        public int? SickLivestockAnimalQuantity { get => sickLivestockAnimalQuantity; set { sickLivestockAnimalQuantity = value; NotifyStateChanged("SickLivestockAnimalQuantity"); } }
        public int? SickAvianAnimalQuantity { get => sickAvianAnimalQuantity; set { sickAvianAnimalQuantity = value; NotifyStateChanged("SickAvianAnimalQuantity"); } }
        public int? DeadLivestockAnimalQuantity { get => deadLivestockAnimalQuantity; set { deadLivestockAnimalQuantity = value; NotifyStateChanged("DeadLivestockAnimalQuantity"); } }
        public int? DeadAvianAnimalQuantity { get => deadAvianAnimalQuantity; set { deadAvianAnimalQuantity = value; NotifyStateChanged("DeadAvianAnimalQuantity"); } }
        public int? NumberOfBuildings { get => numberOfBuildings; set { numberOfBuildings = value; NotifyStateChanged("NumberOfBuildings"); } }
        public int? NumberOfBirdsPerBuilding { get => numberOfBirdsPerBuilding; set { numberOfBirdsPerBuilding = value; NotifyStateChanged("NumberOfBirdsPerBuilding"); } }
        public string Note { get => note; set { note = value; NotifyStateChanged("Note"); } }
        public DateTime? DateEntered { get => dateEntered; set { dateEntered = value; NotifyStateChanged("DateEntered"); } }
        public DateTime? DateModified { get => dateModified; set { dateModified = value; NotifyStateChanged("DateModified"); } }
        public long? FarmAddressID { get => farmAddressID; set { farmAddressID = value; NotifyStateChanged("FarmAddressID"); } }
        public bool IsOwnershipDisabled { get => isOwnershipDisabled; set { isOwnershipDisabled = value; NotifyStateChanged("IsOwnershipDisabled"); } }
        public bool IsAvianDisabled { get => isAvianDisabled; set { isAvianDisabled = value; NotifyStateChanged("IsAvianDisabled"); } }
        public bool IsReadOnly { get => isReadOnly; set { isReadOnly = value; NotifyStateChanged("IsReadOnly"); } }
        public bool IsEdit { get => isEdit; set { isEdit = value; NotifyStateChanged("IsEdit"); } }
        public bool IsReview { get => _isReview; set { _isReview = value; NotifyStateChanged("IsReview"); } }
        public int RowStatus { get => rowStatus; set { rowStatus = value; NotifyStateChanged("RowStatus"); } }
        public int RowAction { get => rowAction; set { rowAction = value; NotifyStateChanged("RowAction"); } }
        public List<VeterinaryDiseaseReportViewModel> DiseaseReports { get => diseaseReports; set { diseaseReports = value; NotifyStateChanged("DiseaseReports"); } }
        public List<VeterinaryDiseaseReportViewModel> OutbreakCases { get => outbreakCases; set { outbreakCases = value; NotifyStateChanged("OutbreakCases"); } }
        public LocationViewModel FarmLocationModel { get => farmLocationModel; set { farmLocationModel = value; NotifyStateChanged("FarmLocationModel"); } }
        public UserPermissions FarmAddSessionPermissions { get => farmAddSessionPermissions; set { farmAddSessionPermissions = value; NotifyStateChanged("FarmAddSessionPermissions"); } }
        public UserPermissions VeterinaryDiseaseResultPermissions { get => veterinaryDiseaseResultPermissions; set { veterinaryDiseaseResultPermissions = value; NotifyStateChanged("VeterinaryDiseaseResultPermissions"); } }
        public IEnumerable<long> SelectedFarmTypes { get => selectedFarmTypes; set { selectedFarmTypes = value; NotifyStateChanged("SelectedFarmTypes"); } }
        public PersonViewModel PersonModel { get => personModel; set { personModel = value; NotifyStateChanged("PersonModel"); } }
        
        public bool FarmHeaderSectionValidIndicator { get; set; }
        public bool FarmInformationSectionValidIndicator { get; set; }
        public bool FarmInformationSectionChangedIndicator { get; set; }
        public bool FarmAddressSectionValidIndicator { get; set; }
        public bool FarmAddressSectionChangedIndicator { get; set; }
        public bool FarmReviewSectionValidIndicator { get; set; }

        #endregion

        #region Collections

        public IList<EventSaveRequestModel> PendingSaveEvents { get; set; }

        #endregion

        #region Events

        /// <summary>
        /// The event that will be raised for state changed.
        /// </summary>
        public event Action<string> OnChange;

        #endregion

        #region Private Methods

        /// <summary>
        /// The state change event notification
        /// </summary>
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);

        #endregion
    }
}
