using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class FarmInventoryGetListViewModel : BaseModel
    {
        public FarmInventoryGetListViewModel ShallowCopy()
        {
            return MemberwiseClone() as FarmInventoryGetListViewModel;
        }
        public int RecordID { get; set; }
        public string RecordType { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public long? FlockOrHerdID { get; set; }
        public long? FlockOrHerdMasterID { get; set; }
        public long? SpeciesID { get; set; }
        public long? SpeciesMasterID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public string EIDSSFarmID { get; set; }
        public string EIDSSFlockOrHerdID { get; set; }
        public DateTime? StartOfSignsDate { get; set; }
        public string AverageAge { get; set; }
        public int? SickAnimalQuantity { get; set; }
        public int? TotalAnimalQuantity { get; set; }
        public int? DeadAnimalQuantity { get; set; }
        public long? ObservationID { get; set; }
        public FlexFormQuestionnaireGetRequestModel SpeciesClinicalInvestigationFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> SpeciesClinicalInvestigationFlexFormAnswers { get; set; }
        public string SpeciesClinicalInvestigationObservationParameters { get; set; }
        public string Note { get; set; }
        public long? OutbreakCaseStatusTypeID { get; set; }
        public string OutbreakCaseStatusTypeName { get; set; }
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }

        private string species;
        public string Species
        {
            get
            {
                //TODO: replace hard-coded value.
                if (RecordType == "Species")
                    species = EIDSSFlockOrHerdID + " - " + SpeciesTypeName;

                return species;
            }
        }
    }
}
