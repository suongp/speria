require 'sitemap_generator'

class Sitemap

  def self.ping
    # Escaped URL
    u = CGI.escape("http://.no/sitemap.xml")

    # ping google
    RestClient.get("http://www.google.com/webmasters/tools/ping?sitemap=#{u}")

    # ping bing
    RestClient.get("http://www.bing.com/ping?sitemap=#{u}")
  end

  def self.write
    base = 'https://speria.no'
    SitemapGenerator::Sitemap.default_host = base
    SitemapGenerator::Sitemap.include_root = true
    SitemapGenerator::Sitemap.public_path = 'app/views/root'
    SitemapGenerator::Sitemap.compress = false
    SitemapGenerator::Sitemap.create do
      ROUTES.each do |key, routes|
        no, en = routes
        # Options: :changefreq => 'daily', :priority => 0.9, :lastmod
        # NOT IN USE: add(no, :alternate => {:href => "#{base}#{en}", :lang => 'en'})
        add(no)
      end
    end
  end
end