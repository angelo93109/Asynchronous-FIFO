module wptr_full #(
    parameter DSIZE = 8, 
    parameter ASIZE = 4)
    (wclk, wrst_n, wreq, r2w_rptr, wptr, waddr, wfull);
    
    input wclk, wrst_n, wreq; 
    input [ASIZE:0] r2w_rptr; // with overflow flag bit (Gray Code)
    output reg [ASIZE:0] wptr; // with overflow flag bit (Gray Code)
    output [ASIZE-1:0] waddr; // Gray code address
    output reg wfull; 

    reg [ASIZE:0] wbin, wbin_nxt, wgray_nxt;
    reg waddr_msb; 
    wire r2w_rptr_msb, wgray_nxt_msb; 

    // Binary Address 
    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n) begin
            wptr <= 0;
            waddr_msb <= 0;
        end else begin
            wptr <= wgray_nxt;
            waddr_msb <= wgray_nxt[ASIZE]^wgray_nxt[ASIZE-1];
        end
    end

    // Gray Code Address
    always @(wreq or wptr) begin
        // Binary to Gray Code
        integer i; 
        for(i=ASIZE; i>=0; i=i-1)
            wbin[i] = ^(wptr>>i); 

        if(!wfull)
            wbin_nxt = wbin + wreq;
        else 
            wbin_nxt = wbin;

        wgray_nxt = (wbin_nxt>>1) ^ (wbin_nxt); 
    end

    assign waddr = {waddr_msb, wptr[ASIZE-2:0]};
    // Because we need the [ASIZE] MSB bit to sense the overflow or underflow, it is the sticky status bit.
    // However, with the bit, the rest of the [ASIZE-1:0] are not actual ASIZE-1:0 bits Gray Code. 
    // We have to apply MSB^MSB-1= actual MSB operation to get back the actual MSB
    assign wgray_nxt_msb = wgray_nxt[ASIZE] ^ wgray_nxt[ASIZE-1];
    assign r2w_rptr_nxt = r2w_rptr[ASIZE] ^ r2w_rptr[ASIZE-1];

    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n) begin
            wfull <= 0; 
        end else begin
            wfull <= (wgray_nxt[ASIZE] != r2w_rptr[ASIZE]) && // Overflow & Underflow sticky bit status
                     (wgray_nxt[ASIZE-2:0] == r2w_rptr[ASIZE-2:0]) && // Compare the rest of gray code value
                     (wgray_nxt_msb == r2w_rptr_nxt); // recover the MSB of [ASIZE-1:0] length gray code from [ASIZE:0] gray code
        end
    end 

endmodule