module VirtFS::ReFS
  class SystemTable
    attr_accessor :fs, :pages

    def initialize(fs)
      @fs    = fs
      @pages = []
    end

    def self.parse(fs)
      table = new(fs)
      table.parse_pages
      table
    end

    def self.first_page_address
      PAGES[:first] * PAGE_SIZE
    end

    def parse_pages
      fs.device.seek(self.class.first_page_address + ADDRESSES[:system_table_page])
      system_table_page    = fs.device.read(8).unpack('Q').first
      system_table_address = system_table_page * PAGE_SIZE

      fs.device.seek(system_table_address + ADDRESSES[:system_pages])
      num_system_pages = fs.device.read(4).unpack('L').first

      0.upto(num_system_pages-1) do
        system_page_offset = fs.device.read(4).unpack('L').first
        pos = fs.device.seek_pos

        fs.device.seek(system_table_address + system_page_offset)
        system_page = fs.device.read(8).unpack('Q').first
        @pages << system_page

        fs.device.seek(pos)
      end
    end
  end # class SystemTable
end # module VirtFS::ReFS
