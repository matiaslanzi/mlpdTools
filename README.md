#pdmlTools

A bunch of primitives for Pd that allow for quick prototyping of audio applications.
*For more information you can reach my [youtube channel](https://youtube.com/user/matiaslanzi)*

---
###Tools
These tools are simple **building blocks** to build modular synthesizers, beat
machines, groove boxes and more.

#mlSetup
This is the setup of the patch, here I declare the channels we're using as well
as a stereo master. Use this to create buses, default settings and any thing
specific to the setup of your patch.

mlSetup patch calls the *init* symbol then waits 100 ms and sets the *dsp* objet
to true. Use the *init* symbol in any patch that contains *mlSetup* to bang any
initializations
on the patches.

The audio routing is defined in *audioIO*.

#mlMaster
Declares 2 symbols MBusL and MBusR, these will be your stereo master bus.
Volume of the 2 channels can be controller with the *volumeMaster* symbol.
Balance of the 2 channels can be controlled with the *balanceMaster* symbol.

#mlUI
This is a simple mixer for the default *mlSetup*.
8 channels routed to 1 master with volume, pan, balance and VU meters.
