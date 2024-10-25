using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.ResponseModels.CrossCutting;

namespace EIDSS.Api.CodeGeneration.CrossCutting
{
    public class ActiveSurveillanceCampaignDirectives
    {
      

        public class GetActiveSurveillanceCampaignGetDetailAsync : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.CrossCuttingController; }
            public Type APIReturnType { get => typeof(List<ActiveSurveillanceCampaignDetailViewModel>); }
            public string MethodParameters { get => "ActiveSurveillanceCampaignDetailRequestModel request, CancellationToken cancellationToken = default"; }
            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
            public Type RepositoryReturnType { get => typeof(List<USP_AS_CAMPAIGN_GETDetailResult>); }
            public string APIGroupName => "Human and Veterinary  active surveillance campaign";
            public string SummaryInfo => "Returns Human/veterinary active surveillance campaign detail record";

        }

        public class GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.CrossCuttingController; }
            public Type APIReturnType { get => typeof(List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>); }
            public string MethodParameters { get => "ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel request, CancellationToken cancellationToken = default"; }
            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
            public Type RepositoryReturnType { get => typeof(List<USP_AS_CAMPAIGN_TO_DIAGNOSIS_SPECIES_SAMPLE_TYPE_GETListResult>); }
            public string APIGroupName => "Human and Veterinary active surveillance campaign";
            public string SummaryInfo => "Returns Human/veterinary active surveillance campaign disease, species, samples List";

        }

        public class SaveActiveSurveillanceCampaignAsync : ICodeGenDirective
        {
            public string APIClassName => TargetedClassNames.CrossCuttingController;
            public Type APIReturnType => typeof(ActiveSurveillanceCampaignSaveResponseModel);
            public string MethodParameters => "ActiveSurveillanceCampaignSaveRequestModel request, CancellationToken cancellationToken = default";
            public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;
            public Type RepositoryReturnType => typeof(USP_AS_CAMPAIGN_SETResult);
            public string APIGroupName => "Save Human/Veterinary active surveillance campaign";
            public string SummaryInfo => "";
        }

        public class DeleteActiveSurveillanceCampaign : ICodeGenDirective
        {
            public string APIClassName => TargetedClassNames.CrossCuttingController;
            public Type APIReturnType => typeof(APIPostResponseModel);
            public string MethodParameters => "string LanguageID, long CampaignID, string UserName, CancellationToken cancellationToken = default";
            public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.DELETE;
            public Type RepositoryReturnType => typeof(USP_AS_CAMPAIGN_DELResult);
            public string APIGroupName => "Delete Human/Veterinary active surveillance campaign";
            public string SummaryInfo => "";
        }

        public class DisassociateSessionFromCampaignAsync : ICodeGenDirective
        {
            public string APIClassName => TargetedClassNames.CrossCuttingController;
            public Type APIReturnType => typeof(APIPostResponseModel);
            public string MethodParameters => "DisassociateSessionFromCampaignSaveRequestModel request, CancellationToken cancellationToken = default";
            public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;
            public Type RepositoryReturnType => typeof(USP_AS_DISASSOCITESESSION_FROM_CAMPAIGN_SETResult);
            public string APIGroupName => "Save Human/Veterinary active surveillance campaign";
            public string SummaryInfo => "";
        }

    }
}
