# Title: Fancybox tag for Jekyll
# Authors: Peter Zotov
#
# Syntax:
# {% fancybox [gallery name] [http[s]:/]/path/to/image [thumbnail size] "caption text" %}
#
# Examples:
# {% fancybox /images/ninja.png "Ninja Attack!"" %}
# {% fancybox pics http://site.com/images/ninja.png "Ninja Attack!" %}
# {% fancybox pics http://site.com/images/ninja.png 150 "Ninja in attack posture" %}

require 'tempfile'
require 'net/http'
require 'micro_magick'

module Jekyll

  class FancyboxTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      data = markup.match(
            /((?<rel>\S+)\s+)?
             ((?<src>(?:https?:\/\/|\/|\S+\/)\S+)\s+)
             ((?<size>\d+)\s+)?
             ("(?<title>.+)"\s+)?/ix)

      thumbnail_size = data[:size] || 250

      thumbnail_folder = File.expand_path "../source/images/thumbnails", File.dirname(__FILE__)
      FileUtils.mkdir_p thumbnail_folder

      thumbnail_digest = Digest::SHA1.hexdigest("#{data[:src]}#{thumbnail_size}")
      thumbnail_name   = "#{thumbnail_digest}#{File.extname(data[:src])}"
      thumbnail_path   = File.join(thumbnail_folder, thumbnail_name)

      begin
        case URI.parse(data[:src])
        when URI::HTTP, URI::HTTPS
          unless File.exists?(thumbnail_path)
            thumbnail_src = Tempfile.new('thumb')
            thumbnail_src.write(Net::HTTP.get(URI(data[:src])))
          end
        when URI::Generic
          source_folder = File.expand_path "../source", File.dirname(__FILE__)
          source_file   = File.join(source_folder, data[:src])

          if !File.exists?(thumbnail_path) ||
             (File.stat(thumbnail_path).mtime < File.stat(source_file).mtime)
            thumbnail_src = File.open(source_file)
          end
        end

        if thumbnail_src
          thumbnail_img = MicroMagick::Image.new(thumbnail_src.path)
          thumbnail_img.resize("#{thumbnail_size}x#{thumbnail_size}").
                        write(thumbnail_path)

          thumbnail_src.close
        end
      rescue => e
        $stderr.puts "#{e.class}: #{e.message}"
      end

      @data = {
        src:   data[:src],
        rel:   data[:rel] || 'fancybox',
        title: (CGI.escapeHTML(data[:title]) if data[:title]),
        thumb: ("/images/thumbnails/#{thumbnail_name}" if File.exists? thumbnail_path) ||
               data[:src],
      }
    end

    def render(context)
      if @data
        %{<a class="fancybox" rel="#{@data[:rel]}" href="#{@data[:src]}" title="#{@data[:title]}">} +
        %{<img src="#{@data[:thumb]}" alt="#{@data[:title]}">} +
        %{</a>}
      else
        %{Error processing input, expected syntax: {% fancybox [gallery name] [http[s]:/]/path/to/image [thumbnail size] "caption text" %}}
      end
    end
  end
end

Liquid::Template.register_tag('fancybox', Jekyll::FancyboxTag)
