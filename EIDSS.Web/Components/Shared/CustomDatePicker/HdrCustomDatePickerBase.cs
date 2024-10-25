using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Extensions;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using static EIDSS.Localization.Constants.FieldLabelResourceKeyConstants;
using static EIDSS.Localization.Constants.MessageResourceKeyConstants;
using static EIDSS.Web.Components.Shared.CustomDatePicker.HdrCustomDatePickerComparator;
using static EIDSS.Web.Components.Shared.CustomDatePicker.HdrCustomDatePickerFieldTypes;

namespace EIDSS.Web.Components.Shared.CustomDatePicker;

public class CustomDatePickerBase : ComponentBase
{
    [Parameter] public DateTime? Max { get; set; }
    [Parameter, EditorRequired] public string Name { get; set; }
    [Parameter] public string Id { get; set; } = "";
    [Parameter] public bool Disabled { get; set; }
    [Parameter] public DateTime? Value { get; set; }
    [Parameter] public bool NoValidate { get; set; }
    [Parameter] public EventCallback<DateTime?> ValueChanged { get; set; }
    [Parameter] public EventCallback<DateTime?> Change { get; set; }
    [Parameter, EditorRequired] public HdrCustomDatePickerFieldTypes? FieldType { get; set; }
    [Inject] private IHdrStateContainer HdrStateContainer { get; set; }
    
    [Inject] protected IStringLocalizer Localizer { get; set; }
    protected string WarningMassage { get; set; }
    
    protected override void OnParametersSet()
    {
        base.OnParametersSet();

        if (FieldType == null)
        {
            throw new Exception($"{nameof(FieldType)} is required field for {nameof(HdrCustomDatePicker)}");
        }
        
        if (string.IsNullOrEmpty(Name))
        {
            throw new Exception($"{nameof(Name)} is required field for {nameof(HdrCustomDatePicker)}");
        }
        
        if (!FieldsDefinitions.ContainsKey(FieldType.Value))
        {
            throw new Exception($"Missing field definition for {nameof(FieldType)}: {FieldType.Value}");
        }
    }

    private static readonly Dictionary<HdrCustomDatePickerFieldTypes, FieldDefinition> FieldsDefinitions = new()
    {
        { DateOfEntered, new FieldDefinition(state => state.DateEntered, HumanDiseaseReportSummaryDateEnteredFieldLabel) },
        { DateOfBirth, new FieldDefinition(state => state.DateOfBirth, PersonInformationDateOfBirthFieldLabel) },
        { DateOfDeath, new FieldDefinition(state => state.DateOfDeath, HumanDiseaseReportFinalOutcomeDateOfDeathFieldLabel) },
        { DateOfNotification, new FieldDefinition(state => state.DateOfNotification, HumanDiseaseReportNotificationDateOfNotificationFieldLabel) },
        { DateOfDiagnosis, new FieldDefinition(state => state.DateOfDiagnosis, HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel) },
        { DateOfDischarge, new FieldDefinition(state => state.DateOfDischarge, HumanDiseaseReportFacilityDetailsDateOfDischargeFieldLabel) },
        { DateOfHospitalization, new FieldDefinition(state => state.DateOfHospitalization, HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel) },
        { DateOfSymptomsOnset, new FieldDefinition(state => state.DateOfSymptomsOnset, HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel) },
        { DateOfCompletion, new FieldDefinition(state => state.DateOfCompletion, HumanDiseaseReportNotificationDateOfCompletionOfPaperFormFieldLabel) },
        { DateOfSoughtCareFirst, new FieldDefinition(state => state.DateOfSoughtCareFirst, HumanDiseaseReportFacilityDetailsDatePatientFirstSoughtCareFieldLabel) },
        { DateOfChangedDiagnosis, new FieldDefinition(state => state.DateOfChangedDiagnosis, HumanDiseaseReportNotificationDateOfChangedDiagnosisFieldLabel) },
        { DateOfStartInvestigation, new FieldDefinition(state => state.DateOfStartInvestigation, HumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel) },
        { DateOfFinalCaseClassification, new FieldDefinition(state => state.DateOfFinalCaseClassification, HumanDiseaseReportFinalOutcomeDateOfFinalCaseClassificationFieldLabel) },
        { DateOfExposure, new FieldDefinition(state => state.DateOfExposure, HumanDiseaseReportCaseInvestigationDateOfPotentialExposureFieldLabel) },
        { DateOfSampleCollection, new FieldDefinition(state => state.DateOfCurrentSampleCollection, HumanDiseaseReportCollectionDateFieldLabel) },
        { DateOfSampleSent, new FieldDefinition(state => state.DateOfCurrentSampleSent, HumanDiseaseReportSentDateFieldLabel) },
        { DateOfLastContact, new FieldDefinition(_ => null, ContactInformationModalDateOfLastContactFieldLabel) },
        { MinimumValueOfLastContactDateFromContacts, new FieldDefinition(state => state.MinimumValueOfLastContactDateFromContacts, ContactInformationModalDateOfLastContactFieldLabel) },
        { MinimumValueOfSampleCollectionDateFromSamples, new FieldDefinition(state => state.MinimumValueOfSampleCollectionDateFromSamples, HumanDiseaseReportCollectionDateFieldLabel) },
        { MinimumValueOfSampleSentDateFromSamples, new FieldDefinition(state => state.MinimumValueOfSampleSentDateFromSamples, HumanDiseaseReportSentDateFieldLabel) },
    };
    
    private static readonly List<CustomDatePickerValidationRule> ValidationRules =
    [
        new (DateOfBirth, LessOrEqual, DateOfEntered),
        new (DateOfBirth, LessOrEqual, DateOfCompletion),
        new (DateOfBirth, LessOrEqual, DateOfChangedDiagnosis),
        new (DateOfBirth, LessOrEqual, DateOfExposure),
        new (DateOfBirth, LessOrEqual, DateOfHospitalization),
        new (DateOfBirth, LessOrEqual, DateOfDischarge),
        new (DateOfBirth, LessOrEqual, DateOfSoughtCareFirst),
        new (DateOfBirth, LessOrEqual, DateOfSymptomsOnset),
        new (DateOfBirth, LessOrEqual, DateOfDiagnosis),
        new (DateOfBirth, LessOrEqual, DateOfNotification),
        new (DateOfBirth, LessOrEqual, DateOfFinalCaseClassification),
        new (DateOfBirth, LessOrEqual, DateOfDeath),
        new (DateOfBirth, LessOrEqual, DateOfStartInvestigation),
        new (DateOfBirth, LessOrEqual, MinimumValueOfLastContactDateFromContacts),
        new (DateOfBirth, LessOrEqual, MinimumValueOfSampleSentDateFromSamples),
        new (DateOfBirth, LessOrEqual, MinimumValueOfSampleCollectionDateFromSamples),
        new (DateOfCompletion, GraterOrEqual, DateOfBirth),
        new (DateOfChangedDiagnosis, GraterOrEqual, DateOfBirth),
        new (DateOfChangedDiagnosis, GraterOrEqual, DateOfDiagnosis),
        new (DateOfChangedDiagnosis, GraterOrEqual, DateOfSymptomsOnset),
        new (DateOfChangedDiagnosis, LessOrEqual, DateOfFinalCaseClassification),
        new (DateOfExposure, GraterOrEqual, DateOfBirth),
        new (DateOfExposure, LessOrEqual, DateOfSymptomsOnset),
        new (DateOfDischarge, GraterOrEqual, DateOfHospitalization),
        new (DateOfHospitalization, GraterOrEqual, DateOfBirth),
        new (DateOfHospitalization, GraterOrEqual, DateOfSymptomsOnset),
        new (DateOfHospitalization, LessOrEqual, DateOfDischarge),
        new (DateOfSoughtCareFirst, GraterOrEqual, DateOfBirth),
        new (DateOfSymptomsOnset, GraterOrEqual, DateOfBirth),
        new (DateOfSymptomsOnset, LessOrEqual, DateOfEntered),
        new (DateOfSymptomsOnset, LessOrEqual, DateOfChangedDiagnosis),
        new (DateOfSymptomsOnset, LessOrEqual, DateOfDiagnosis),
        new (DateOfSymptomsOnset, LessOrEqual, DateOfNotification),
        new (DateOfSymptomsOnset, LessOrEqual, DateOfFinalCaseClassification),
        new (DateOfSymptomsOnset, LessOrEqual, DateOfHospitalization),
        new (DateOfSymptomsOnset, GraterOrEqual, DateOfExposure),
        new (DateOfDiagnosis, GraterOrEqual, DateOfBirth),
        new (DateOfDiagnosis, LessOrEqual, DateOfEntered),
        new (DateOfDiagnosis, GraterOrEqual, DateOfSymptomsOnset),
        new (DateOfDiagnosis, LessOrEqual, DateOfChangedDiagnosis),
        new (DateOfDiagnosis, LessOrEqual, DateOfNotification),
        new (DateOfDiagnosis, LessOrEqual, DateOfFinalCaseClassification),
        new (DateOfNotification, LessOrEqual, DateOfEntered),
        new (DateOfNotification, LessOrEqual, DateOfStartInvestigation),
        new (DateOfNotification, GraterOrEqual, DateOfBirth),
        new (DateOfNotification, GraterOrEqual, DateOfChangedDiagnosis),
        new (DateOfNotification, GraterOrEqual, DateOfDiagnosis),
        new (DateOfNotification, GraterOrEqual, DateOfSymptomsOnset),
        new (DateOfFinalCaseClassification, GraterOrEqual, DateOfBirth),
        new (DateOfFinalCaseClassification, GraterOrEqual, DateOfNotification),
        new (DateOfFinalCaseClassification, GraterOrEqual, DateOfDiagnosis),
        new (DateOfFinalCaseClassification, GraterOrEqual, DateOfSymptomsOnset),
        new (DateOfFinalCaseClassification, GraterOrEqual, DateOfChangedDiagnosis),
        new (DateOfDeath, GraterOrEqual, DateOfBirth),
        new (DateOfStartInvestigation, GraterOrEqual, DateOfBirth),
        new (DateOfStartInvestigation, GraterOrEqual, DateOfNotification),
        new (DateOfSampleSent, GraterOrEqual, DateOfSampleCollection),
        new (DateOfSampleSent, GraterOrEqual, DateOfBirth),
        new (DateOfSampleCollection, LessOrEqual, DateOfSampleSent),
        new (DateOfSampleCollection, GraterOrEqual, DateOfBirth),
        new (DateOfLastContact, GraterOrEqual, DateOfBirth),
    ];

    protected async Task OnChange(DateTime? value)
    {
        if (value == null)
        {
            WarningMassage = "";
            await ValueChanged.InvokeAsync(null);
            await Change.InvokeAsync(null);
            return;
        }

        var warningMessage = ValidateValue(value.Value);

        if (!string.IsNullOrWhiteSpace(warningMessage))
        {
            WarningMassage = warningMessage;
            await ValueChanged.InvokeAsync(null);
            await Change.InvokeAsync(null);
        }
        else
        {
            WarningMassage = "";
            await ValueChanged.InvokeAsync(value);
            await Change.InvokeAsync(value);
        }
    }

    private string ValidateValue(DateTime value)
    {
        if (NoValidate)
        {
            return null;
        }

        var validationRules = ValidationRules.Where(x => x.Field == FieldType);
        foreach (var rule in validationRules)
        {
            var valueForCompare = FieldsDefinitions[rule.ComparedField].ValueSelector(HdrStateContainer);
            if (rule.Comparator == GraterOrEqual && value.IsEarlierThan(valueForCompare))
            {
                return GenerateLaterThanMessage(FieldsDefinitions[FieldType!.Value].LabelId, value,
                    FieldsDefinitions[rule.ComparedField].LabelId, valueForCompare!.Value);
            }
            
            if (rule.Comparator == LessOrEqual && value.IsLaterThan(valueForCompare))
            {
                return GenerateEarlierThanMessage(FieldsDefinitions[FieldType!.Value].LabelId, value,
                    FieldsDefinitions[rule.ComparedField].LabelId, valueForCompare!.Value);
            }
        }

        return null;
    }

    private string GenerateEarlierThanMessage(string firstLabelId, DateTime firstDate, string secondLabelId, DateTime secondDate)
    {
        var compareTemplate = Localizer.GetString(GlobalMustBeLessThanOrEqualToMessage).Value;
        return GenerateMessage(firstLabelId, firstDate, secondLabelId, secondDate, compareTemplate);
    }
    
    private string GenerateLaterThanMessage(string firstLabelId, DateTime firstDate, string secondLabelId, DateTime secondDate)
    {
        var compareTemplate = Localizer.GetString(GlobalMustBeGreaterThanOrEqualToMessage).Value;
        return GenerateMessage(firstLabelId, firstDate, secondLabelId, secondDate, compareTemplate);
    }
    
    private string GenerateMessage(string firstLabelId, DateTime firstDate, string secondLabelId, DateTime secondValue, string compareTemplate)
    {
        var firstFieldNameWithDate = $"{Localizer.GetString(firstLabelId)} ({firstDate:d})";
        var secondFieldNameWithDate = $"{Localizer.GetString(secondLabelId)} ({secondValue:d})";
        return string.Format(compareTemplate, firstFieldNameWithDate, secondFieldNameWithDate);
    }
}