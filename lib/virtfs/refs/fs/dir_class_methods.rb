module VirtFS::ReFS
  class FS
    module DirClassMethods
      def dir_delete(p)
        raise "writes not supported"
      end

      def dir_entries(p)
        dir = get_dir(p)
        return nil if dir.nil?
        dir.glob_names
      end

      def dir_exist?(p)
        begin
          !get_dir(p).nil?
        rescue
          false
        end
      end

      def dir_foreach(p, &block)
        r = get_dir(p).try(:glob_names)
                      .try(:each, &block)
        block.nil? ? r : nil
      end

      def dir_mkdir(p, permissions)
        raise "writes not supported"
      end

      def dir_new(fs_rel_path, hash_args, _open_path, _cwd)
        get_dir(fs_rel_path)
      end

      private

      def get_dir(p)
        p = p.gsub("/", "\\")
        return root_dir.virtfs_dir if p == '.' || p == '/' || p == '\\'
        dir = root_dir.find_entry(p)

        dir.is_a?(Dir) ? dir : nil
      end
    end # module DirClassMethods
  end # class FS
end # module VirtFS::ReFS
