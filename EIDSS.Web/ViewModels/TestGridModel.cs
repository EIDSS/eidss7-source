using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{
    public class TestGridModel
    {

        public IQueryable<Customer> GetCustomers()
        {
            List<Customer> customerList = new List<Customer>();
            for (int i = 0; i <= 1000000; i++)
            {
                customerList.Add(new Customer {Id= Guid.NewGuid(), Name = "Customer_" + i.ToString(), Address = "Address_" + i.ToString(), City = "City_" + i.ToString(), Country = "Country_" + i.ToString() });
            }

            return customerList.AsQueryable();
        }
    }
    public class Customer
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public string ZipCode { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string ContactName { get; set; }
        public IEnumerable<Order> Orders { get; set; }
    }

    public class Order
    {
        public Guid Id { get; set; }
        public DateTime Date { get; set; }
        public Decimal OrderValue { get; set; }
        public bool Shipped { get; set; }
    }

  
}
