// Thursheyco Arreguin
// 07-08-19
// DVP3 1907
// Code Exercise 01 - Event Handler
using System;
using System.Windows.Forms;

namespace ArreguinThursheyco_CE01
{
    public partial class UserInput : Form
    {
        // Refernece to MainForm
        MainForm main = Application.OpenForms[0] as MainForm;

        // EventHandler delegate
        public EventHandler AddToDone;

        // Property for UserInput form to get & set the controls on its form
        public Item Data
        {
            get
            {
                Item i = new Item();
                i.Title = txtTitle.Text;
                i.Done = chkDone.Checked;
                return i;
            }
            set
            {
                txtTitle.Text = value.Title;
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

            // Close UserInput form
            Close();
        }

        // EventHandler Method to modify the item selected from the ListBox on MainForm
        public void UserInput_ModifyItem(object sender, MainForm.ModifyObjectEventArgs e)
        {
            // set fields for UserInput form from selected item
            Item i = e.ObjectToModify1 as Item;

            txtTitle.Text = i.Title;
            chkDone.Checked = i.Done;

            // show button to apply changes
            btnEdit.Show();
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            // raise the event to send back data to change selected items data in ListBox
            if (main.ModifyObject != null)
            {
                main.ModifyObject(this, new MainForm.ModifyObjectEventArgs(main.SelectedObject));
            }
        }
    }
}
