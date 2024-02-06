using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Enumerations
{
    public enum SecurityEventActionEnum:long
    {
        Logon=10110000,
        Logoff=	10110001,
        Processstart	=10110002,
        Processstop=	10110003,
        Protecteddataupdate=	10110004,
        Update	=10110005,
        DataArchiving	=10110006
    }

    public enum SecurityEventProcessTypeEnum : long
    {
        EIDSS=10130000,
        Notificationservice=	10130001,
        Replication=	10130002,
        EIDSSClientAgent=	10130003
    }


}
