require 'open-uri'
require 'cucumber-feed/atom'

module CucumberFeed
  class AbcAtom < Atom
    def initialize
      super
      @config = Config.new
    end

    def channel_title
      return 'ABC毎日放送 プリキュア公式'
    end

    def url
      return 'https://www.asahi.co.jp/precure/'
    end

    def source_url
      return 'https://www.asahi.co.jp/precure/hugtto/js/inc/news.js'
    end

    protected
    def entries
      data = []
      pattern = /\<li.*?\>.*?\<dt\>(.*?)\<\/dt\>.*?href=\"(.*?)\".*?\>(.*?)\<\/a\>.*?\<\/li\>/m
      open(source_url).read.scan(pattern).each do |matches|
        data.push({
          date: Time.parse(matches[0]),
          title: matches[2].force_encoding('utf-8'),
          link: parse_url(matches[1]).to_s,
        })
      end
      return data
    rescue
      return [] # 当面、例外が発生したら空配列を返す
    end
  end
end
