Copy the **rotateLTasy.sh** to ~/.bashrc by clicking it, select all and copy functions inside then paste it into ~/.bashrc    
**rotLTSym** is Bash function performing multiplication of 2D cartesian pairs with rotation-matrix in a LTSpice's .asy file.   
The script will produce then its 45 and -45 degree (if it's horizontal or vertical) equivalences relative to horizontal line.   
But cannot rotate yet the ellipse (asymetric circle) and the arc part of the .asy symbol file 

## Requirement   
  - `bash` (tested, developed on version 5)  
  - `bc` (Linux basic calculator utility version 1.07)   

## Usage   

```
rotLTSym {dir | filename}
```
the result would be created in current directory


## Wish
Any developer capable of calculating the rotation of the ellipse and the arc defined by top-left and bottom-right points method is needed or expected to complete to the finish 
