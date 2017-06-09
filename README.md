# IMaude


IMaude is a set of Maude Modules to be used in conjuction
with the [Maude system](http://maude.cs.uiuc.edu) and the
[IOP Platform](https://github.com/SRI-CSL/iopc)
 to program interactive Maude applications.  It is used in systems such as the 
 [Pathway Logic Assistant](http://pl.csl.sri.com/) and the [Maude-NPA System](http://maude.cs.illinois.edu/w/index.php?title=Maude_Tools:_Maude-NPA) and its [GUI.](http://www.csl.sri.com/users/iam/NPA/index.html)

## Overview

This repository serves two purposes. It contains the shared
libraries for imaude (interactive maude) applications such as those mentioned above. It also contains
the simple vending machine example, that illustrates how to use the IMaude system.

### Vending Machine

There are two ways to use the IMaude interaction environment: using only Maude
or using the IOP framework. These are illustrated with the help of the vending
machine example in subdirectory VendingMachine

To interact using only Maude, cd to [VendingMachine](VendingMachine), and type
```
  maude load-vend
```
[load-vend.maude](VendingMachine/load-vend.maude) loads the necessary IMaude code, maude's model checker, the vending machine specification
in [vend.maude](VendingMachine/vend.maude) and then starts up loop mode with the command
```
  loop init .
```
Initialize the environment with some let commands to name states you are
interested in exploring, then you can rewrite and apply functions to the
results using the commands  described in [test-vend.txt](VendingMachine/test-vend.txt).
Examples can be found in [input.txt](VendingMachine/input.txt) 
and a scenario with output summary can be found in [test-vend.txt](VendingMachine/test-vend.txt).  

You can examine the current environment using the various `show` requests
of the `IMAUDE-STATE` module (also described in [doc-imaude.txt](ilib/Doc/doc-imaude.txt)).
input.txt has examples.

To interact via IOP you must have [IOP Platform](https://github.com/SRI-CSL/iopc) installed with the `IOPBINDIR` binary directory
in your path.  

By default `iop` looks for a file named `startup.txt` to configure itself ---
what actors to start with what parameters.
Two sample startups are provided.  [startup-vend.txt](VendingMachine/startup-vend.txt) allows you
interact with the vending machine via the IOP GUI.  [startup-assist.txt](VendingMachine/startup-assist.txt)
presents a specialized vending machine window with buttons and
menus for interaction.  You can overide the default choice of `startup.txt`
by using the `-i` switch.
In a shell in the VendingMachine directory type
```
  iop -i startup-vend.txt
```
to interact with the vending machine via the IOP GUI.  Type
```
  iop -i startup-assist.txt
```
to get the vending machine window, a GUI application written in jlambda in the file 
[vend.lsp](VendingMachine/vend.lsp). The IOP GUI window will also be available, sometimes
useful for debugging the system of actors.

IOP will display the file [input.txt](VendingMachine/input.txt) in IOP GUI interaction window.  

In general, you can use input.txt in the maude directory of
interest to predefine or save request scenarios. 

You send messages to IMaude by selecting a line and doing `<KEY>l`  where
`KEY` is `control` on Linux and `command` on Mac.


## References

A technical description of the IMaude system can be found in the paper:

[IOP: The InterOperability Platform and IMaude: An Interactive Extension of Maude](http://www.csl.sri.com/~clt/Papers/04wrla-iop.pdf)
by Ian A. Mason and Carolyn L. Talcott.

From Fifth International Workshop on Rewriting Logic and Its Applications (WRLA'2004). Elsevier. 2004.
