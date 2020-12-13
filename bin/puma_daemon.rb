#!/usr/bin/env ruby
dir = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(File.join(dir, 'app/lib'))
ENV['BUNDLE_GEMFILE'] = File.join(dir, 'Gemfile')

require 'cucumber_feed'
ENV['RACK_ENV'] ||= Mulukhiya::Environment.type
CucumberFeed::PumaDaemon.spawn!
