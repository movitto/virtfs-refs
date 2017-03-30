require 'fileutils'
require 'virtfs/refs/collections/dirs'
require 'virtfs/refs/collections/files'
require 'virtfs/refs/attribute'
require 'virtfs/refs/fs_dir/file_entry'
require 'virtfs/refs/fs_dir/dir_entry'

module VirtFS::ReFS
  module FSDir
    class DirBase
      attr_accessor :fs
      attr_accessor :dirs
      attr_accessor :files

      def initialize(fs)
        @fs = fs
      end

      def parse_dir_obj(object_id, prefix)
        object_table   = fs.object_table
        @dirs        ||= Dirs.new
        @files       ||= Files.new

        page_id      = object_table.pages[object_id]
        page_address = page_id * PAGE_SIZE
        parse_dir_page page_address, prefix
      end

      def parse_dir_page(page_address, prefix)
        # skip container/placeholder attribute
        fs.device.seek(page_address + ADDRESSES[:first_attr])
        Attribute.read(fs)

        # start of table attr, pull out table length, type
        table_header_attr   = Attribute.read(fs)
        table_header_dwords = table_header_attr.unpack("L*")
        header_len          = table_header_dwords[0]
        table_len           = table_header_dwords[1]
        remaining_len       = table_len - header_len
        table_type          = table_header_dwords[3]

        until remaining_len == 0
          orig_pos = fs.device.seek_pos
          record   = Record.read(fs)

          # need to keep track of position locally as we
          # recursively call parse_dir via helpers
          pos = fs.device.seek_pos

          if table_type == DIR_TREE
            parse_dir_branch record, prefix

          else #if table_type == DIR_LIST
            record = filter_dir_record(record)
            pos = fs.device.seek_pos
            parse_dir_record record, prefix

          end

          fs.device.seek pos
          remaining_len -= (fs.device.seek_pos - orig_pos)
        end
      end

      def filter_dir_record(record)
        # '4' seems to indicate a historical record or similar,
        # records w/ flags '0' or '8' are what we want
        record.flags == 4 ? filter_dir_record(Record.read(fs)) : record
      end

      def parse_dir_branch(record, prefix)
        key          = record.key
        value        = record.value
        flags        = record.flags

        value_dwords = value.unpack('L*')
        value_qwords = value.unpack('Q*')

        page_id      = value_dwords[0]
        page_address = page_id * PAGE_SIZE
        checksum     = value_qwords[2]

        parse_dir_page page_address, prefix unless checksum == 0 || flags == 4
      end

      def parse_dir_record(record, prefix)
        key        = record.key
        value      = record.value

        key_bytes  = key.unpack('C*')
        key_dwords = key.unpack('L*')
        entry_type = key_dwords.first

        if entry_type == DIR_ENTRY
          dir_name = key_bytes[4..-1].reject{ |n| n == 0 }.pack('C*')
          dir_obj = value.unpack('C*')[0...8]
          dirs << DirEntry.new(fs,
                               :prefix   => prefix,
                               :name     => dir_name,
                               :metadata => dir_obj,
                               :record   => record)

          dir_obj = [0, 0, 0, 0, 0, 0, 0, 0].concat(dir_obj)
          parse_dir_obj(dir_obj, "#{prefix}\\#{dir_name}")

        elsif entry_type == FILE_ENTRY
          filename = key_bytes[4..-1]
          filename.delete(0)
          filename = filename.reject{ |n| n == 0 }.pack('C*')

          files <<  FileEntry.new(fs,
                                  :prefix   => prefix,
                                  :name     => filename,
                                  :metadata => value,
                                  :record   => record)
        end
      end
    end # class DirBase
  end # module FSDir
end # module VirtFS::ReFS
