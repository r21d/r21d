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


get "/gowithit" do
  # Fetch playlist data from YouTube API
  playlist_id = "PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr "  # Replace with your actual playlist ID
  api_key = "AIzaSyCMkYOzj-pE5BlUmdnJBStvsNtdOalHKMo"           # Replace with your YouTube Data API key
  url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{playlist_id}&key=#{api_key}&maxResults=50"   
  # Get up to 50 videos

  response = open(url)
  data = JSON.parse(response.read)

  # Extract video information
  videos = data['items'].map do |item|
    {
      title: item['snippet']['title'],
      videoId: item['snippet']['resourceId']['videoId'],
      thumbnail: item['snippet']['thumbnails']['medium']['url']  # Choose appropriate thumbnail size
    }
  end

  # Pass video data to the view
  erb :playlist, locals: { videos: videos }
end
