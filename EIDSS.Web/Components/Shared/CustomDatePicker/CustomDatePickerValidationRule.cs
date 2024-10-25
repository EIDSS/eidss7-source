namespace EIDSS.Web.Components.Shared.CustomDatePicker;

internal record CustomDatePickerValidationRule(
    HdrCustomDatePickerFieldTypes Field,
    HdrCustomDatePickerComparator Comparator,
    HdrCustomDatePickerFieldTypes ComparedField
);