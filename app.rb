class App < Sinatra::Base

  helpers Asset::Helpers, AppHelper

  # Lookup routes
  def self.r(key); ROUTES[key]; end

  configure do
    register Sinatra::MultiRoute

    use Rack::Session::Cookie, :key => 'rack.session', :path => '/', :secret => 'hCUCXa2ptDNa6SbN6GJMlg=='
    set :root, Dir.pwd
    set :views, File.join(root, 'app', 'views')
    set :assets, File.join(root, 'app', 'assets')
  end

  before do
    v = request.path.split('?')[0]
    @route = ROUTES.keys.find{|k| ROUTES[k].include?(v)}
  end


  # Pages
  get *r(:root) do
    erb :'root/index', :layout => :'layout/layout'
  end

  get *r(:om_oss) do
    erb :'root/om_oss', :layout => :'layout/layout'
  end

  get *r(:design_utvikling) do
    erb :'root/design_utvikling', :layout => :'layout/layout'
  end

  get *r(:seo_marketing) do
    erb :'root/seo_marketing', :layout => :'layout/layout'
  end

  get *r(:hosting_drift) do
    erb :'root/hosting_drift', :layout => :'layout/layout'
  end

  # Contact
  ###########################################################

  get *r(:contact) do
    erb :'root/reservasjon', :layout => :'layout/layout'
  end

  post *r(:contact) do
    # Validate data

    # {"name"=>"asdfwefawef", "email"=>"awefawef", "antall"=>"1", "time"=>"15", "message"=>"awefawef"}
    @errors = Hash.new{|h, k| h[k] = []}

    @errors['name'] << t('error_name') if params['name'].strip.size < 3
    @errors['email'] << t('error_email') if params['email'].strip !~ EMAIL_REGEXP
    @errors['tel'] << t('error_tel') if params['tel'].strip.size < 8
    @errors['emne'] << t('error_guest') if params['antall'].strip.blank?

    if @errors.any?
      erb :'root/reservasjon', :layout => :'layout/layout'
    else

      # Send email
      mail

      # Redirect to confirmation
      redirect("#{u(:confirmation)}?#{to_param}")
    end
  end

  get *r(:confirmation) do
    erb :'root/bekreftelse', :layout => :'layout/layout'
  end

  # Sitemap
  get '/sitemap.xml' do
    content_type :xml
    view('sitemap.xml')
  end

  # Sitemap
  get '/robots.txt' do
    content_type :text
    view('robots.txt')
  end

  get '/test/error' do
    1 / 0
  end

  # Error pages
  #######################################

  error do
    erb :'root/500', :layout => :'layout/layout'
  end

  not_found do
    erb :'root/404', :layout => :'layout/layout'
  end

end
