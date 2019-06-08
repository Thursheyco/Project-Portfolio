// Thursheyco Arreguin
// 06-06-19
// DVP3 1906
// Code Exercise 01 - Event Handler
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ArreguinThursheyco_CE01
{
    public partial class UserInput : Form
    {
        // EventHandler delegate
        public EventHandler AddToDone;

        // Property for UserInput form to get & set the controls on its form
        public Item Data
        {
            get
            {
                Item i = new Item();
                i.Title = txtTitle.Text;
                i.Movie = rdoMovie.Checked;
                i.Book = rdoBook.Checked;
                i.Done = chkDone.Checked;
                return i;
            }
            set
            {
                txtTitle.Text = value.Title;
                rdoMovie.Checked = value.Movie;
                rdoBook.Checked = value.Book;
                chkDone.Checked = value.Done;
            }
        }

        public UserInput()
        {
            InitializeComponent();
        }

        private void btnEnter_Click(object sender, EventArgs e)
        {
            // Raise the event of the user entering info to pass to MainForm
            if(AddToDone != null)
            {
                AddToDone(this, new EventArgs());
            }

            // Close USerInput form
            Close();
        }
    }
}
