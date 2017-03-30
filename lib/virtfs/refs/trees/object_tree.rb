module VirtFS::ReFS
  class ObjectTree
    attr_accessor :fs

    attr_accessor :map

    def initialize(fs)
      @fs    = fs
      @map ||= {}
    end

    def self.parse
      tree = new
      tree.parse_entries
      tree
    end

    # Depends on Image Pages extraction
    def page
      fs.device.pages.newest_for PAGES[:object_table]
    end

    def parse_entries
      page.attributes.each { |attr|
        obj1 = obj1_from attr
        obj2 = obj2_from attr
        @map[obj1] ||= []
        @map[obj1]  << obj2
      }
    end

    private

    def obj1_from(attr)
      attr.bytes[ADDRESSES[:object_tree_start1]..ADDRESSES[:object_tree_end1]]
    end

    def obj2_from(attr)
      attr.bytes[ADDRESSES[:object_tree_start2]..ADDRESSES[:object_tree_end2]]
    end
  end # class ObjectTree
end # module VirtFS::ReFS
