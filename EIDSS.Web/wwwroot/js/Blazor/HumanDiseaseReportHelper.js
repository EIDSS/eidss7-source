//var GLOBAL = GLOBAL || {};
//GLOBAL.HumanDiseaseDotNetReference = null;
//GLOBAL.SetHumanDiseaseDotNetReference = function (pDotNetReference) {
//    GLOBAL.HumanDiseaseDotNetReference = pDotNetReference;
//};

//function setInvestigationOffice(InvestigatingOrg) {
//        //await stuffBaseInstance.invokeMethodAsync('SetInvestigationOffice', officeID);
   
//    GLOBAL.HumanDiseaseDotNetReference.invokeMethodAsync('SetInvestigationOffice', InvestigatingOrg);

//}

//function setDiagnosisOrResultDate(diagnosisDate) {
//    GLOBAL.HumanDiseaseDotNetReference.invokeMethodAsync('SetDiagnosisOrResultDate', diagnosisDate);
//}



class HumanDiseaseHelpers  {
    static dotNetHelper;

    static setDotNetHelper(value) {
        HumanDiseaseHelpers.dotNetHelper = value;
    }

    static  setInvestigationOffice(InvestigatingOrg) {
        HumanDiseaseHelpers.dotNetHelper.invokeMethodAsync('SetInvestigationOffice', InvestigatingOrg);
    }

    static setDiagnosisOrResultDate(diagnosisDate) {
        HumanDiseaseHelpers.dotNetHelper.invokeMethodAsync('SetDiagnosisOrResultDate', diagnosisDate);
    }
}
window.HumanDiseaseHelpers = HumanDiseaseHelpers;