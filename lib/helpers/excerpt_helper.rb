module ExcerptHelper
  def excerpt(html)
    html.gsub(/<!--\s*more\s*-->.*/m, '')
  end
end
