# Logs the time a feature files takes to run to help in balancing a distrubuted build
#
# cucumber -r Hobson::Formatters::Cucumber
#
require 'cucumber'
require 'cucumber/formatter/io'
require File.expand_path('../now', __FILE__)

module Hobson
  module Formatters
    class Cucumber

      include ::Cucumber::Formatter::Io

      def initialize step_mother, path_or_io, options
        @io = ensure_io(path_or_io, "hobson_status")
      end

      def before_feature_element feature_element
        @started_at = Hobson::Formatters.now.to_f
      end

      def scenario_name keyword, name, file_colon_line, source_indent
        @scenario_name = name
        @io.puts "TEST:scenario:#{@scenario_name}:START:#{@started_at}"
        @io.flush
      end

      def after_feature_element feature_element
        ended_at = Hobson::Formatters.now.to_f
        status = feature_element.failed? ? 'FAIL' : 'PASS'
        @io.puts "TEST:scenario:#{@scenario_name}:COMPLETE:#{ended_at}:#{status}"
        @io.flush
        @scenario_name = @started_at = nil
      end

    end
  end
end
