module VirtFS::ReFS
  class VBR
    attr_accessor :fs, :bytes_per_sector, :sectors_per_cluster

    def initialize(fs)
      raise "nil fs" if fs.nil?
      @fs = fs

      fs.device.seek(0)
      @signature = fs.device.read(FS_SIGNATURE.size).unpack('C*')

      fs.device.seek(ADDRESSES[:bytes_per_sector])
      @bytes_per_sector = fs.device.read(4).unpack('L').first

      fs.device.seek(ADDRESSES[:sectors_per_cluster])
      @sectors_per_cluster = fs.device.read(4).unpack('L').first

      validate!
    end

    def device
      @fs.devive
    end

    def cluster_size
      @cluster_size ||= bytes_per_sector * sectors_per_cluster
    end

    def validate!
      raise "invalid signature" if @signature != FS_SIGNATURE
    end
  end # class VBR
end # module VirtFS::ReFS
