require 'fileutils'

module VirtFS::ReFS
  module FSDir
    class DirEntry
      attr_accessor :prefix
      attr_accessor :name
      attr_accessor :metadata

      # metadata record
      attr_accessor :record

      attr_accessor :fs
      attr_accessor :virtfs_dir

      def initialize(fs, args={})
        @fs       = fs
        @prefix   = args[:prefix]
        @name     = args[:name]
        @metadata = args[:metadata]
        @record   = args[:record]
        @virtfs_dir = Dir.new(self)
      end

      def fullname
        "#{prefix}\\#{name}"
      end

      def disk_offset
        image.offset + dir.record.attribute.pos
      end
    end # class DirEntry
  end # module FSDir
end # module VirtFS::ReFS
