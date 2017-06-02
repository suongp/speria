require './config/boot.rb'
require './app.rb'
app = Rack::Builder.new do
  use Rack::Cache if MODE != 'development'

  # Include the Asset middleware router
  use Asset::Router

  # Use this setup to have files served from /assets/images and /assets/fonts
  use Rack::Static, :urls => ['/images', '/fonts'], :root => App.assets,
    :header_rules => [
      [:all, {'Cache-Control' => 'public, max-age=31536000'}],
      [:fonts, {'Access-Control-Allow-Origin' => '*'}]
    ]

  use Fuprint::Request if MODE == 'development'

  run App.new
end
run app