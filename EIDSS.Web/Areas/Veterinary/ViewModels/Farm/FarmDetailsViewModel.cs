using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Areas.Administration.ViewModels.Organization;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{ 
    public class FarmDetailsViewModel
    {
        public long? FarmMasterID { get; set; }
        public bool IsReadonly { get; set; }
        public bool DisableFarmId { get; set; } = true;
        public string EIDSSFarmID { get; set; }
        public string LegacyFarmID { get; set; }
        public long? FarmTypeID { get; set; }
        public IEnumerable<long> SelectedFarmTypes { get; set; }
        public string FarmOwnerFirstName { get; set; }
        public string FarmOwnerLastName { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? FarmOwnerID { get; set; }
        public long? RegionID { get; set; }
        public long? RayonID { get; set; }
        public long? SettlementID { get; set; }
        public long? SettlementTypeID { get; set; }
        public long? MonitoringSessionID { get; set; }

        public bool FarmSectionValidIndicator { get; set; }

        public FarmSearchRequestModel SearchCriteria { get; set; }
        public List<FarmViewModel> SearchResults { get; set; }
        public UserPermissions FarmSearchPermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public long BottomAdminLevel { get; set; }

        public bool RecordSelectionIndicator { get; set; }

        public bool DeleteVisibleIndicator { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public long? OrganizationKey { get; set; }
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public FarmInfoSectionViewModel FarmInfoSection { get; set; }
        public AddressSectionViewModel AddressSection  { get; set; }

        public long? FarmID { get; internal set; }
        public string strfarmID { get; internal set; }

        public string DateEntered { get; set; }
        public string DateModified { get; set; }

        public long? TimeIntervalTypeID { get; set; }

        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? StartDate { get; set; }

        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? EndDate { get; set; }

        public long? AdministrativeUnitTypeID { get; set; }  //todo: rename to administrative unit type ID once human agg complete.

        public bool NotificationSectionValidIndicator { get; set; }

        //public static implicit operator FarmDetailsViewModel(List<FarmGetListDetailViewModel> v)
        //{
        //    throw new NotImplementedException();
        //}
    }
}
