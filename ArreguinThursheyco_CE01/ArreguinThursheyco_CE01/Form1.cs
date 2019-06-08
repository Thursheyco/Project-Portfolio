// Thursheyco Arreguin
// 06-06-19
// DVP3 1906
// Code Exercise 01 - Event Handlers
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
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // Exit the app
            Application.Exit();
        }

        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // instantiate the UserInput form
            UserInput ui = new UserInput();

            // subscribe to user entering info event
            ui.AddToDone += AddToListBox1;

            // show as modeless
            ui.Show();
        }

        // event handler method to handle adding a new Item to first ListBox
        public void AddToListBox1(object sender, EventArgs e)
        {
            // cast the sender as a UserInput form to extract its data
            UserInput ui = sender as UserInput;

            // cast again to help with process
            Item i = ui.Data;

            // check if the item has been seen or read to determine which ListBox to add it to
            if(i.Done == true)
            {
                listBoxReadSeen.Items.Add(i);
            }
            else
            {
                listBoxUnreadUnseen.Items.Add(i);
            }
        }

        private void btnMoveRight_Click(object sender, EventArgs e)
        {
            // check if the user has selected an item from listBoxUnseenUnread
            if(listBoxUnreadUnseen.SelectedIndex == -1)
            {
                // alert the user they must select an item from the 1st ListBox to move to the 2nd
                MessageBox.Show("Please select an item from Movies To-Watch / Books To-Read first.");
            }
            else
            {
                // move selected item from listBoxUnseenUnread to listBoxReadSeen
                listBoxReadSeen.Items.Add(listBoxUnreadUnseen.SelectedItem);

                // set checkBox for Done to true for the item moved
                Item i = listBoxUnreadUnseen.SelectedItem as Item;
                i.Done = true;

                // remove selected item from listBoxUnreadUnseen
                listBoxUnreadUnseen.Items.Remove(listBoxUnreadUnseen.SelectedItem);
            }
        }

        private void btnMoveLeft_Click(object sender, EventArgs e)
        {
            // check if the user has selected an item from listBoxSeenRead
            if(listBoxReadSeen.SelectedIndex == -1)
            {
                // alert the user they must select an item from the 2nd ListBox to move to the 1st
                MessageBox.Show("Please select an item from Movies Seen / Books Read first.");
            }
            else
            {
                // move selected item from listBoxSeenRead to listBoxUnseenUnread
                listBoxUnreadUnseen.Items.Add(listBoxReadSeen.SelectedItem);

                // set checkBox for Done to false
                Item i = listBoxReadSeen.SelectedItem as Item;
                i.Done = false;

                // remove selected item from listBoxReadSeen
                listBoxReadSeen.Items.Remove(listBoxReadSeen.SelectedItem);
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            // check to see if the user made a selection from listBoxUnreadUnseen
            if (listBoxUnreadUnseen.SelectedItem != null)
            {
                // delete selected item
                listBoxUnreadUnseen.Items.Remove(listBoxUnreadUnseen.SelectedItem);
            }
            else if(listBoxReadSeen.SelectedItem != null)
            {
                // delected selected item from listBoxReadSeen
                listBoxReadSeen.Items.Remove(listBoxReadSeen.SelectedItem);
            }
            else
            {
                // alert user to select an item first
                MessageBox.Show("Please select an item from Movies Seen / Books Read first,\nor from Movies To-Watch / Books To-Read.");
            }
        }
    }
}
