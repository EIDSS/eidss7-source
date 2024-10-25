using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class AnimalGetListViewModel : BaseModel
    {
        public AnimalGetListViewModel ShallowCopy()
        {
            return (AnimalGetListViewModel)MemberwiseClone();
        }

        public long AnimalID { get; set; }
        public long? SexTypeID { get; set; }
        public string SexTypeName { get; set; }
        public long? ConditionTypeID { get; set; }
        public string ConditionTypeName { get; set; }
        public long? AgeTypeID { get; set; }
        public string AgeTypeName { get; set; }
        public long? SpeciesID { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? ObservationID { get; set; }
        public string AnimalDescription { get; set; }
        public string EIDSSAnimalID { get; set; }
        public string AnimalName { get; set; }
        public string Color { get; set; }
        public int RowStatus { get; set; }
        public long? HerdID { get; set; }
        public string EIDSSHerdID { get; set; }
        public string Species { get; set; }
        public string ClinicalSigns { get; set; }
        public long? ClinicalSignsIndicator { get; set; }
        public FlexFormQuestionnaireGetRequestModel ClinicalSignsFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> ClinicalSignsFlexFormAnswers { get; set; }
        public string ClinicalSignsObservationParameters { get; set; }
        public int RowAction { get; set; }
    }
}
