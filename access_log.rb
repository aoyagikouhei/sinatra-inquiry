#coding: utf-8
require 'rack'

module Rack
  class AccessLog
    def initialize(app, opts = {})
      @app = app
      @collection = opts[:collection] ? opts[:collection] : Mongo::Connection.new()['test']['access']
      @excludes = opts[:excludes] ? opts[:excludes] : []
      @mask = opts[:mask] ? opts[:mask] : 'xxx'
      @safe = opts[:safe] ? opts[:safe] : false
    end
  
    def call(env)
      req = Rack::Request.new(env)
      p = req.params()
      @excludes.each do |it|
        if p[it]
          p[it] = @mask
        end
      end
      params = {
        ip: req.ip(),
        uri: req.path(),
        ua: req.user_agent(),
        p: p,
        ins: Time.now
      };
      @collection.insert(params, {safe: @safe})
      res = @app.call(env)
      res
    end
  end
end
