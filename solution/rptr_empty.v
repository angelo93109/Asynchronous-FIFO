module rptr_empty (rempty, raddr, rptr, rwptr2, rinc, rclk, rrst_n);
    parameter ADDRSIZE = 4;
    output rempty;
    output [ADDRSIZE-1:0] raddr;
    output [ADDRSIZE:0] rptr;
    input  [ADDRSIZE:0] rwptr2;   // write pointer synchronized into read clock (Gray)
    input  rinc, rclk, rrst_n;

    reg [ADDRSIZE:0] rptr, rbin, rgnext, rbnext;
    reg rempty, raddrmsb;

    //-------------------
    // GRAYSTYLE1 pointer
    //-------------------
    // Maintain Gray-coded read pointer; on reset clear pointers/MSB tracking.
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) begin
            rptr     <= 0;
            raddrmsb <= 0;
        end else begin
            rptr     <= rgnext;                          // commit next Gray read pointer
            // Operation to get the MSB from N bit gray code to N-1 bit gray code
            raddrmsb <= rgnext[ADDRSIZE]^rgnext[ADDRSIZE-1]; 
        end

    // Combinational Gray increment logic.
    // Convert Gray -> binary (rbin), optionally increment, then binary -> Gray (rgnext).
    always @(rptr or rinc) begin : Gray_inc
        integer i;
        for (i=ADDRSIZE; i>=0; i=i-1)
            rbin[i] = ^(rptr >> i);          // prefix XOR converts Gray to binary
        if (!rempty)
            rbnext = rbin + rinc;            // increment binary pointer when not empty
        else
            rbnext = rbin;                   // hold when empty
        rgnext = (rbnext >> 1) ^ rbnext;     // binary -> Gray conversion
    end

    // Memory read-address pointer (binary addr bits + folded MSB to select half).
    assign raddr = {raddrmsb, rptr[ADDRSIZE-2:0]}; //

    //---------------------------------------------------------------
    // FIFO empty on reset or when next read pointer == synced write pointer
    //---------------------------------------------------------------
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n)
            rempty <= 1'b1;                  // empty after reset
        else
            rempty <= (rgnext == rwptr2);    // empty when pointers match (Gray)

endmodule