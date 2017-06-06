require 'sitemap_generator'

class Sitemap

  def self.ping
    # Escaped URL
    u = CGI.escape("http://www.speria.no/sitemap.xml")

    # ping google
    RestClient.get("http://www.google.com/webmasters/tools/ping?sitemap=#{u}")

    # ping bing
    RestClient.get("http://www.bing.com/ping?sitemap=#{u}")
  end

  def self.write
    base = 'https://www.speria.no'
    SitemapGenerator::Sitemap.default_host = base
    SitemapGenerator::Sitemap.include_root = true
    SitemapGenerator::Sitemap.public_path = 'app/views/root'
    SitemapGenerator::Sitemap.compress = false
    SitemapGenerator::Sitemap.create do
      ROUTES.each do |key, routes|
        next if key == :root
        no, en = routes
        # Options: :changefreq => 'daily', :priority => 0.9, :lastmod
        add(no, :alternate => {:href => "#{base}#{en}", :lang => 'en'})
      end
    end
  end
end
