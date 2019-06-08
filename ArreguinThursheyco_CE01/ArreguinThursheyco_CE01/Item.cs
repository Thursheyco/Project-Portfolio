// Thursheyco Arreguin
// 06-06-19
// DVP3 1906
// Code Exercise 01 - Event Handler
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ArreguinThursheyco_CE01
{
    // will hold data entered by the user on the UserInput form
    public class Item
    {
        public string Title { get; set; }
        public bool Movie { get; set; }
        public bool Book { get; set; }
        public bool Done { get; set; }

        // override ToString method to only return Title of Item
        public override string ToString()
        {
            return Title;
        }
    }
}
