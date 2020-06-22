name cmslpt

file resident
file cmsout
file res_data
file res_end

file cmsinit
file cmdline
file cmslpt

# Use tiny model, so that we don't need to worry about segments and
# can just assume that DS == CS
system com

option map
option quiet
