module VirtFS::ReFS
  class File
    def initialize(file_entry)
      @file_entry = file_entry
    end

    def to_h
      { :directory? => false,
        :file?      => false,
        :symlink?   => false } # ...
    end

    def dir?
    end

    def file?
    end

    def symlink?
      false
    end

    def fs
    end

    def size
    end

    def close
    end
  end # class File
end # module VirtFS::ReFS
