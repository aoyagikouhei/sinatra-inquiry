#coding: utf-8
require 'sinatra/base'
require 'active_support/core_ext' # for blank?
require './my_mail'

class MyApp < Sinatra::Base
  MAIL_FROM = "noreply@example.com"
  MAIL_TO = "mymail@example.com"
  MAIL_SUBJECT = "[Inquiry] お問い合わせ."
  
  helpers do
    # for escape
    include Rack::Utils; alias_method :h, :escape_html
  end

  def get_value(params, key)
    params[key] ? params[key] : ''
  end

  def parse_params(params)
    @name = get_value(params, 'name')
    @company = get_value(params, 'company')
    @content = get_value(params, 'content')
    @opened = get_value(params, 'opened')
    @confirm = get_value(params, 'confirm')

    # 必須チェック
    !@name.blank? && !@company.blank? && !@content.blank?
  end

  def send_mail
    body = <<-EOS
氏名: #{@name}
企業名: #{@company}
お問い合わせ内容:
#{@content}
    EOS
    mail = MyMail.new({
      subject: MyApp::MAIL_SUBJECT,
      body: body,
      from: MyApp::MAIL_FROM,
      to: MyApp::MAIL_TO
     })
     mail.send_mail
  end

  get '/' do
    redirect '/index.html'
  end

  get '/inquiry/index' do
    parse_params(params)
    erb :index
  end

  post '/inquiry/index' do
    if parse_params(params)
      # 確認
      erb :confirm
    else
      # 修正
      erb :index
    end
  end
  
  post '/inquiry/confirm' do
    if parse_params(params)
      if @confirm == '0'
        # 戻る
        erb :index
      else
        # 送信
        send_mail()
        redirect '/thanks.html'
      end
    else
      # 修正
      erb :index
    end
  end
end
