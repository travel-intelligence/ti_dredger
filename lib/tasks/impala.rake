namespace :impala do

  desc 'Dump a schema into a JSON (impala_host is mandatory, impala_port defaults to 21000, databases_pattern defaults to \'*\', debug defaults to false)'
  task 'dump', [:impala_host, :impala_port, :databases_pattern, :tables_pattern, :debug] do |_task, args|
    raise 'Need to specify the Impala host to connect to.' if args[:impala_host].nil?
    impala_host = args[:impala_host]
    impala_port = args[:impala_port].nil? ? 21000 : Integer(args[:impala_port])
    databases_pattern = args[:databases_pattern] || '*'
    tables_pattern = args[:tables_pattern] || '*'
    debug = args[:debug] == 'true'
    require 'impala'
    require 'json'
    Impala.connect(impala_host, impala_port) do |impala|
      puts JSON.pretty_generate({
        schemas: impala.query("SHOW DATABASES LIKE \'#{databases_pattern}\'").map do |database_row|
          puts "Dumping #{database_row[:name]}..." if debug
          {
            description: database_row[:name],
            name: database_row[:name].upcase,
            tables: impala.query("SHOW TABLES in #{database_row[:name]} LIKE \'#{tables_pattern}\'").map do |table_row|
              puts "Dumping #{database_row[:name]}.#{table_row[:name]}..." if debug
              {
                name: table_row[:name].upcase,
                columns: impala.query("DESCRIBE #{database_row[:name]}.#{table_row[:name]}").map do |column_row|
                  {
                    name: column_row[:name].upcase,
                    domain: column_row[:type].upcase
                  }
                end
              }
            end
          }
        end
      })
    end
  end

end
