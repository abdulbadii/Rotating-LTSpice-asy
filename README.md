Copy the **MatrixMultiplier.sh** to ~/.bashrc by clicking it, select all and copy functions inside then paste it into ~/.bashrc    
**rotLTSym** is Bash function performing multiplication of 2D cartesian pairs with rotation-matrix in a LTSpice's .asy file.
The script will produce then its 45 and -45 degree (if it's horizontal or vertical) equivalent ones relaive to horizontal line.
But cannot do yet for arc part of the .asy symbol file 

## Requirement  
  - `bash` (tested, developed on version 5)  
  - `bc` (Linux basic calculator utility version 1.07)   

## Usage

rotLTSym {dir | filename}
