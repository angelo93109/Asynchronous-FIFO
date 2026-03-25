module fifomem #(
    parameter DSIZE = 8, 
    parameter ASIZE = 4 )
    (wclk, wdata, wclken, waddr, rdata, raddr);
    

input [DSIZE-1:0] wdata;
input wclken, wclk;
input [ASIZE-1:0] waddr;
output [DSIZE-1:0] rdata;
input [ASIZE-1:0] raddr;

`ifdef VENDOR_RAM
    VENDOR_RAM MEM(.dout(rdata), .din(wdata), .we(wclken), 
        .waddr(waddr), .raddr(raddr), .clk(wclk));
`else

reg [DSIZE-1:0] mem_array [0:(1<<ASIZE)-1];

always @(posedge wclk) begin
    if(wclken) begin
        mem_array[waddr] <= wdata;
    end
end

assign rdata = mem_array[raddr];

`endif

endmodule