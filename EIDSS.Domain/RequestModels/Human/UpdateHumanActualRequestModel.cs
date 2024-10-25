using System;

namespace EIDSS.Domain.RequestModels.Human
{
    public class UpdateHumanActualRequestModel
    {
        public long HumanActualId { get; set; }

        public DateTime? DateOfBirth { get; set; }

        public DateTime? DateOfDeath { get; set; }
    }
}
