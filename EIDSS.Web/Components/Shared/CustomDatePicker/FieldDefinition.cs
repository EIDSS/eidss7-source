using System;
using EIDSS.Web.Services;

namespace EIDSS.Web.Components.Shared.CustomDatePicker;

internal record FieldDefinition(
    Func<IHdrStateContainer, DateTime?> ValueSelector,
    string LabelId
);