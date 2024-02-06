using AutoFixture;
using AutoFixture.AutoMoq;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using EIDSS.Repository.ReturnModels;
using Moq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Api.xUnitTest.Arrangements
{
    public class EIDSSContextProceduresMock : EIDSSContextProcedures
    {
        private Mock<EIDSSContext> _context;

        public EIDSSContextProceduresMock(Mock<EIDSSContext> context) : base(context.Object)
        {
            _context = context;
        }
    }
}
