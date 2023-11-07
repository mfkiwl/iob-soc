SIM_SERVER=$(CADENCE_SERVER)
SIM_USER=$(CADENCE_USER)
SIM_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SIM_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SIM_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)

COV_TEST?=test

SFLAGS = -errormax 15 -status -licqueue
EFLAGS = $(SFLAGS) -access +wc
ifeq ($(COV),1)
COV_SFLAGS= -covoverwrite -covtest $(COV_TEST)
COV_EFLAGS= -covdut $(NAME)_$(CSR_IF) -coverage A -covfile xcelium_cov_commands.ccf
endif

VFLAGS=$(SFLAGS) -update -linedebug -sv -incdir .

ifneq ($(wildcard ../src),)
VFLAGS+=-incdir ../src
endif

ifneq ($(wildcard src),)
VFLAGS+=-incdir src
endif

ifneq ($(wildcard hardware/src),)
VFLAGS+=-incdir hardware/src
endif

ifeq ($(VCD),1)
VFLAGS+=-define VCD
endif

ifeq ($(SYN),1)
VFLAGS+=-define SYN
endif

comp xmvlog.log: $(VHDR) $(VSRC) $(HEX)
	xmvlog $(VFLAGS) $(VSRC)

elab xmelab.log: comp xmvlog.log
	xmelab $(EFLAGS) $(COV_EFLAGS) worklib.$(NAME)_tb:module

exec: elab xmelab.log
	sync && sleep 1 && xmsim $(SFLAGS) $(COV_SFLAGS) worklib.$(NAME)_tb:module
ifeq ($(COV),1)
	ls -d cov_work/scope/* > all_ucd_file
	imc -execcmd "merge -runfile all_ucd_file -overwrite -out merge_all"
	imc -init iob_cov_waiver.tcl -exec xcelium_cov.tcl
endif

clean: gen-clean
	@rm -f xmelab.log  xmsim.log  xmvlog.log
	@rm -f iob_cov_waiver.vRefine

very-clean: clean
	@rm -rf cov_work *.log
	@rm -f coverage_report_summary.rpt coverage_report_detail.rpt


.PHONY: comp elab exec clean very-clean
