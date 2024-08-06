require "sinatra"

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

require 'json'

get "/gowithit" do

  fl = 'lyricsbi.json'
  fa = 'ASFA.json'
  fo = 'ogjssonfix.json'

  fld = JSON.parse(File.read(fl))
  fad = JSON.parse(File.read(fa))
  fod = JSON.parse(File.read(fo))

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

  fad.each do |key, item|
    cd[key]['sum'] = item['sum']
    cd[key]['rad'] = item['rad']
  end

  fld.each do |key, item|
    cd[key].merge!(item)  
  end

    erb :gowithit, locals: { cd: cd.to_json } 

end
