// Thursheyco Arreguin
// 07-08-19
// DVP3 1907
// Code Exercise 01 - Event Handler

namespace ArreguinThursheyco_CE01
{
    // will hold data entered by the user on the UserInput form
    public class Course
    {
        public string Title { get; set; }
        public bool Done { get; set; }

        // override ToString method to only return Title of Item
        public override string ToString()
        {
            return Title;
        }
    }
}
