all: comp sim

clean: 
	rm -rf simv* comp.log sim.log ucli* verdi* novas* csrc* *fsdb*

comp: 
	vcs ./rtl/* ./tb/* -full64 -sverilog -debug_access+all -kdb -l comp.log
	
sim: 
	simv -l sim.log

gui: 
	verdi -ssf async_fifo.fsdb -sswr signal.rc &