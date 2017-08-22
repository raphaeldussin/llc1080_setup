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
### end platform specific options

mitgcm_dir = MITgcm_$(mitgcm_checkpoint)
build_dir = build_$(mitgcm_checkpoint)_$(tile_size)
mitgcmuv = $(build_dir)/mitgcmuv

base_dir := $(shell pwd)

#bin_files = $(bin_dir)/bathy1080_g5_r4 \ 
#  $(bin_dir)/Jan2010_SALT_1080x14040x50_r4 \
#  $(bin_dir)/Jan2010_SALT_1080x14040x90_r4 \
#  $(bin_dir)/Jan2010_SIarea_1080x14040_r4 \
#  $(bin_dir)/Jan2010_SIheff_1080x14040_r4 \
#  $(bin_dir)/Jan2010_SIhsalt_1080x14040_r4 \
#  $(bin_dir)/Jan2010_SIhsnow_1080x14040_r4 \
#  $(bin_dir)/Jan2010_THETA_1080x14040x50_r4 \
#  $(bin_dir)/Jan2010_THETA_1080x14040x90_r4 \
#  $(bin_dir)/runoff1p2472-360x180x12.bin \
#  $(bin_dir)/tile001.mitgrid \
#  $(bin_dir)/tile002.mitgrid \
#  $(bin_dir)/tile003.mitgrid \
#  $(bin_dir)/tile004.mitgrid \
#  $(bin_dir)/tile005.mitgrid \
#  $(bin_dir)/tile006.mitgrid 

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

check_bin_files :
	cd $(bin_dir); md5sum -c $(base_dir)/bin_files_md5sum.chk 
		
