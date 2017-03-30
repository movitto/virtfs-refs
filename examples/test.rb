require 'json'
require 'virtfs'
require 'virtfs/refs'
require 'virt_disk/block_file'
require 'virtfs-nativefs-thick'
require 'virtfs/block_io'

native_fs = VirtFS::NativeFS::Thick.new
VirtFS.mount(native_fs, "/")

PATH   = "/home/mmorsi/Downloads/refs.img"
OFFSET = 34603008
device = VirtFS::BlockIO.new(VirtDisk::BlockFile.new(PATH, OFFSET))

exit 1 unless VirtFS::ReFS::FS.match?(device)
fs = VirtFS::ReFS::FS.new(device)
puts fs.root_dir.dirs.collect { |d| d.fullname }
puts "~~~"

VirtFS.mount fs, '/mnt'
puts VirtFS::VDir.entries('/mnt/subdir1/')
