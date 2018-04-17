include Makefile.cheyenne

build_dir = $(run_dir)/build_$(mitgcm_checkpoint)_$(tile_size)
mitgcmuv = $(build_dir)/mitgcmuv

# hack to refer to the main directory where the makefile lives
base_dir := $(shell pwd)

#$(mitgcm_dir) :
#	cvs co -P -r checkpoint$(mitgcm_checkpoint) MITgcm_code
#	mv MITgcm $(mitgcm_dir)

$(mitgcmuv) : $(mitgcm_dir)
	mkdir -p $(build_dir) && \
	  cd $(build_dir) && \
	  $(module_cmd) && \
	  cp $(base_dir)/code/SIZE.h_$(tile_size) SIZE.h && \
	  $(mitgcm_dir)/tools/genmake2 -rootdir $(mitgcm_dir) -of $(base_dir)/code/$(optfile) -mpi -mods $(base_dir)/code && \
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
	# TODO: translate timestep of pickup to timestep of model
	cp scripts/* $(target_dir)
