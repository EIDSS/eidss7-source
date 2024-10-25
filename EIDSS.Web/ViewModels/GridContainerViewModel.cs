using System.Collections.Generic;

namespace EIDSS.Web.ViewModels
{
    public class GridContainerViewModel
    {
    }
    public class EIDSSGridColumnChooserDefinition
    {
        public int User { get; set; }
        public List<RowReOrderClass> RowOrderDefinitionList { get; set; }

    }
    public class RowReOrderClass
    {
        public string ColumnName { get; set; }
        public int Index { get; set; }
        public int? ReorderedIndex { get; set; }
        public bool IsVisible { get; set; } = true;
    }
}
