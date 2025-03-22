--------------------- PICO-8 TETRIS ---------------------


General Loop:


Load Cart -> Loads blank in-game GUI -> press Z to start

-> Load Piece and Show Next Piece -> Piece reaches the ceiling -> END -> Load Blank


Game States:

0 Blank/Not Running
1 Playing


Data Structures:


Game Board - Matrix: a 2D array represents the game board. 

Whenever a piece is dropped the matrix is checked for any full line -> If so clear the line and adds to the Score/Lines counter.
If 4 lines cleared at the same time -> Tetris!
If multiple lines cleared at the same time -> Bonus Mult

Next Piece Buffer - Queue that holds at least 2 pieces.

The next piece buffer holds the reference to the next few pieces.
It's a QUEUE (FIFO).


Gameplay:

Left Arrow/Right Arrow: Move
Down Arrow: Fast drop
Up Arrow: Drops immediately
Z/X: Rotates Left/Rotates Right

Z+X = Swap?

Pieces fall at a rate of X Pixels/Frame

Coyote Time: Whenever a piece touches another piece/bottom of board it waits a few frames until it is locked.
Piece can be moved and rotated if valid while it's in coyote time.

Collisions: Pieces should be checked each frame for contact with another piece/board.

Implement a method that rotates a piece.


Piece States:

0 Locked
1 Selected