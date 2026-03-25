module sync_w2r #(
    parameter DSIZE = 8, 
    parameter ASIZE = 4)
    (rclk, rrst_n, wptr, w2r_wptr);
    
    input rclk, rrst_n;
    input [ASIZE:0] wptr;
    output [ASIZE:0] w2r_wptr;
    reg [ASIZE:0] wptr_reg1, wptr_reg2;

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wptr_reg1 <= 0;
            wptr_reg2 <= 0;
        end else begin
            wptr_reg1 <= wptr;
            wptr_reg2 <= wptr_reg1;
        end
    end

    assign w2r_wptr = wptr_reg2; 

endmodule

module sync_r2w #(
    parameter DSIZE = 8,
    parameter ASIZE = 4)
    (wclk, wrst_n, rptr, r2w_rptr);

    input wclk, wrst_n;
    input [ASIZE:0] rptr;
    output [ASIZE:0] r2w_rptr;
    reg [ASIZE:0] rptr_reg1, rptr_reg2;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rptr_reg1 <= 0;
            rptr_reg2 <= 0;
        end else begin
            rptr_reg1 <= rptr;
            rptr_reg2 <= rptr_reg1;
        end
    end
    assign r2w_rptr = rptr_reg2;
endmodule 