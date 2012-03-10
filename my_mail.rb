# coding: utf-8
require 'mail'

class MyMail
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 25
  DEFAULT_FROM = ''
  DEFAULT_SUBJECT = ''
  DEFAULT_BODY = ''
  DEFAULT_TO = ''
  
  def initialize(params={})
    @host = params[:host] ? params[:host] : MyMail::DEFAULT_HOST
    @port = params[:port] ? params[:port] : MyMail::DEFAULT_PORT
    @from = params[:from] ? params[:from] : MyMail::DEFAULT_FROM
    @subject = params[:subject] ? params[:subject] : MyMail::DEFAULT_SUBJECT
    @body = params[:body] ? params[:body] : MyMail::DEFAULT_BODY
    @to = params[:to] ? params[:to] : MyMail::DEFAULT_TO

    ::Mail.defaults do
      delivery_method :smtp, {
        :enable_starttls_auto => false,
        :address => @host,
        :port => @port,
      }
    end
  end

  def send_mail(params={})
    from = params[:from] ? params[:from] : @from
    to = params[:to] ? params[:to] : @to
    body = params[:body] ? params[:body] : @body
    subject = params[:subject] ? params[:subject] : @subject

    mail = ::Mail.new do
      from    from
      to      to
      subject subject
      body    body
    end

    mail.delivery_method :sendmail
    mail.deliver
  end
end

