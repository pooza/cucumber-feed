require 'cucumber-feed/atom'
require 'nokogiri'
require 'time'

module CucumberFeed
  class ToeiAtom < Atom
    def channel_title
      return '東映アニメーション プリキュア公式'
    end

    def url
      return 'http://www.toei-anim.co.jp/tv/precure/'
    end

    protected

    def source
      unless @sourcce
        html = URI.parse(source_url).open(headers, &:read)
        @source = Nokogiri::HTML.parse(html.force_encoding('utf-8'), nil, 'utf-8')
      end
      return @source
    end

    def entries
      data = []
      source.xpath('//ul[@class="news_list"]//a').each do |node|
        title = node.search('p').inner_text.split(/\s+/)
        title.shift
        title.shift
        data.push({
          link: parse_url(node.attribute('href')).to_s,
          title: title.join(' '),
          date: Time.parse(node.search('span[@class="day"]').inner_text),
        })
      end
      return data
    end
  end
end
