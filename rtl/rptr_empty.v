module rptr_empty #(
    parameter DSIZE = 8, 
    parameter ASIZE = 4 )
    (rclk, rrst_n, rreq, w2r_wptr, rptr, raddr, rempty);

    input rclk, rrst_n, rreq;
    input [ASIZE:0] w2r_wptr; // Gray Code
    output reg [ASIZE:0] rptr; // Gray Code
    output [ASIZE-1:0] raddr; 
    output reg rempty;
    reg [ASIZE:0] rbin, rbin_nxt, rgray_nxt; 
    reg raddr_msb; 

    // Binary Read Pointer 
    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n) begin
            rptr <= 0; 
            raddr_msb <= 0; 
        end else if (!rempty) begin
            rptr <= rgray_nxt; 
            // Operation to get the MSB from N bit gray code to N-1 bit gray code
            raddr_msb <= rgray_nxt[ASIZE] ^ rgray_nxt[ASIZE-1];
        end
    end

    assign raddr = {raddr_msb, rptr[ASIZE-2:0]}; //Memory access address [ASIZE-1:0]

    // Binary Code to Gray Code
    always @(rptr or rreq) begin
        integer i; 
        for(i=ASIZE; i>=0; i=i-1) // Convert Gray Code to Binary Code
            rbin[i] = ^(rptr>>i); //b(msb)=g(msb), b(msb-1)=b(msb)^g(msb-1) ...
        
        if(!rempty) 
            rbin_nxt = rbin + rreq; 
        else 
            rbin_nxt = rbin; 

        rgray_nxt = rbin_nxt ^ (rbin_nxt>>1); // Convert Binary Code to Gray Code
    end

    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n) begin
            rempty <= 0;
        end else begin
            rempty <= (w2r_wptr == rgray_nxt); 
        end 
    end

endmodule
