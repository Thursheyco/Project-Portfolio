// Thursheyco Arreguin
// 07-08-19
// DVP3 1907
// Code Exercise 01 - Event Handlers
using System;
using System.Windows.Forms;

namespace ArreguinThursheyco_CE01
{
    public partial class MainForm : Form
    {
        // EventHandler delegate to call the EventHandler method on MainForm
        public EventHandler<ModifyObjectEventArgs> ModifyObject;

        // declare an internal class to help me modify a selected item from the listBoxUnseenUnread
        public class ModifyObjectEventArgs : EventArgs
        {
            // Instance / Member variables used to buld a new object with the selected item in the ListBox
            Item ObjectToModify;

            // Properties to allow access to the Item that I want to modify
            public Item ObjectToModify1
            {
                get
                {
                    return ObjectToModify;
                }
                set
                {
                    ObjectToModify = value;
                }
            }

            // Constructor that will take in parameters to modify
            public ModifyObjectEventArgs(Item i)
            {
                ObjectToModify = i;
            }
        }

        // public property to access selected item in listBoxUnseenUnread
        public Item SelectedObject
        {
            get
            {
                // check if anyhting is selected within listBoxUnseenUnread
                if(listBoxClassesToTake.SelectedItem != null)
                {
                    return listBoxClassesToTake.SelectedItem as Item;
                }
                return new Item();
            }
        }

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

        // event handler method to handle adding a new Item to either ListBox
        public void AddToListBox1(object sender, EventArgs e)
        {
            // cast the sender as a UserInput form to extract its data
            UserInput ui = sender as UserInput;

            // cast again to help with process
            Item i = ui.Data;

            // check if the item has been seen or read to determine which ListBox to add it to
            if(i.Done == true)
            {
                listBoxClassesCompleted.Items.Add(i);
            }
            else
            {
                listBoxClassesToTake.Items.Add(i);
            }
        }

        private void btnMoveRight_Click(object sender, EventArgs e)
        {
            // check if the user has selected an item from listBoxUnseenUnread
            if(listBoxClassesToTake.SelectedIndex == -1)
            {
                // alert the user they must select an item from the 1st ListBox to move to the 2nd
                MessageBox.Show("Please select an item from Movies To-Watch / Books To-Read first.");
            }
            else
            {
                // move selected item from listBoxUnseenUnread to listBoxReadSeen
                listBoxClassesCompleted.Items.Add(listBoxClassesToTake.SelectedItem);

                // set checkBox for Done to true for the item moved
                Item i = listBoxClassesToTake.SelectedItem as Item;
                i.Done = true;

                // remove selected item from listBoxUnreadUnseen
                listBoxClassesToTake.Items.Remove(listBoxClassesToTake.SelectedItem);
            }
        }

        private void btnMoveLeft_Click(object sender, EventArgs e)
        {
            // check if the user has selected an item from listBoxSeenRead
            if(listBoxClassesCompleted.SelectedIndex == -1)
            {
                // alert the user they must select an item from the 2nd ListBox to move to the 1st
                MessageBox.Show("Please select an item from Movies Seen / Books Read first.");
            }
            else
            {
                // move selected item from listBoxSeenRead to listBoxUnseenUnread
                listBoxClassesToTake.Items.Add(listBoxClassesCompleted.SelectedItem);

                // set checkBox for Done to false
                Item i = listBoxClassesCompleted.SelectedItem as Item;
                i.Done = false;

                // remove selected item from listBoxReadSeen
                listBoxClassesCompleted.Items.Remove(listBoxClassesCompleted.SelectedItem);
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            // check to see if the user made a selection from listBoxUnreadUnseen
            if (listBoxClassesToTake.SelectedItem != null)
            {
                // delete selected item
                listBoxClassesToTake.Items.Remove(listBoxClassesToTake.SelectedItem);
            }
            else if(listBoxClassesCompleted.SelectedItem != null)
            {
                // delete selected item from listBoxReadSeen
                listBoxClassesCompleted.Items.Remove(listBoxClassesCompleted.SelectedItem);
            }
            else
            {
                // alert user to select an item first
                MessageBox.Show("Please select an item from Movies Seen / Books Read first,\nor from Movies To-Watch / Books To-Read.");
            }
        }

        private void listBoxUnreadUnseen_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            // Instantiate a new UserInput form 
            UserInput ui = new UserInput();

            // Subscribe to the event of editing an item when the user double clicks
            ModifyObject += ui.UserInput_ModifyItem;

            // raise the event to send back data to change selected items data in ListBox
            if (ModifyObject != null)
            {
                ModifyObject(this, new ModifyObjectEventArgs(SelectedObject));
            }

            // show UserInput form with populates fields to change
            ui.Show();
        }
    }
}
