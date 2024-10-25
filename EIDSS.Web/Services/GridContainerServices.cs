using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Abstracts;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using EIDSS.Web.ViewModels;
namespace EIDSS.Web.Services
{
    public class GridContainerServices : BaseServiceContainer
    {
        private EIDSSGridColumnChooserDefinition eidssgridcolumnchooserdefinition;

        private RowReOrderClass rowReOrderClass;
        public EIDSSGridColumnChooserDefinition GridColumnConfig
        { get => eidssgridcolumnchooserdefinition; set { eidssgridcolumnchooserdefinition = value; NotifyStateChanged("GridColumnConfig"); } }

        private List<string> visibleColumnList;
        public List<string> VisibleColumnList
        {
            get { return visibleColumnList; }
            set { visibleColumnList = value; }
        }
        public int ColumnCounter { get; set; }
        public GridContainerServices() : base() {

            eidssgridcolumnchooserdefinition = new EIDSSGridColumnChooserDefinition();
            eidssgridcolumnchooserdefinition.RowOrderDefinitionList = new List<RowReOrderClass>();
            visibleColumnList = new List<string>();
        }
        public event Action<string> OnChange;

        public void SaveColumnOrder() { 
        
        
        }
     
        public void LoadColumnOrder()
        {

        }
        private void NotifyStateChanged(string property) => OnChange?.Invoke(property);
  
    }
}
   



