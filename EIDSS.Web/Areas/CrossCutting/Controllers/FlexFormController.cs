using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [Area("CrossCutting")]
    [Controller]
    public class FlexFormController : BaseController
    {
        private readonly IFlexFormClient _flexFormClient;

        public FlexFormController(IFlexFormClient flexFormClient, ILogger<FlexFormController> logger) : base(logger)
        {
            _flexFormClient = flexFormClient;
        }

        [HttpPost]
        public Task<JsonResult> SaveAnswers(string inputAnswers, string selectAnswers, long idfsFormTemplate, long idfObservation, string strUser = "")
        {
            var request = new FlexFormActivityParametersSaveRequestModel();

            FlexFormObservationAnswers answer;

            var lAnswers = new List<FlexFormObservationAnswers>();

            if (inputAnswers != ".")
            {
                var strInputAnswers = inputAnswers.Split('‼');

                foreach (var t in strInputAnswers)
                {
                    var aAnswer = t.Split('☼');

                    answer = new FlexFormObservationAnswers
                    {
                        idfsParameter = long.Parse(aAnswer[0]),
                        idfsEditor = long.Parse(aAnswer[1]),
                        answer = aAnswer[2] == "null" ? null : aAnswer[2],
                        idfRow = long.Parse(aAnswer[3])
                    };

                    lAnswers.Add(answer);
                }
            }

            if (selectAnswers != ".")
            {
                var strSelectAnswers = selectAnswers.Split('‼');

                foreach (var t in strSelectAnswers)
                {
                    var aAnswer = t.Split('☼');

                    answer = new FlexFormObservationAnswers
                    {
                        idfsParameter = long.Parse(aAnswer[0]),
                        idfsEditor = long.Parse(aAnswer[1]),
                        answer = aAnswer[2] == "null" ? null : aAnswer[2],
                        idfRow = long.Parse(aAnswer[3])
                    };

                    lAnswers.Add(answer);
                }
            }

            request.Answers = JsonConvert.SerializeObject(lAnswers);
            request.idfsFormTemplate = idfsFormTemplate;
            request.idfObservation = idfObservation == 0 ? null : idfObservation;
            request.User = strUser;

            var response = _flexFormClient.SaveAnswers(request).Result;

            return Task.FromResult(Json(response.idfObservation));
        }
    }
}
