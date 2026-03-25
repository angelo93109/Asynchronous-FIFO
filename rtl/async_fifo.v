module async_fifo #(
    parameter DSIZE = 8,
    parameter ASIZE = 4 ) 
    (wdata, wreq, wfull, wclk, wrst_n,
    rdata, rreq, rempty, rclk, rrst_n);

input [DSIZE-1:0] wdata;
input wreq, wclk, wrst_n;
input rreq, rclk, rrst_n;
output [DSIZE-1:0] rdata;
output wfull, rempty;

wire [ASIZE-1:0] waddr, raddr; //N-1 Bit Gray Code 
wire [ASIZE:0] w2r_wptr, r2w_rptr, wptr, rptr; // N Bit Gray Code

fifomem u_fifomem (.wclk(wclk), .wdata(wdata), .wclken(wreq), .waddr(waddr), .rdata(rdata), .raddr(raddr)); 
wptr_full u_wptr_full (.wclk(wclk), .wrst_n(wrst_n), .wreq(wreq), .r2w_rptr(r2w_rptr), .wptr(wptr), .waddr(waddr), .wfull(wfull));
rptr_empty u_rptr_empty (.rclk(rclk), .rrst_n(rrst_n), .rreq(rreq), .w2r_wptr(w2r_wptr), .rptr(rptr), .raddr(raddr), .rempty(rempty));
sync_w2r u_sync_w2r (.rclk(rclk), .rrst_n(rrst_n), .wptr(wptr), .w2r_wptr(w2r_wptr));
sync_r2w u_sync_r2w (.wclk(wclk), .wrst_n(wrst_n), .rptr(rptr), .r2w_rptr(r2w_rptr));

endmodule 