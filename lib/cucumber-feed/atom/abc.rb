require 'cucumber-feed/atom'
require 'httparty'

module CucumberFeed
  class AbcAtom < Atom
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
      pattern = %r{\<li.*?\>.*?\<dt\>(.*?)\</dt\>.*?href=\"(.*?)\".*?\>(.*?)\</a\>.*?\</li\>}m
      HTTParty.get(source_url, {headers: headers}).to_s.scan(pattern).each do |matches|
        data.push({
          date: Time.parse(matches[0]),
          title: sanitize(matches[2].force_encoding('utf-8')),
          link: parse_url(matches[1]).to_s,
        })
      end
      return data
    end
  end
end
