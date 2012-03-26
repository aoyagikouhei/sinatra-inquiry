#coding: utf-8
require 'mongoid'

class Link
  SHORT_URL_LENGTH = 6
  LOOP_COUNT = 100
  include Mongoid::Document
  include Mongoid::Timestamps
  field :long_url
  field :short_url

  before_save :make_short

  def self.get_by_long_url(url)
    link = Link.where(long_url: url).first
    if !link
      p "bbb"
      link = Link.new(long_url: url)
      link.save
    end
    link
  end

  def make_short
    return !(short_url.blank?)
    for i in 0..Link::LOOP_COUNT
      temp_url = rands(Link::SHORT_URL_LENGTH)
      count = Link.where(short_url: temp_url).count
      if 0 == count
        self.short_url = temp_url
        break
      end
    end
    raise "loop error" if short_url.blank?
  end

  def rands(length)
    a = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      #+ ["-", "_", ".", "!", "~", "*", "'", "(", ")"]
    return Array.new(length){a[rand(a.size)]}.join
  end
end
