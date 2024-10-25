using EIDSS.Api.ActionFilters;
using EIDSS.CodeGenerator;
using EIDSS.Api.Abstracts;
using EIDSS.Api.Provider;
using EIDSS.Api.Providers;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.Repositories;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Serilog;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Threading;
using System.Threading.Tasks;
using Swashbuckle.AspNetCore.Annotations;
using EIDSS.Api.CodeGeneration.Control;

namespace EIDSS.Api.CodeGeneration.Administration
{
    //public class GetSiteAlertsSubscriptionList : ICodeGenDirective
    //{
    //    public string APIClassName { get => TargetedClassNames.SiteAlertsSubscriptionController; }

    //    public string APIGroupName => "Administration - Site Alert Subscription";

    //    public Type APIReturnType { get => typeof(EventSubscriptionTypeModel[]); }

    //    public string MethodParameters { get => "EventSubscriptionGetRequestModel request, CancellationToken cancellationToken = default"; }

    //    public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

    //    public Type RepositoryReturnType { get => typeof(USP_CONF_GetEventSubcriptionTypes_GETResult[]); }
    //    public string SummaryInfo => "";
    //}
}
