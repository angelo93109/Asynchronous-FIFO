module tb;
	localparam DSIZE = 8;
	localparam ASIZE = 4;
	localparam DEPTH = (1 << ASIZE);

	reg                   wclk = 1'b0;
	reg                   rclk = 1'b0;
	reg                   wrst_n = 1'b0;
	reg                   rrst_n = 1'b0;
	reg                   wreq = 1'b0;
	reg                   rreq = 1'b0;
	reg  [DSIZE-1:0]      wdata = {DSIZE{1'b0}};
	wire [DSIZE-1:0]      rdata;
	wire                  wfull;
	wire                  rempty;

	reg                   write_phase = 1'b0;
	reg                   read_phase  = 1'b0;
	integer               fill_count = 0;

	// simple scoreboard to track expected FIFO contents
	reg [DSIZE-1:0]       exp_queue [$];

	async_fifo #(.DSIZE(DSIZE), .ASIZE(ASIZE)) dut (
		.wdata (wdata),
		.wreq  (wreq),
		.wfull (wfull),
		.wclk  (wclk),
		.wrst_n(wrst_n),
		.rdata (rdata),
		.rreq  (rreq),
		.rempty(rempty),
		.rclk  (rclk),
		.rrst_n(rrst_n)
	);

	// 3 ns period write clock
	always #1.5 wclk = ~wclk;

	// 20 ns period read clock
	always #10 rclk = ~rclk;

	// generate wreq: single wclk-cycle pulse when in write_phase
	initial begin
		wreq = 1'b0;
		wait (wrst_n);
		forever begin
			@(posedge wclk);
			if (write_phase && !wfull) begin
				wreq = 1'b1;
				@(posedge wclk);
				wreq = 1'b0;
			end else begin
				wreq = 1'b0;
			end
		end
	end


	// generate rreq: single rclk-cycle pulse when in read_phase
	initial begin
		rreq = 1'b0;
		wait (rrst_n);
		forever begin
			@(posedge rclk);
			if (read_phase && !rempty) begin
				rreq = 1'b1;
				@(posedge rclk);
				rreq = 1'b0;
			end else begin
				rreq = 1'b0;
			end
		end
	end

	// write domain stimulus and scoreboard push using initial block
	initial begin
		wait (wrst_n && rrst_n);
		write_phase = 1'b1;
		forever begin
			@(posedge wclk);
			if (write_phase && wreq && !wfull) begin
				wdata <= $urandom;
				exp_queue.push_back(wdata);
				fill_count = fill_count + 1;
				if (fill_count >= DEPTH) begin
					write_phase = 1'b0;
					read_phase  = 1'b1;
				end
			end
		end
	end

	// read domain checking and scoreboard pop using event control
	initial begin
		wait (rrst_n);
		forever begin
			@(rreq && !rempty);
			if (exp_queue.size() == 0) begin
				$error("Read when scoreboard is empty");
			end else begin
				if (rdata !== exp_queue[0]) begin
					$error("Data mismatch: expected %0h, got %0h", exp_queue[0], rdata);
				end
				exp_queue.pop_front();
				if (exp_queue.size() == 0 && read_phase) begin
					$display("FIFO drained");
				end
			end
		end
	end

	// reset sequencing: assert rrst_n first, then wrst_n
	initial begin
		rrst_n = 1'b0;
		wrst_n = 1'b0;
		#30;      // hold read reset low
		rrst_n = 1'b1;
		#20;      // allow read domain to exit reset before write domain
		wrst_n = 1'b1;
	end

	// stop simulation after some time
	initial begin
		#5000;
		$display("Simulation completed");
		$finish;
	end

    initial begin
        $fsdbDumpfile("async_fifo.fsdb"); 
        $fsdbDumpvars(0, tb, "+mda");
    end

endmodule