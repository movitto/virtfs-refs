module VirtFS::ReFS
  class FS
    module FileClassMethods
      def file_atime(p)
      end

      def file_blockdev?(p)
      end

      def file_chardev?(p)
      end

      def file_chmod(permission, p)
        raise "writes not supported"
      end

      def file_chown(owner, group, p)
        raise "writes not supported"
      end

      def file_ctime(p)
      end

      def file_delete(p)
      end

      def file_directory?(p)
        f = get_file(p)
        !f.nil? && f.dir?
      end

      def file_executable?(p)
      end

      def file_executable_real?(p)
      end

      def file_exist?(p)
        !get_file(p).nil?
      end

      def file_file?(p)
        f = get_file(p)
        !f.nil? && f.file?
      end

      def file_ftype(p)
      end

      def file_grpowned?(p)
      end

      def file_identical?(p1, p2)
      end

      def file_lchmod(permission, p)
      end

      def file_lchown(owner, group, p)
      end

      def file_link(p1, p2)
      end

      def file_lstat(p)
      end

      def file_mtime(p)
      end

      def file_owned?(p)
      end

      def file_pipe?(p)
      end

      def file_readable?(p)
      end

      def file_readable_real?(p)
      end

      def file_readlink(p)
      end

      def file_rename(p1, p2)
      end

      def file_setgid?(p)
      end

      def file_setuid?(p)
      end

      def file_size(p)
      end

      def file_socket?(p)
      end

      def file_stat(p)
      end

      def file_sticky?(p)
      end

      def file_symlink(oname, p)
      end

      def file_symlink?(p)
        get_file(p).symlink?
      end

      def file_truncate(p, len)
      end

      def file_utime(atime, mtime, p)
      end

      def file_world_readable?(p)
      end

      def file_world_writable?(p)
      end

      def file_writable?(p)
      end

      def file_writable_real?(p)
      end

      def file_new(f, parsed_args, _open_path, _cwd)
        file = get_file(f)
        raise Errno::ENOENT, "No such file or directory" if file.nil?
        File.new(file, superblock)
      end

      private

      def get_file(p)
        p = p.gsub("/", "\\")
        dir, fname = VfsRealFile.split(p)
        fname = '.' if fname == '/' || fname == '\\'
        return get_dir(dir).find_entry(fname)
      end
    end # module FileClassMethods
  end # class FS
end # module VirtFS::ReFS

