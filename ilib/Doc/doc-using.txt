There are two ways to use the IMaude interaction environment: using only Maude
or using the IOP framework. These are illustrated with the help of the vending
machine example in IMaudeVend

To interact using only Maude: cd to IMaudeVend, start Maude and type

  load load-vend

which loads the necessary IMaude code, the vending machine specification
in vend.maude, and starts up loop mode with the command

  loop init .

Initialize the environment with some let commands to name states you are
interested in exploring, then you can rewrite and apply functions to the
results using the commands  described in doc-imaude.txt.
Examples can be found in input.txt 
and a scenario with output summary can be found in test-vend.txt.  

You can examine the current environment using the various `show' requests
of the IMAUDE-STATE module (also described in doc-imaude.txt).
input.txt has examples.

To interact via IOP you must have IOP installed with the IOP binary directory
in your path.  (IOP binaries for linux and mac, installation instructions,
manuals and papers can be found at http://jlambda.com/~iop/)

iop looks for a file named startup.txt configure itself ---
what actors to start with what parameters.
Two sample startups are provided.  startup-vend.txt allows you
interact with the vending machine via the IOP Gui.  startup-assist.txt
presents a specialized vending machine window with buttons and
menus for interaction.  In a shell in the IMaudeVend directory type

  iop -i startup-vend.txt

to interact with the vending machine via the IOP Gui.  Type

  iop -i startup-assist.txt

to get the vending machine window.  (The IOP Gui will also be avaliable.)

IOP will display the file input.txt in IOP Gui interaction window.  

In general, you can  use input.txt in the maude directory of
interest to predefine or save request scenarios. 

You send messages to IMaude by selecting a line and doing <KEY>l  where
KEY is ctl on Linux and cmd on Mac.

