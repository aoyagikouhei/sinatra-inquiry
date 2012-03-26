#coding: utf-8
require 'sinatra/base'
require 'active_support/core_ext' # for blank?
require 'rack/session/mongo'
require './models/link'
require 'json'
require './mongo_logger'

class MyApp < Sinatra::Base
  SHORT_HOST = "http://short.krsgw.net"
  configure do
    conn = Mongo::Connection.new('localhost', 27017)
    use Rack::Session::Mongo, {
      connection: conn,
      db: 'krsgw',
      expire_after: 24 * 3600
    }
    set :haml, {format: :html5, escape_html: true}
 
    Mongoid.configure do |conf|
      conf.master = conn['krsgw']
    end
    syslog = conn['krsgw']['syslog']
    set :logger, MongoLogger.new({collection: syslog, safe: true})

    set :syslog, syslog
  end

  def logger
    settings.logger
  end

  helpers do
    # for escape
    include Rack::Utils; alias_method :h, :escape_html
    def make_time(src)
      src.getlocal.strftime('%Y-%m-%d %H:%M:%S')
    end
  end

  get '/short' do
    content_type :json
    long_url = params["longUrl"]
    if long_url.blank?
      status 500
      return {status_code: 500, status_txt: "MISSING_ARG_LONGURL"}.to_json
    end
    link = Link.get_by_long_url(long_url)
    p link
    {}.to_json
    #{status_code: 200, status_txt: "OK", data: {url: MyApp::SHORT_HOST + "/" + link.short_url}}.to_json
  end

  get '/log' do
    syslog = settings.syslog
    @cpp = params[:cpp] ? params[:cpp].to_i : 10
    @page = params[:page] ? params[:page].to_i : 1
    @count = syslog.count()
    @list = syslog.find({}, {limit: @cpp, sort: [:i, :desc], skip: (@page - 1) * @cpp})
    haml :log
  end

  get '*' do
    logger.info(request.path_info)
    request.path_info
  end
end
