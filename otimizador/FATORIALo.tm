  2:     IN  0,0,0  
Linha: 3 LDA 2,0( 0)
  4:    LDC  0,0(0) 
Linha: 3 LDA 2,0( 0)
Linha: 6 LDA  0,0(2)
Linha: 6 LDA  0,0(2)
  8:    SUB  0,1,0  
  9:    JLT  0,2(7) 
 10:    LDC  0,0(0) 
 11:    LDA  7,1(7) 
 12:    LDC  0,1(0) 
 14:    LDC  0,1(0) 
Linha: 15 LDA 3,0( 0)
Linha: 16 LDA  0,0(3)
Linha: 16 LDA  0,0(3)
Linha: 18 LDA  0,0(2)
Linha: 18 LDA  0,0(2)
 20:    MUL  0,1,0 
Linha: 21 LDA 3,0( 0)
Linha: 22 LDA  0,0(2)
Linha: 22 LDA  0,0(2)
 24:    LDC  0,1(0) 
Linha: 22 LDA  0,0(2)
 26:    SUB  0,1,0 
Linha: 27 LDA 2,0( 0)
Linha: 28 LDA  0,0(2)
Linha: 28 LDA  0,0(2)
 30:    LDC  0,0(0) 
Linha: 28 LDA  0,0(2)
 32:    SUB  0,1,0 
 33:    JEQ  0,2(7) 
 34:    LDC  0,0(0) 
 35:    LDA  7,1(7) 
 36:    LDC  0,1(0) 
 37:    JEQ  0,-22(7) 
Linha: 38 LDA  0,0(3)
 39:    OUT  0,0,0 
 13:    JEQ  0,27(7) 
 40:    LDA  7,0(7) 
 41:   HALT  0,0,0 