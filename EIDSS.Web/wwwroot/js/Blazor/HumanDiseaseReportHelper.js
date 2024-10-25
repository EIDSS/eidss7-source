class HumanDiseaseHelpers  {
    static dotNetHelper;

    static setDotNetHelper(value) {
        HumanDiseaseHelpers.dotNetHelper = value;
    }

    static setDiagnosisOrResultDate(diagnosisDate) {
        HumanDiseaseHelpers.dotNetHelper.invokeMethodAsync('SetDiagnosisOrResultDate', diagnosisDate);
    }
}
window.HumanDiseaseHelpers = HumanDiseaseHelpers;