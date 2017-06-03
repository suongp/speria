module AppHelper

  # Lookup translation
  def t(key, admin = false)
    q = LANG[current_lang][key]
    q = %{<span class='editable' data-key="#{key}"> #{q} </span>} if admin and session[:admin]
    q
  end

  # Lookup URL
  def u(key, lang = current_lang)
    ROUTES[key][lang == 'en' ? 1 : 0] rescue ''
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def error(key)
    if @errors and @errors[key.to_s].present?
      %{<div class="error-message">#{@errors[key.to_s].join(', ').capitalize}</div>}
    end
  end

  # Get current language
  def current_lang
    @current_lang ||= (request.path =~ /^\/en/ ? 'en' : 'no')
  end

  # Output params as HTTP parameters
  def to_param(t = params.dup)
    t.delete('splat');t.delete('captures')
    return '' if t.empty?
    t.to_a.map{|r| "#{r[0]}=#{URI.escape(r[1])}"}.join('&')
  end

  # Output ? if params
  def q
    params.any? ? '?' : ''
  end

  # Load view
  def view(name, path = 'root')
    File.read(File.join(Dir.pwd, 'app', 'views', path, name)) rescue 404
  end

  # Send email
  def mail(background = false)
    # Don't deliver if it's disabled
    return false if MODE == 'test'

    # Options for email
    options = {
      :to => 'post@speria.no', :from => 'Kontaktskjema <post@speria.no>',
      'h:Reply-To' => "#{params['name']} <#{params['email']}>",
      :subject => SUBJECTS[params['subject'].to_sym], :text => erb(:'mail/text'), :html => erb(:'mail/html', :layout => :'layout/mail')
    }

    # Set up mailgun
    url = "https://api:#{SETTINGS[:mailgun_api_key]}@api.mailgun.net/v3/speria.no/messages"

    if(background)
      # Pass job to background processing
      EmailJob.new.async.perform(url, options)
    else
      # Sending without background queue
      RestClient.post(url, options)
    end
  end

  # Check if file is valid yaml
  def valid_yaml?(yml)
    !!YAML.load(yaml) rescue false
  end

  def protected!
    if MODE == 'development'
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [SETTINGS[:http_user], SETTINGS[:http_passwd]]
  end

end
