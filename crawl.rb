#!/usr/bin/env ruby

ROOT_DIR = File.expand_path(__dir__)
$LOAD_PATH.push(File.join(ROOT_DIR, 'lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(ROOT_DIR, 'Gemfile')
ENV['SSL_CERT_FILE'] ||= File.join(ROOT_DIR, 'cert/cacert.pem')

require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext'
require 'cucumber-feed/atom'

CucumberFeed::Atom.all do |atom|
  begin
    atom.crawl
  end
end
