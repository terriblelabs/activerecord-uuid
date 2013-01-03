module ActiveRecord
  class SQLCounter
    IGNORED_SQL = [/^PRAGMA /, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/,
      /SELECT name\s+FROM sqlite_master\s+WHERE type = 'table' AND NOT name = 'sqlite_sequence'/]

    def initialize
      $queries_executed = []
    end

    def call(name, start, finish, message_id, values)
      sql = values[:sql]

      unless 'CACHE' == values[:name]
        $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
      end
    end
  end
  ActiveSupport::Notifications.subscribe('sql.active_record', SQLCounter.new)
end

#Dir[File.expand_path('../helpers/*.rb', __FILE__)].each do |f|
  #require f
#end
require File.expand_path('../support/schema.rb', __FILE__)
require File.expand_path('../support/models.rb', __FILE__)

RSpec.configure do |config|
  config.before(:suite) do
    puts '=' * 80
    puts "Running specs against Active Record #{ActiveRecord::VERSION::STRING} and ARel #{Arel::VERSION}..."
    puts '=' * 80
    Models.make
  end
end

RSpec::Matchers.define :be_like do |expected|
  match do |actual|
    actual.gsub(/^\s+|\s+$/, '').gsub(/\s+/, ' ').strip ==
      expected.gsub(/^\s+|\s+$/, '').gsub(/\s+/, ' ').strip
  end
end