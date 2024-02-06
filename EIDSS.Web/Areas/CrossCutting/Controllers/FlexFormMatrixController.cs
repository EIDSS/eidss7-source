using Microsoft.AspNetCore.Mvc;
using EIDSS.Web.Abstracts;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [Area("CrossCutting")]
    [Controller]
    public class FlexFormMatrixController : BaseController
    {
        IFlexFormClient _flexFormClient;

        public FlexFormMatrixController(IFlexFormClient flexFormClient, ILogger<FlexFormMatrixController> logger) : base(logger)
        {
            _flexFormClient = flexFormClient;
        }

        [HttpPost()]
        public async Task<JsonResult> SaveAnswers(string inputAnswers, string selectAnswers, long idfsFormTemplate, long idfObservation)
        {
            FlexFormActivityParametersSaveRequestModel request = new FlexFormActivityParametersSaveRequestModel();
            List<FlexFormObservationAnswers> answers = new List<FlexFormObservationAnswers>();

            FlexFormObservationAnswers answer = new FlexFormObservationAnswers();

            List<FlexFormObservationAnswers>  lAnswers = new List<FlexFormObservationAnswers>();

            if (!(inputAnswers == "."))
            {
                string[] strInputAnswers = inputAnswers.Split('‼');

                for (int i = 0; i < strInputAnswers.Length; i++)
                {
                    string[] aAnswer = strInputAnswers[i].ToString().Split('☼');

                    answer = new FlexFormObservationAnswers();
                    answer.idfsParameter = long.Parse(aAnswer[0].ToString());
                    answer.answer = aAnswer[1].ToString();
                    answer.idfRow = long.Parse(aAnswer[2].ToString());

                    lAnswers.Add(answer);
                }
            }

            if (!(selectAnswers == "."))
            {
                string[] strSelectAnswers = selectAnswers.Split('‼');

                for (int i = 0; i < strSelectAnswers.Length; i++)
                {
                    string[] aAnswer = strSelectAnswers[i].ToString().Split('☼');

                    answer = new FlexFormObservationAnswers();
                    answer.idfsParameter = long.Parse(aAnswer[0].ToString());
                    answer.answer = aAnswer[1].ToString();
                    answer.idfRow = long.Parse(aAnswer[2].ToString());

                    lAnswers.Add(answer);
                }
            }

            request.Answers = JsonConvert.SerializeObject(lAnswers);
            request.idfsFormTemplate = idfsFormTemplate;
            request.idfObservation = idfObservation == 0 ? null : idfObservation;

            FlexFormActivityParametersResponseModel response = _flexFormClient.SaveAnswers(request).Result;

            return Json(response.idfObservation);
        }
    }
}
