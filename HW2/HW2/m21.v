module m21(y,d0,d1,select);
    output y;
    input d0,d1,select;
    wire t1,t2;

    and (t1,d0,~select), (t2,d1,select);
    or (y,t1,t2);

endmodule
