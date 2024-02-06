using System;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.CrossCutting;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;

namespace EIDSS.Web.Areas.Outbreak.ViewModels
{
    public class OutbreakSessionViewModel
    {
        public string CurrentLanguage { get; set; }
        //public DateTime? Today { get; set; }
        public OutbreakSessionDetailsResponseModel SessionDetails { get; set; }
        public bool IsSessionClosed { get; set; } = false;
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        public bool idfscbHuman { get; set; }
        public bool idfscbAvian { get; set; }
        public bool idfscbLivestock { get; set; }
        public bool idfscbVector { get; set; }
        public bool bHasHumanCases { get; set; }
        public bool bHasVetCases { get; set; }
        public string HumanSpecies { get; set; } = "<input type=\"checkbox\" id=\"idfscbHuman\" asp-for=\"idfscbHuman\" species=\"Human\" onclick=\"outbreakCreate.showParameters(this, 'Human');\" [ATTRIBUTES] />";
        public string AvianSpecies { get; set; } = "<input type=\"checkbox\" id=\"idfscbAvian\" asp-for=\"idfscbAvian\" species=\"Avian\" onclick=\"outbreakCreate.showParameters(this, 'Avian')\" [ATTRIBUTES] />";
        public string LivestockSpecies { get; set; } = "<input type=\"checkbox\" id=\"idfscbLivestock\" asp-for=\"idfscbLivestock\" species=\"Livestock\" onclick=\"outbreakCreate.showParameters(this, 'Livestock')\" [ATTRIBUTES] />";
        public string VectorSepceis { get; set; } = "<input type=\"checkbox\" id=\"idfscbVector\" asp-for=\"idfscbVector\" species=\"Vector\" onclick=\"outbreakCreate.showParameters(this, 'Vector')\" [ATTRIBUTES] />";

        //Location Control Properties
        public LocationViewModel SessionLocationViewModel { get; set; }

        public LocationViewModel FormLocationViewModel { get; set; }
        public List<BaseReferenceViewModel> SearchTimeIntervalList { get; set; }
        public List<BaseReferenceViewModel> SearchAdministrativeUnitTypeList { get; set; }
        public List<GisLocationCurrentLevelModel> SearchOrganizationList { get; set; }

        public long SearchAdministrativeUnitTypeID { get; set; }
        public string DefaultOutbreakStatus { get; set; }
    }
}
