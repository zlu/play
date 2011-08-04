require 'bundler'
Bundler::GemHelper.install_tasks

require 'bundler/setup'

task :default => [:test]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test) do |spec|
  spec.skip_bundler = true
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = '--color'
end

namespace :tropo do
  task :update do
    require 'tmpdir'
    
    prism_home = RUBY_PLATFORM.match(/darwin/)? '/Applications/prism' : '/opt/voxeo/prism'

    download_dir = File.join(Dir.tmpdir, 'tropo2')
    
    system "mkdir -p #{download_dir}"
    
    puts "* Downloading latest successful build of Tropo2"
    system "cd #{download_dir} && wget -q http://hudson.voxeolabs.com/hudson/job/Tropo%202/lastSuccessfulBuild/artifact/*zip*/archive.zip"
    puts "* Downloaded to #{File.join(download_dir, 'archive.zip')}"
    
    puts "* Unzipping tropo2"
    system "cd #{download_dir} && unzip archive.zip"
    
    puts "* Updating tropo2"
    system "cd #{download_dir} && mv archive/tropo-war/target/tropo-*.war #{prism_home}/apps/tropo2.war"
    
    puts "* Cleaning up"
    system "cd #{download_dir} && rm archive.zip"
    system "cd #{download_dir} && rm -rf archive"
    
    puts "* Restarting Prism server ..."
    system "#{prism_home}/bin/prism restart"
    puts "* Prism server restarted."
  end
end