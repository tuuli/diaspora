#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

begin
  require 'rspec/core'
  require 'rspec/core/rake_task'

  spec_prereq = Rails.root.join('config', 'database.yml').exist? ? "db:test:prepare" : :noop
  task :noop do
  end

  task :stats => "spec:statsetup"

  desc "Run all specs in spec directory (excluding plugin specs)"
  RSpec::Core::RakeTask.new(:spec => spec_prereq)

  desc "Run the specs with rcov"
  Rspec::Core::RakeTask.new(:rcov => spec_prereq) do |t|
    t.rcov = true
    t.rcov_opts = ['-Ispec', '--exclude', 'spec', '--exclude', 'gems']
  end
  namespace :"spec --color" do
    [:requests, :models, :controllers, :views, :helpers, :mailers, :lib].each do |sub|
      desc "Run the code examples in spec/#{sub}"
      RSpec::Core::RakeTask.new(sub => spec_prereq) do |t|
        t.pattern = "./spec/#{sub}/**/*_spec.rb "
      end
    end

    task :statsetup do
      require 'rails/code_statistics'
      ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
      ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
      ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
      ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
      ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
      ::STATS_DIRECTORIES << %w(Mailer\ specs spec/mailers) if File.exist?('spec/mailers')
      ::STATS_DIRECTORIES << %w(Routing\ specs spec/routing) if File.exist?('spec/routing')
      ::STATS_DIRECTORIES << %w(Request\ specs spec/requests) if File.exist?('spec/requests')
      ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
      ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
      ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
      ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
      ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
      ::CodeStatistics::TEST_TYPES << "Mailer specs" if File.exist?('spec/mailer')
      ::CodeStatistics::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
      ::CodeStatistics::TEST_TYPES << "Request specs" if File.exist?('spec/requests')
    end

  end
rescue MissingSourceFile
  module RSpec
    module Core
      class RakeTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

            # ... otherwise, do this:
            raise <<-MSG

            #{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
            #{"*" * 80}
            MSG
          end
        end
      end
    end
  end
end
