ROOT_DIR = File.expand_path(__dir__)
$LOAD_PATH.push(File.join(ROOT_DIR, 'lib'))
ENV['BUNDLE_GEMFILE'] ||= File.join(ROOT_DIR, 'Gemfile')
ENV['SSL_CERT_FILE'] ||= File.join(ROOT_DIR, 'cert/cacert.pem')

require 'bundler/setup'

[:start, :stop, :restart].each do |action|
  desc "alias of server:#{action}"
  task action => ["server:#{action}"]
end

namespace :server do
  [:start, :stop, :restart].each do |action|
    desc "#{action} thin"
    task action do
      sh "thin --config config/thin.yaml #{action}"
    end
  end
end
