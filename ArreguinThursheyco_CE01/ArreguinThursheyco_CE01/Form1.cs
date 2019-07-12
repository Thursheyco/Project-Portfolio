// Thursheyco Arreguin
// 07-08-19
// DVP3 1907
// Code Exercise 01 - Event Handlers
using System;
using System.Windows.Forms;
// Directive for using XML
using System.Xml;

namespace ArreguinThursheyco_CE01
{
    public partial class MainForm : Form
    {
        // EventHandler delegate to call the EventHandler method on MainForm
        public EventHandler<ModifyObjectEventArgs> ModifyObject;

        // declare an internal class to help me modify a selected Course from the listBoxClassesToTake
        public class ModifyObjectEventArgs : EventArgs
        {
            // Instance / Member variables used to buld a new object with the selected item in the ListBox
            Course ObjectToModify;

            // Properties to allow access to the Item that I want to modify
            public Course ObjectToModify1
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
            public ModifyObjectEventArgs(Course i)
            {
                ObjectToModify = i;
            }
        }

        // public property to access selected course in listBoxClassesToTake
        public Course SelectedObject
        {
            get
            {
                // check if anyhting is selected within listBoxClassesToTake
                if(listBoxClassesToTake.SelectedItem != null)
                {
                    return listBoxClassesToTake.SelectedItem as Course;
                }
                return new Course();
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
            Course i = ui.Data;

            // check if the course has been completed to determine which ListBox to add it to
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
            // check if the user has selected a course from listBoxClassesToTake
            if(listBoxClassesToTake.SelectedIndex == -1)
            {
                // alert the user they must select a course from the 1st ListBox to move to the 2nd
                MessageBox.Show("Please select a class from Classes To Take first.");
            }
            else
            {
                // move selected item from listBoxClassesToTake to listClassesCompleted
                listBoxClassesCompleted.Items.Add(listBoxClassesToTake.SelectedItem);

                // set checkBox for Done to true for the course moved
                Course i = listBoxClassesToTake.SelectedItem as Course;
                i.Done = true;

                // remove selected course from listClassesToTake
                listBoxClassesToTake.Items.Remove(listBoxClassesToTake.SelectedItem);
            }
        }

        private void btnMoveLeft_Click(object sender, EventArgs e)
        {
            // check if the user has selected a course from listClassesToTake
            if(listBoxClassesCompleted.SelectedIndex == -1)
            {
                // alert the user they must select a course from the 2nd ListBox to move to the 1st
                MessageBox.Show("Please select a class from Classes Completed first.");
            }
            else
            {
                // move selected item from listClasesCompleted to listBoxClassesToTake
                listBoxClassesToTake.Items.Add(listBoxClassesCompleted.SelectedItem);

                // set checkBox for Done to false
                Course i = listBoxClassesCompleted.SelectedItem as Course;
                i.Done = false;

                // remove selected item from listBoxClassesCompleted
                listBoxClassesCompleted.Items.Remove(listBoxClassesCompleted.SelectedItem);
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            // check to see if the user made a selection from listBoxClassesToTake
            if (listBoxClassesToTake.SelectedItem != null)
            {
                // delete selected course
                listBoxClassesToTake.Items.Remove(listBoxClassesToTake.SelectedItem);
            }
            else if(listBoxClassesCompleted.SelectedItem != null)
            {
                // delete selected course from listBoxClassesCompleted
                listBoxClassesCompleted.Items.Remove(listBoxClassesCompleted.SelectedItem);
            }
            else
            {
                // alert user to select a course first
                MessageBox.Show("Please select a class from Classes To Take first,\nor from Classes Completed.");
            }
        }

        // method to display s course double clicked from either ListBox
        private void listBoxClassesToTake_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            // Instantiate a new UserInput form 
            UserInput ui = new UserInput();

            // Subscribe to the event of editing a course when the user double clicks a course in listBoxClassesToTake
            ModifyObject += ui.UserInput_ModifyItem;

            // raise the event to send back data to change selected courses data in ListBox
            if (ModifyObject != null)
            {
                ModifyObject(this, new ModifyObjectEventArgs(SelectedObject));
            }

            // show UserInput form with populated fields to change
            ui.Show();
        }

        // method to save data in both ListBoxes in XML format
        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // Declare & instantiate a SaveDialogBox
            SaveFileDialog saveFileDialog = new SaveFileDialog();

            // Set the default extension
            saveFileDialog.DefaultExt = "xml";

            if (DialogResult.OK == saveFileDialog.ShowDialog())
            {
                // First we must create the XMLWriterSettings
                XmlWriterSettings settings = new XmlWriterSettings();

                // Set the level of conformance
                settings.ConformanceLevel = ConformanceLevel.Document;

                // Set the indent to true to head readability of the XML
                settings.Indent = true;

                // Create the XMLWriter
                using (XmlWriter writer = XmlWriter.Create(saveFileDialog.FileName, settings))
                {
                    // First element will define the data
                    writer.WriteStartElement("CourseData");

                    foreach(Course c in listBoxClassesToTake.Items)
                    {
                        // Save the title of the course
                        writer.WriteElementString("ClassTitle", c.Title);

                        // Save the status of course
                        writer.WriteElementString("CourseComplete", Convert.ToString(c.Done));
                    }

                    foreach(Course c in listBoxClassesCompleted.Items)
                    {
                        // Save the title of the course
                        writer.WriteElementString("ClassTitle", c.Title);

                        // Save the status of course
                        writer.WriteElementString("CourseComplete", Convert.ToString(c.Done));
                    }

                    // Write the end element for the data
                    writer.WriteEndElement();
                }
            }
        }
    }
}
