require_relative 'collections/pages'

module VirtFS::ReFS
  class Page
    attr_accessor :fs
    attr_accessor :id
    attr_accessor :contents

    attr_accessor :sequence
    attr_accessor :virtual_page_number

    attr_accessor :attributes

    attr_accessor :object_id
    attr_accessor :entries

    def initialize
      @attributes ||= []
    end

    def self.extract_all(fs)
      page_id     = PAGES[:first]
      pages       = Pages.new

      fs.device.seek(page_id * PAGE_SIZE)
      while contents = fs.device.read(PAGE_SIZE)
        # only pull out metadata pages currently
        extracted_id   = id_from_contents(contents)
        is_metadata    = extracted_id == page_id
        pages[page_id] = Page.parse(fs, page_id, contents) if is_metadata
        page_id       += 1
      end

      pages
    end

    def self.id_from_contents(contents)
      contents.unpack('S').first
    end

    def offset
      id * PAGE_SIZE
    end

    def attr_start
      offset + ADDRESSES[:first_attr]
    end

    def root?
      virtual_page_number == PAGES[:root]
    end

    def object_table?
      virtual_page_number == PAGES[:object_table]
    end

    def self.parse(fs, id, contents)
      store_pos

      page          = new
      page.fs       = fs
      page.id       = id
      page.contents = contents

      fs.device.seek(page.offset + ADDRESSES[:page_sequence])
      page.sequence = fs.device.read(4).unpack('L').first

      fs.device.seek(page.offset + ADDRESSES[:virtual_page_number])
      page.virtual_page_number = fs.device.read(4).unpack('L').first

      unless page.root? || page.object_table?
        # TODO:
        #page.parse_attributes
        #page.parse_metadata
      end

      restore_pos

      page
    end

    def has_attributes?
      !@attributes.nil? && !@attributes.empty?
    end

    def parse_attributes
      fs.device.seek(attr_start)
      while true
        attr = Attribute.read(fs)
        break if attr.empty?
        @attributes << attr
      end
    end

    def parse_metadata
      @object_id = @attributes.first.unpack("C*")[ADDRESSES[:object_id]]
      @entries   = @attributes.first.unpack("C*")[ADDRESSES[:num_objects]]
    end
  end # class Page
end # module VirtFS::ReFS
