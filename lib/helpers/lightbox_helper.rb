module LightboxHelper
  def lightbox(filename, gallery: nil, title: nil)
    thumbnail = @items[filename].path(rep: :thumbnail)
    unless gallery.nil?
      rel_attr = %Q{ rel="gal-#{gallery}"}
    end
    unless title.nil?
      title_attr = %Q{ title="#{title}"}
    end
    %Q{<a class="fancybox"#{rel_attr} href="#{filename}"#{title_attr}>} +
      %Q{<img src="#{thumbnail}"#{title_attr}>} +
    %Q{</a>}
  end
end
