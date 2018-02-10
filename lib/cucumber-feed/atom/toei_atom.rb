require 'cucumber-feed/atom'

module CucumberFeed
  class ToeiAtom < Atom
    def initialize
      super
      @config = Config.new
    end

    def channel_title
      return '東映アニメーション プリキュア公式'
    end

    def url
      return 'http://www.toei-anim.co.jp/tv/precure/'
    end

    protected
    def entries
      data = []
      source.xpath('//div[@class="jspPane"]//dl').each do |node|
        begin
          data.push({
            link: URI.parse(url + node.search('dd/a').child.attribute('href')).to_s,
            title: node.search('dd/a').inner_html,
            date: Time.parse(node.search('dd/span').inner_html),
          })
        rescue => e
          # 当面、例外が発生したら捨てる
        end
      end
      return data
    end
  end
end
