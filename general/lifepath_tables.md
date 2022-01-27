## Lifepath Table Definition

This section describes the process of manually defining tables for the Lifepath wizard. It can be done by simply going through 
the relevant section of the PDF and using the wizard I created.

You may ask why I went to the trouble to create a UI wizard to define tables in a specific format rather than simply creating 
the tables myself. It would be much less work to simply create the tables and package them in. But the written content of the tables 
is copyrighted intellectual property of Mopiphius which I am sure they worked very hard on, so packaging that content into my 
extension would be unethical. So if you want to have automated tables in the tool, this wizard seemed like the way to go.

This ensures that users of the extension have to buy the actual source book in order to be able to use the lifepath tables 
from the book.

As a side bonus, it also means that you can define your own custom table sets if you want to use a non-standard set of tables for 
character creation in your game. 22nd century setting? Orion Syndicate? Romulan spies? All Borg all the time? Knock yourself 
out, you can create whatever custom tables you want for character creation in your games.

### Creating a tableset

The wizard outputs ordinary Fantasy Grounds table records, but it also creates a tableset reference to link the records 
together into a single set, and allow for setting the defaults to be used by players more easily.

Also, the formatting of the data in the tables must be exactly as the tool expects, so this wizard ensures that the tables 
created will work with the lifepath wizard and function as expected. 

To open the tableset wizard, simply click the "Lifepath Table Settings" button in the GM detail pane:

![](../images/gm_detail_pane.png)

Then in the settings window, use the green + icon to open the wizard:

![](../images/lifepath_table_settings.png)

The wizard will look like this:

![](../images/lifepath_table_wizard_1.png)

At the top, you set a name for the full set of tables, this is what you then set as the default for lifepath creation for 
your players to use.

The tabs below will take you through the six steps of lifepath creation. In the blue input section, you can enter names for each individual table (
I would recommend giving each table within the set a globally-unique name to avoid any issues with FGs normal name-based 
table resolution mechanism via the [] brackets). 

In the purple input section, you define each row in the table by entering the from/to range of numbers, the name of the result, 
and then using the control widgets to select whatever attributes or disciplines are linked to that result.

