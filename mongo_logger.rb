#coding: utf-8
require 'logger'

class MongoLogger
  DEFAULT_LEVEL = Logger::Severity::INFO

  def initialize(opts={})
    @level = opts[:level] ? opts[:level] : MongoLogger::DEFAULT_LEVEL
    @collection = opts[:collection] ? opts[:collection] : nil
    @safe = opts[:safe] ? opts[:safe] : false
  end

  def log(level, msg=nil, &block)
    return true if level < @level
    msg = yield if block_given?
    @collection.insert({i: Time.now, l: level, m: msg}, {safe: @safe})
    true
  end

  def fatal(msg=nil, &block)
    log(Logger::Severity::FATAL, msg, &block)
  end

  def error(msg=nil, &block)
    log(Logger::Severity::ERROR, msg, &block)
  end

  def warn(msg=nil, &block)
    log(Logger::Severity::WARN, msg, &block)
  end

  def info(msg=nil, &block)
    log(Logger::Severity::INFO, msg, &block)
  end
  
  def debug(msg=nil, &block)
    log(Logger::Severity::DEBUG, msg, &block)
  end
end
