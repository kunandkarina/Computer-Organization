module m42(y,d,select);
    output y;
    input [0:3] d;
    input [1:0] select;
    wire t1,t2;

    m21 mux1(y,t1,t2,select[1]);
    m21 mux2(t1,d[0],d[1],select[0]);
    m21 mux3(t2,d[2],d[3],select[0]);

endmodule