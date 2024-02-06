using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.RequestModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ResponseModels.Human;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetHumanActiveSurveillanceCampaignListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceCampaignController; }
        public Type APIReturnType { get => typeof(List<HumanActiveSurveillanceCampaignViewModel>); }
        public string MethodParameters { get => "HumanActiveSurveillanceCampaignRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_CAMPAIGN_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
    public class GetHumanActiveCampaignSampleToSampleTypeListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceCampaignController; }
        public Type APIReturnType { get => typeof(List<GetHumanActiveCampaignSampleToSampleTypeResponseModel>); }
        public string MethodParameters { get => "GetHumanActiveCampaignSampleToSampleTypeRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_CAMPAIGN_TO_SAMPLE_TYPE_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
    public class GetHumanActiveSurveillanceCampaignDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceCampaignController; }
        public Type APIReturnType { get => typeof(List<GetHumanActiveSurveillanceCampaignDetailsResponseModel>); }
        public string MethodParameters { get => "HumanActiveSurveillanceCampaignDetailsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_CAMPAIGN_GETDetailResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
    public class SetHumanActiveSurveillanceCampaignAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceCampaignController; }
        public Type APIReturnType { get => typeof(List<SetHumanActiveSurveillanceCampaignResponseModel>); }
        public string MethodParameters { get => "SetHumanActiveSurveillanceCampaignRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_CAMPAIGN_SETResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DeleteActiveSurveillanceCampaignAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanActiveSurveillanceCampaignController; }
        public Type APIReturnType { get => typeof(List<DeleteHumanActiveSurveillanceCampaignDetailsResponseModel>); }
        public string MethodParameters { get => "DeleteHumanActiveSurveillanceCampaignRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_HAS_CAMPAIGN_DELResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
}
