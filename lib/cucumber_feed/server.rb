module CucumberFeed
  class Server < Ginseng::Sinatra
    include Package

    get '/feed/v1.0/site/:name' do
      site, type = params[:name].split('.')
      type ||= 'rss'
      @renderer = FeedRenderer.create(site)
      @renderer.type = type
      return @renderer.to_s
    rescue LoadError
      raise Ginseng::NotFoundError, "Resource #{request.path} not found."
    end

    def default_renderer_class
      return 'Ginseng::XMLRenderer'
    end

    not_found do
      @renderer = Ginseng::XMLRenderer.new
      @renderer.status = 404
      @renderer.message = "Resource #{request.path} not found."
      return @renderer.to_s
    end

    error do |e|
      e = Ginseng::Error.create(e)
      @renderer = Ginseng::XMLRenderer.new
      @renderer.status = e.status
      @renderer.message = "#{e.class}: #{e.message}"
      Slack.broadcast(e.to_h)
      @logger.error(e.to_h)
      return @renderer.to_s
    end
  end
end
