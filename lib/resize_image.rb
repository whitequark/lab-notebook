require 'micro_magick'

class ResizeImage < Nanoc::Filter
  identifier :resize_image
  type       :binary

  def run(filename, params = {})
    cache_dir = File.join(File.dirname(__FILE__), "..", "cache")
    FileUtils.mkdir_p(cache_dir)

    thumbnail_path = File.join(cache_dir, Digest::SHA1.hexdigest("thumbnail:" + filename))
    if !File.exists?(thumbnail_path)
      MicroMagick::Image.new(filename).
        resize("#{params[:size]}x#{params[:size]}").
        write(thumbnail_path)
    end

    FileUtils.cp(thumbnail_path, output_filename)
  end
end
