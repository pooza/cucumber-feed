module CucumberFeed
  class Server < Ginseng::Web::Sinatra
    include Package

    get '/feed/v1.0/site/:name' do
      site, type = params[:name].split('.')
      type ||= 'rss'
      @renderer = FeedRenderer.create(site)
      @renderer.type = type
      return @renderer.to_s
    rescue LoadError
      @renderer = Ginseng::Web::XMLRenderer.new
      @renderer.status = 404
      @renderer.message = "Resource #{request.path} not found."
      return @renderer.to_s
    rescue => e
      @renderer = Ginseng::Web::XMLRenderer.new
      @renderer.status = e.status
      @renderer.message = e.message
      return @renderer.to_s
    end

    private

    def default_renderer_class
      return 'Ginseng::Web::XMLRenderer'.constantize
    end
  end
end
