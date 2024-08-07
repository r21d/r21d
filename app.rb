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
  redirect "pabe.html"
end

get "/u" do
morts.rb
  redirect "https://www.youtube.com/channel/UCkfI4g-ztKQZa3bB_QX9gBw?sub_confirmation=1"
end

get "/list" do
  redirect "https://www.youtube.com/watch?v=QblWYWmXOQ4&list=PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr"
end

get '/wow' do
  json_file_path = File.join(settings.public_folder, 'o.json') 
  begin
    json_data = JSON.parse(File.read(json_file_path))
  rescue Errno::ENOENT => e
    status 404
    return "File not found: #{e.message}"
  rescue JSON::ParserError => e
    status 500
    return "Invalid JSON data: #{e.message}"
  endrub
  erb :gow, locals: { data: json_data } 
end

get "/gowithit" do
  playlist_id = "PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr" 
  api_key = "AIzaSyCMkYOzj-pE5BlUmdnJBStvsNtdOalHKMo"
  url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{playlist_id}&key=#{api_key}&maxResults=50"
end
  response = open(url)
  data = JSON.parse(response.read)
  videos = data['items'].map do |item|
    {
      title: item['snippet']['title'],
      videoId: item['snippet']['resourceId']['videoId'],
      thumbnail: item['snippet']['thumbnails']['medium']['url'] 
    }
  end
  erb :playlist, locals: { videos: videos }
end
