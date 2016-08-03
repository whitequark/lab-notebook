include Nanoc::Helpers::HTMLEscape

module CodeHelper
  def highlight_code(language, filename=nil, &block)
    if block.nil?
      code = @items[filename].compiled_content(snapshot: :raw)
    else
      code = capture(&block)
    end

    result = %Q{<pre><code class="language-#{language}">#{html_escape(code)}</code></pre>}
    unless filename.nil?
      basename = File.basename(filename)
      if block.nil?
        link   = link_to "download", filename
        result = %Q{<figure><figcaption>#{basename} (#{link})</figcaption>#{result}</figure>}
      else
        result = %Q{<figure><figcaption>#{basename}</figcaption>#{result}</figure>}
      end
    end

    if block.nil?
      result
    else
      erbout = eval('_erbout', block.binding)
      erbout << result
      ''
    end
  end
end
