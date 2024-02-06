using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Abstracts
{
    public abstract class BaseClientMock<T> where T : class
    {
        private Mock<T> _client;

        public Mock<T> Client
        {
            get => _client;
            protected set => _client = value;
        }

        public BaseClientMock()
        {
            _client = new Mock<T>();
        }


    }
}
