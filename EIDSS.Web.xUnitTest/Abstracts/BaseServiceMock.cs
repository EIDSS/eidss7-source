using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Abstracts
{
    public abstract class BaseServiceMock<T> where T : class
    {
        private Mock<T> _service;
        public  Mock<T> Service 
        { 
            get => _service;
            protected set => _service = value;
        }

        public BaseServiceMock()
        {
            _service = new Mock<T>();
        }
    }
}
