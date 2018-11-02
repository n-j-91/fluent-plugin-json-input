# Load the module that defines common initialization method (Required)
require 'fluent/test'
# Load the module that defines helper methods for testing (Required)
require 'fluent/test/helpers'
# Load the test driver (Required)
require 'fluent/test/driver/output'
# Load the plugin (Required)
require 'fluent/plugin/out_file'

class FileOutputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  def setup
    Fluent::Test.setup   # setup test for Fluentd (Required)
    # setup test for plugin (Optional)
    # ...
  end

  def teardown
    # terminate test for plugin (Optional)
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::FileOutput).configure(conf)
  end

  # configuration related test group
  sub_test_case 'configuration' do
    test 'basic configuration' do
      d = create_driver(basic_configuration)
      assert_equal 'somethig', d.instance.parameter_name
    end
  end

  # Another test group goes here
  sub_test_case 'path' do
    test 'normal' do
      d = create_driver('...')
      d.run(default_tag: 'test') do
        d.feed(event_time, record)
      end
      events = d.events
      assert_equal(1, events.size)
    end
  end
end