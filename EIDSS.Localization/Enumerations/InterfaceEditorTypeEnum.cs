namespace EIDSS.Localization.Enumerations
{
    public enum InterfaceEditorTypeEnum : long
    {
        /// <summary>
        /// Resources that apply to a button's display text.
        /// </summary>
        ButtonText = 10540000,
        /// <summary>
        /// Resources that apply to an HTML element's tool tip; such as a button's title tag.
        /// </summary>
        ToolTip = 10540001,
        /// <summary>
        /// Resources that apply to a table column header.
        /// </summary>
        ColumnHeading = 10540002,
        /// <summary>
        /// Resources that apply to a property's display text; typically for a label tag.
        /// </summary>
        FieldLabel = 10540003,
        /// <summary>
        /// Resources that apply to a page title and page or section heading; typically for an h1, h2, etc. tag.
        /// </summary>
        Heading = 10540004,
        /// <summary>
        /// Resources that indicate if an HTML element is shown or not.  OBSOLETE
        /// </summary>
        //Hidden = 10540005,
        /// <summary>
        /// Resources that apply to an error, informational or warning message/notification text.
        /// </summary>
        Message = 10540006,
        /// <summary>
        /// Resources that indicate if a field is required or not.  Used in association with the 
        /// required if data annotation.  OBSOLETE
        /// </summary>
        //Required = 10540007
    }
}