SHELL:=/bin/bash

# platform specific options...should be moved to config file
mitgcm_checkpoint = 66h
tile_size = 60x60x2872
define module_cmd
. /etc/profile.d/modules.sh && \
module load comp/intel-17.0.2.174 mpi/sgi-mpt-2.15
endef
# optfile should reside in the code directory
optfile = linux_amd64_ifort_discover_sgi-mpt
# where to put the binary files
bin_dir = /discover/nobackup/rpaberna/llc_1080/bin_files
forcing_dir = /discover/nobackup/rpaberna/llc_1080/ECMWF_operational/NEW
pickup_dir = /discover/nobackup/rpaberna/llc_1080/pickup/run_year1
# seconds since 2010-01-1
pickup_time = 37843200
# where to run the model
run_dir = /discover/nobackup/rpaberna/llc_1080_new
### end platform specific options

mitgcm_dir = MITgcm_$(mitgcm_checkpoint)
build_dir = build_$(mitgcm_checkpoint)_$(tile_size)
mitgcmuv = $(build_dir)/mitgcmuv

# hack to refer to the main directory where the makefile lives
base_dir := $(shell pwd)

$(mitgcm_dir) :
	cvs co -P -r checkpoint$(mitgcm_checkpoint) MITgcm_code
	mv MITgcm $(mitgcm_dir)

$(mitgcmuv) : $(mitgcm_dir)
	mkdir -p $(build_dir) && \
	  cd $(build_dir) && \
	  $(module_cmd) && \
	  cp ../code/SIZE.h_$(tile_size) SIZE.h && \
	  ../$(mitgcm_dir)/tools/genmake2 -rootdir ../$(mitgcm_dir) -of ../code/$(optfile) -mpi -mods ../code && \
	  make depend && \
	  make -j8

mitgcmuv : $(mitgcmuv)

check_bin_files :
	cd $(bin_dir); md5sum -c $(base_dir)/bin_files.chk 
	cd $(forcing_dir); md5sum -c $(base_dir)/ecmwf_operational.chk
	cd $(pickup_dir); md5sum -c $(base_dir)/pickup.chk

run_% : input_% $(mitgcmuv)
	$(eval target_dir = $(run_dir)/$@)
	mkdir -p $(target_dir)
	ln -sf $(bin_dir)/* $(target_dir)
	ln -sf $(forcing_dir)/* $(target_dir)
	cp $(mitgcmuv) $(target_dir)
	cp input/* $(target_dir)
	cp $</* $(target_dir)
	mv $(target_dir)/data.exch2_$(tile_size) $(target_dir)/data.exch2
	#ln -sf $(pickup_dir)/* $(target_dir)
	# get the correct timestep for the pickup file
	$(eval deltat := $(shell ../scripts/get_data_variable.sh $(target_dir)/data deltat ))
	cp $(deltat) .
	# TODO: translate timestep of pickup to timestep of model
	cp scripts/* $(target_dir)
