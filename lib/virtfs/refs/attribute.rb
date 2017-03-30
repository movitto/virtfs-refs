module VirtFS::ReFS
  class Attribute
    attr_accessor :fs
    attr_accessor :pos
    attr_accessor :bytes

    def initialize(fs, args={})
      @fs    = fs
      @pos   = args[:pos]
      @bytes = args[:bytes]
    end

    def empty?
      bytes.nil? || bytes.empty?
    end

    def self.read(fs)
      pos = fs.device.seek_pos
      packed = fs.device.read(4)
      return new if packed.nil?
      attr_len = packed.unpack('L').first
      return new(fs) if attr_len == 0

      fs.device.seek pos
      value = fs.device.read(attr_len)
      new(fs, :pos => pos, :bytes => value)
    end

    def unpack(format)
      bytes.unpack(format)
    end

    def [](key)
      return bytes[key]
    end

    def to_s
      bytes.collect { |a| a.to_s(16) }.join(' ')
    end
  end # class Attribute
end # module VirtFS::ReFS
