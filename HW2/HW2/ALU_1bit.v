module ALU_1bit( result, carryOut, a, b, invertA, invertB, operation, carryIn, less ); 
  
  output wire result;
  output wire carryOut;
  
  input wire a;
  input wire b;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  input wire carryIn;
  input wire less;
  
  /*your code here*/ 
  wire A,B;
  m21 m1(A,a,~a,invertA);
  m21 m2(B,b,~b,invertB);
  
  wire OR,AND,ADD;
  or (OR,A,B);
  and (AND,A,B);
  Full_adder Fa(ADD, carryOut, carryIn, A, B);
  
  m42 m3(result,{OR,AND,ADD,less}, operation);
  
endmodule