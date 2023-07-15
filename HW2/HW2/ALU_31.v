module ALU_31( result, carryOut, a, b, invertA, invertB, operation, carryIn, less, set, overflow ); 
  
  output wire result;
  output wire carryOut;
  output wire set;
  output wire overflow;
  
  input wire a;
  input wire b;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  input wire carryIn;
  input wire less;

  wire A,B;
  m21 m1(A,a,~a,invertA);
  m21 m2(B,b,~b,invertB);

  wire OR,AND,ADD;
  or (OR,A,B);
  and (AND,A,B);
  Full_adder Fa(ADD, carryOut, carryIn, A, B);

  m42 m3(set, {ADD,1'b0,1'b1,ADD}, {a,b});
  m42 m4(result, {OR,AND,ADD,less}, operation);

  wire Over;
  xor (Over, carryIn, carryOut);
  m42 m5(overflow, {1'b0, 1'b0, Over, Over}, operation);

endmodule

