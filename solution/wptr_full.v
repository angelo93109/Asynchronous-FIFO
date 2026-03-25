module wptr_full (wfull, waddr, wptr, wrptr2, winc, wclk, wrst_n);
    parameter ADDRSIZE = 4;
    output wfull;
    output [ADDRSIZE-1:0] waddr;
    output [ADDRSIZE:0] wptr;
    input [ADDRSIZE:0] wrptr2;
    input winc, wclk, wrst_n;
    reg [ADDRSIZE:0] wptr, wbin, wgnext, wbnext;
    reg wfull, waddrmsb;

    // GRAYSTYLE1 pointer
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr <= 0;
            waddrmsb <= 0;
        end else begin
            wptr <= wgnext;
            waddrmsb <= wgnext[ADDRSIZE]^wgnext[ADDRSIZE-1];
        end
    end 

    always @(wptr or winc) begin: Gray_inc
        integer i;
        for (i=0; i<=ADDRSIZE; i=i+1)
            wbin[i] = ^(wptr>>i);
        
        if (!wfull) 
            wbnext = wbin + winc;
        else 
            wbnext = wbin;
        
        wgnext = (wbnext>>1) ^ wbnext;
    end
    
    // Memory write-address pointer
    assign waddr = {waddrmsb,wptr[ADDRSIZE-2:0]};
    wire w_2ndmsb = wgnext[ADDRSIZE] ^ wgnext[ADDRSIZE-1];
    wire wr_2ndmsb = wrptr2[ADDRSIZE] ^ wrptr2[ADDRSIZE-1];
    
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) wfull<=0;
        else wfull<=((wgnext[ADDRSIZE] !=wrptr2[ADDRSIZE]) &&
            (w_2ndmsb ==wr_2ndmsb ) &&
            (wgnext[ADDRSIZE-2:0]==wrptr2[ADDRSIZE-2:0]));
    end 
endmodule