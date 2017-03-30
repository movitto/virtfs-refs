module VirtFS::ReFS
  class Dir
    def initialize(dir_entry)
      @dir_entry = dir_entry
    end

    def close
    end

    def fs_dir
      return @dir_entry.fs.root_dir if root?

      @dir_entry.fs.root_dir.dirs.find { |d|
        d.fullname == @dir_entry.name
      }
    end

    def glob_names
      dirs  = @dir_entry.fs.root_dir.dirs
      files = @dir_entry.fs.root_dir.files

      return (dirs+files).select { |d|
               d.fullname.count('\\') == 1
             }.collect { |d|
               d.fullname
             } if root?

      fn = @dir_entry.fullname
      seperators = fn.count('\\')

      (dirs+files).select { |d|
        d.fullname[0...fn.size] == fn &&
        d.fullname.count('\\') == seperators + 1
      }.collect { |d| d.fullname }
    end

    def root?
      @dir_entry.kind_of?(FSDir::DirBase)
    end

    def symlink?
      false
    end

    def virtfs_file
      File.new(@dir_entry)
    end

    def find_entry(name, type = nil)
      return virtfs_file if name == '.'

      dirs  = @dir_entry.fs.root_dir.dirs
      files = @dir_entry.fs.root_dir.files

      entry = (dirs + files).find { |d|
        d.fullname == name
      }

      raise "dir entry #{name} not found" if entry.nil?

      entry.is_a?(FSDir::DirEntry) ?
        entry.virtfs_dir : entry.virtfs_file
    end
  end # class Directory
end # module VirtFS::ReFS
