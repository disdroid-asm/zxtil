# ZX-TIL
An implementation of the code published in ["Threaded Interpretive Languages"](https://ia902805.us.archive.org/27/items/R.G.LoeligerThreadedInterpretiveLanguagesTheirDesignAndImplementationByteBooks1981/R.%20G.%20Loeliger-Threaded%20Interpretive%20Languages_%20Their%20Design%20and%20Implementation-Byte%20Books%20%281981%29.pdf) by R. G. Loeliger 1981, for the ZX Spectrum 48k.

## Building

Assemble using sjasmplus to generate a TAP file:
`sjasmplus code/code.asm -DTAP`

## Status

The outer interpreter loop is running. Input is read from the keyboard by line, tokenised and executed.
Because of a bug in the keyboard routine, symbol shift isn't working so it hasn't been possible to test
the defining words such as `CREATE` and `:` yet. 

_TODO_ Update the outer loop to enable processing of text from RAM instead of the terminal, and to support 
loading from mass storage. 


## Notes

The code in the book is largely complete but contains several bugs and typos. I'm steadily fixing these.

Because the iy register is used to store the address of the NEXT routine, then the Spectrum ROM can't be
used. 

Therefore it was necessary to import keyboard and display routines from my game library.
These had to be adapted to support text input using caps and symbol shift.
_TODO_ The symbol shift routine isn't working properly yet. This is quite hard to debug in the emulator becuase
the keypresses aren't processed when the machine is suspended at a breakpoint.


