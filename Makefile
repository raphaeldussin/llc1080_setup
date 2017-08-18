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
### end platform specific options

mitgcm_dir = MITgcm_$(mitgcm_checkpoint)
build_dir = build_$(mitgcm_checkpoint)_$(tile_size)
mitgcmuv = $(build_dir)/mitgcmuv

$(mitgcm_dir) :
	cvs co -P -r checkpoint$(mitgcm_checkpoint) MITgcm_code
	mv MITgcm $(mitgcm_dir)

$(mitgcmuv) : $(mitgcm_dir)
	mkdir -p $(build_dir) && \
	  cd $(build_dir) && \
	  $(module_cmd) && \
	  cp ../code/SIZE.h_90x90x1342 SIZE.h && \
	  ../$(mitgcm_dir)/tools/genmake2 -rootdir ../$(mitgcm_dir) -of ../code/$(optfile) -mpi -mods ../code && \
	  make depend && \
	  make -j8

mitgcmuv : $(mitgcmuv)

