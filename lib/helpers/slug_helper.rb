module SlugHelper
  def as_slug(text)
    text.downcase.gsub(/[^a-z0-9]/, '-')
  end
end
