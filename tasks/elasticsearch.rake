# Elasticsearch index management.

require 'bundler/setup'
require 'elasticsearch'
require 'json'

namespace :elasticsearch do

  # options:
  #   log - show HTTP requests and responses
  task client: [:environment] do
    log = ENV['log'] || false
    endpoint = "http://#{$config['elasticsearch']['host']}:#{$config['elasticsearch']['port']}"
    index = $config['elasticsearch']['index']
    $elasticsearch_client = Elasticsearch::Client.new url: endpoint, log: log, index: index
  end

  # options:
  #   only - only one mapping, please
  #   force - delete the mapping first (okay...)
  desc "Initialize ES mappings"
  task init: [:environment, :client] do
    single = ENV['only'] || nil
    force = ENV['force'] || false

    mappings = single ? [single] : Dir.glob('config/mappings/*.json').map {|dir| File.basename dir, File.extname(dir)}

    index = $config['elasticsearch']['index']
    index_settings = JSON.parse(File.read('config/index.json'))

    if force
      if $elasticsearch_client.indices.exists index: index
        $elasticsearch_client.indices.delete index: index

        puts "Deleted index"
      end
      $elasticsearch_client.indices.create index: index
      $elasticsearch_client.cluster.health wait_for_status: 'green'

      puts "Created index"
    else
      if $elasticsearch_client.indices.exists index: index
        puts "Index already exists"
      else
        $elasticsearch_client.indices.create index: index
        $elasticsearch_client.cluster.health wait_for_status: 'green'

        puts "Created index"
      end
    end

    $elasticsearch_client.indices.close index: index

    puts "Closed index"

    begin
      $elasticsearch_client.indices.put_settings index: index, body: index_settings

      puts "Configured index"
    ensure
      $elasticsearch_client.indices.open index: index

      puts "Opened index"
    end

    mappings.each do |mapping|
      mapping_raw = File.read("config/mappings/#{mapping}.json")
      mapping_config = JSON.parse(mapping_raw)
      $elasticsearch_client.indices.put_mapping index: index, type: mapping, body: mapping_config

      puts "Created #{mapping}"
    end
  end

  namespace :index do
    task list: [:environment, :client] do
      for index, aliases in $elasticsearch_client.indices.get_aliases do
        if !(index.start_with? ".") then
          puts "#{index}, #{aliases['aliases'].length} aliases"
          for alias_, options in aliases['aliases'] do
            if options.length > 0 then
              puts "  #{alias_}: #{options}"
            else
              puts "  #{alias_}"
            end
          end
        end
      end
    end
  end
end
