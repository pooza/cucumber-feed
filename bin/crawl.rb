#!/usr/bin/env ruby

path = File.expand_path(__dir__)
path = File.expand_path(File.readlink(path)) while File.symlink?(path)
dir = File.expand_path('..', path)
$LOAD_PATH.unshift(File.join(dir, 'app/lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(dir, 'Gemfile')

require 'bundler/setup'
require 'cucumber_feed'

CucumberFeed::FeedRenderer.all(&:crawl)
