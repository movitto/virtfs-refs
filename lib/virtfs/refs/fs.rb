require_relative 'fs/dir_class_methods'
require_relative 'fs/file_class_methods'

require_relative 'vbr'
require_relative 'page'
require_relative 'tables/system'
require_relative 'tables/object'
require_relative 'dirs/root_dir'
require_relative 'trees/object_tree'

module VirtFS::ReFS
  class FS
    include DirClassMethods
    include FileClassMethods

    attr_accessor :mount_point, :device

    def self.match?(device)
      begin
        VBR.new(new(device))
        return true
      rescue => err
        return false
      end
    end

    def initialize(device)
      @device  = device
    end

    def vbr
      @vbr ||= VBR.new(self)
    end

    def pages
      @pages ||= Page.extract_all(self)
    end

    def system_table
      @system_table ||= SystemTable.parse(self)
    end

    def object_table
      @object_table ||= ObjectTable.parse(self)
    end

    def root_dir
      @root_dir ||= RootDir.parse(self)
    end

    def object_tree
      @object_tree ||= ObjectTree.parse(self)
    end

    def thin_interface?
      true
    end

    def umount
      @mount_point = nil
    end
  end # class FS
end # module VirtFS::ReFS
