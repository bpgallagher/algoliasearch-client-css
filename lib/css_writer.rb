require 'awesome_print'

# Writes CSS rules that match a given LookupTable
class CSSWriter
  # Given a prefix and an entry, should return the matching CSS rule
  def self.rule(keyword, entry)
    css = []

    entry = entry[0]
    highlight = entry[:highlight]
    content = "#{highlight[:before]}"\
              "___#{highlight[:highlight]}___"\
              "#{highlight[:after]}"

    css << "input[value='#{keyword}' i] + div {"
    css << "background-image: url(#{entry[:record]['image']});"
    css << 'background-color: green;'
    css << '}'
    css << "input[value='#{keyword}' i] + div:before {"
    css << "content: '#{content}'"
    css << '}'

    css.join("\n")
  end

  # Base CSS to be added to the search
  def self.base
    ['.searchbar + div:before { font-weight: bold; }']
  end

  # Get the Cloudinary link to an image
  def self.cloudinary(url)
    'https://res.cloudinary.com/pixelastic-parisweb/image/fetch/' \
    "w_50,h_50,q_90,c_scale,r_max,f_auto,e_grayscale/#{url}"
  end

  # Preload all images by loading the images in the body background
  def self.preload_images(css, records)
    preloaded_images = []
    records.each do |record|
      preloaded_images.push("url(#{record[:image]})")
    end
    css.push('body:before{content:""; display:none; '\
           "background:#{preloaded_images.join(',')}}")
    css
  end
end
