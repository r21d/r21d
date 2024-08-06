require "sinatra"
require 'json'
require 'open-uri'
set :bind, "0.0.0.0"
port = ENV["PORT"] || "3000"
set :port, port

get '/h/:filename' do
  filename = params[:filename].split(':')
  file_path = File.join("/public", "#{filename[0]}.#{filename[1]}")
  if File.exist?(file_path)
    send_file file_path
  else
    redirect "#{file_path}"
  end
end


get "/" do
  redirect "https://www.youtube.com/channel/UCkfI4g-ztKQZa3bB_QX9gBw?sub_confirmation=1"
end

get "/list" do
  redirect "https://www.youtube.com/watch?v=QblWYWmXOQ4&list=PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr"
end


get "/gowithit" do
  begin
    fl = URI.open('http://' + request.host + '/lyricsbi.json').read  
    fa = URI.open('http://' + request.host + '/ASFA.json').read
    fo = URI.open('http://' + request.host + '/ogjssonfix.json').read

    fld = JSON.parse(fl)
    fad = JSON.parse(fa)
    fod = JSON.parse(fo)
  rescue OpenURI::HTTPError => e
    status 404
    return "File not found: #{e.message}"
  rescue JSON::ParserError => e
    status 500
    return "Invalid JSON data: #{e.message}"
  end

  
  cd = {}
  fod.each do |key, item|
    cd[key] = {
      'id' => item['id'],
      'sub' => item['sub'],
      'obj' => item['obj'],
      'tag' => item['tag'],
      'img' => item['img'],
      'txt' => item['txt']
    }
  end

fld.each do |key, item|
    if combined_data.key?(key) && combined_data[key].is_a?(Hash)  # Check key existence and type
      combined_data[key].merge!(item)
    else
      # Handle the case where the key is not in combined_data or not a hash 
      puts "Warning: Key '#{key}' not found in combined_data or not a hash."
      # You can add logic here to create the key with an empty hash or take other actions.
      combined_data[key] ||= {}  # Example: create the key with an empty hash
      combined_data[key].merge!(item)
    end
  end  fad.each do |key, item|
    if cd.key?(key)  
      cd[key]['sum'] = item['sum'] if item.key?('sum')
      cd[key]['rad'] = item['rad'] if item.key?('rad')
    else
      
      puts "Warning: Key '#{key}' not found in primary data."
    end
  end

  fld.each do |key, item|
    cd[key] =   cd.fetch(key, {}).merge(item)  
  end

  erb :gowithit, locals: { cd: cd.to_json }
end