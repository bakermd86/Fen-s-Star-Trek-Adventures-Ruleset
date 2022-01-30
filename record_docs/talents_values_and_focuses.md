## Talents, Values and Focuses

### Talent Requirements

Talent records are very simple text-based records, they are self-explanatory except for how the "Requirements" field is 
handled by the [talent selection widget](../general/lifepath_wizard#selecting-or-creating-talents). The talent selection 
window has the option to display only talents whose requirements are met. But that only works if the requirement strings 
are formatted as it expects.

These are the string formats that the utility understands and should work correctly:

* A blank value will always be considered as having its requirements met
* As will any string containing the values "Main Character" or "None" 
* A string containing a species name anywhere in it will match for that species (e.g. "Vulcan or GM Permission", "Andorian, Vulcan or Human" would both match for a Vulcan)
* A Discipline score requirement of the format Discipline X+ (e.g. "Security 4+") will match if the score is met or exceeded
* A list of such discipline score requirements will work if any of the scores are met (e.g. "Conn 2+ or Engineering 2+", "Science 3+, Medicine 3+ or Security 3+")

For discipline score filters, make sure not to include any other characters besides a space between the discipline name 
and the minimum score. And be sure to include the + at the end as well.

### Values and Focuses, Why Though?

Values and focuses are no different from any text record, just a string field for the name and a formatted text body. 
So you might wonder why I bothered breaking them out to their own record types. 

The only real reason is just for the random value/focus buttons in the 
[Lifepath Wizard](../general/lifepath_wizard#random-mode) and the 
[Supporting Character Select](../record_docs/ship_record#supporting-characters). If you want to be able to use those 
buttons to get random focuses/values, then you have to define a bunch of values and focuses for them to choose from.

Other than that, these records are not really necessary as you can just create values/focuses directly in the character 
or NPC record sheets without needing to externally define them.

