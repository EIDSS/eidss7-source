using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class GetInterfaceEditorModuleList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.InterfaceEditorController; }

        public string APIGroupName => "Administration - Other Editors";

        public Type APIReturnType { get => typeof(List<InterfaceEditorModuleSectionViewModel>); }

        public string MethodParameters { get => " InterfaceEditorModuleGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_IE_Module_GETListResult>); }
        public string SummaryInfo => "Gets a list of the modules for the interface editor.";
    }

    public class GetInterfaceEditorSectionList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.InterfaceEditorController; }

        public string APIGroupName => "Administration - Other Editors";

        public Type APIReturnType { get => typeof(List<InterfaceEditorModuleSectionViewModel>); }

        public string MethodParameters { get => " InterfaceEditorSectionGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_IE_Section_GETListResult>); }
        public string SummaryInfo => "Gets a list of the sections for a particular module for the interface editor.";
    }

    public class GetInterfaceEditorResourceList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.InterfaceEditorController; }

        public string APIGroupName => "Administration - Other Editors";

        public Type APIReturnType { get => typeof(List<InterfaceEditorResourceViewModel>); }

        public string MethodParameters { get => " InterfaceEditorResourceGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_IE_Resource_GETListResult>); }
        public string SummaryInfo => "Gets a list of the resources for a particular section for the interface editor.";
    }

    public class SaveInterfaceEditorResource : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.InterfaceEditorController; }
        public string APIGroupName => "Administration - Other Editors";
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "InterfaceEditorResourceSaveRequestModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_IE_Resource_SETResult); }
        public string SummaryInfo => "Save Interface Editor Resource";
    }

    public class SaveInterfaceEditorLanguage : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.InterfaceEditorController; }
        public string APIGroupName => "Administration - Other Editors";
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "InterfaceEditorLanguageSaveRequestModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_IE_Language_SETResult); }
        public string SummaryInfo => "Prepares the system to accept a new language file before uploading the file.";
    }

    public class GetInterfaceEditorTemplateItems : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.InterfaceEditorController; }
        public string APIGroupName => "Administration - Other Editors";
        public Type APIReturnType { get => typeof(List<InterfaceEditorTemplateViewModel>); }
        public string MethodParameters { get => "string langId, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_IE_DownloadTemplate_GETListResult>); }
        public string SummaryInfo => "Get the Interface Editor Resources for creating a translation template.";
    }
}