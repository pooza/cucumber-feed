require 'json'
require 'xmlsimple'
require 'uri'
require 'cucumber-feed/atom'

module CucumberFeed
  class ToeiAtom < Atom
    def channel_title
      return '東映アニメーション プリキュア公式'
    end

    def url
      return 'http://www.toei-anim.co.jp/tv/precure/'
    end

    def source_url
      return 'http://www.toei-anim.co.jp/tv/precure/news.json'
    end

    protected
    def entries
      data = []
      JSON.parse(open(source_url, headers).read)['news'].each do |entry|
        element = XmlSimple.xml_in(entry['description'].gsub('&', '&amp;'))
        data.push({
          link: parse_url(element['href']).to_s,
          title: element['content'],
          date: Time.parse(entry['date']),
        })
      end
      return data
    end
  end
end
