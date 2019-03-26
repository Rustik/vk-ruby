class VK::FakeBrowser

  def sign_in!(authorization_url, login, password)
    agent.get(authorization_url)

    agent.page.form_with(action: /login.vk.com/){ |form|
      form.email = login
      form.pass  = password
    }.submit
  rescue Exception => ex
    raise VK::AuthentificationError.new({
      error: 'Authentification error',
      description: 'invalid loging or password'
    })
  end

  def authorize!
    if detect_cookie?
      url = agent.page
                 .body
                 .gsub("\n",'')
                 .gsub("  ",'')
                 .match(/.*function allow\(\)\s?\{.*}location.href\s?=\s?[\'\"\s](.+)[\'\"].+\}/)
                 .to_a
                 .last

      agent.get(url)
    else
      raise VK::AuthentificationError.new({
        error: 'Authorization error',
        description: 'invalid loging or password'
      })
    end
  end

  def response
    @response ||= agent.page
                       .uri
                       .fragment
                       .split('&')
                       .map{ |s| s.split '=' }
                       .inject({}){ |a, (k,v)| a[k] = v; a }
  end

  private

  def agent
    @agent ||= Mechanize.new.tap { |m| m.user_agent_alias = 'Mac Safari' }
  end

  def detect_cookie?
    agent.cookies.detect{|cookie| cookie.name == 'remixsid'}
  end
  
end