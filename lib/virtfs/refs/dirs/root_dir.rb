require_relative '../fs_dir/dir_base'
module VirtFS::ReFS
  class RootDir < FSDir::DirBase
    attr_accessor :virtfs_dir

    def name
      '\\'
    end

    alias :fullname :name

    def self.parse(fs)
      dir = new fs
      dir.parse_dir_obj ROOT_DIR_ID, ''
      dir.virtfs_dir = Dir.new(dir)
      dir
    end

    def find_entry(nme)
      virtfs_dir.find_entry nme
    end
  end  # class RootDir
end # module VirtFS::ReFS
