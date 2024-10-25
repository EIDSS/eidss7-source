using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Enumerations
{
    /// <summary>
    /// Specifies the location hierarchy level of the <see cref="AuditColumnEnum"/> specified as a parameter
    /// of the <see cref="DataEntryAuditAttribute"/>.  This means the property is a location type.
    /// When the auditing infrastructure encounters properties decorated with the DataEntryAuditAttribute and
    /// the LocatonTypeEnum is specified, all attributes associated with the property are enumerated.  The system will then make a call to
    /// the database to get the location hiearchy for that location and assign the correct location id for each attribute specified.
    /// </summary>
    public enum LocationTypeEnum
    {
        Level1,
        Level2,
        Level3,
        Level4,
        Level5,
        Level6,
        Level7
    }
}
