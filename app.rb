require 'sinatra'
require 'json'
require 'open3' # For running curl

set :bind, "0.0.0.0"
port = ENV["PORT"] || "3000"
set :port, port

post '/generate' do
  content_type :json

  begin
    params = JSON.parse(request.body.read)
    api_key = params['apiKey']
    prompt = params['prompt']

    # Use curl to make the API request.  Error handling is crucial here.
    cmd = "curl -X POST -H \"Content-Type: application/json\" -H \"Authorization: Bearer #{api_key}\" \"https://api.openai.com/v1/completions\" -d '{\"model\": \"text-davinci-003\", \"prompt\": \"#{prompt}\", \"max_tokens\": 150}'"
    stdout, stderr, status = Open3.capture3(cmd)

    if status.success?
      response = JSON.parse(stdout)
      { text: response['choices'][0]['text'] }.to_json
    else
      error_message = "Error generating text: #{stderr.strip}"
      puts error_message # Log to server console for debugging.
      { error: error_message }.to_json
    end

  rescue JSON::ParserError => e
    { error: "Invalid JSON response from API: #{e.message}" }.to_json
  rescue StandardError => e
    { error: "An error occurred: #{e.message}" }.to_json
  end
end


get '/ai' do
  erb :ai_form
end

get "/" do
  redirect "pabe.html"
end

get "/fax" do
  redirect "https://r21d.atlassian.net/servicedesk/customer/portals"
end

get "/u" do
  redirect "https://www.youtube.com/channel/UCkfI4g-ztKQZa3bB_QX9gBw?sub_confirmation=1"
end

get "/list" do
  redirect "https://www.youtube.com/watch?v=QblWYWmXOQ4&list=PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr"
end



get '/wow' do
  json_file_path = File.join(settings.public_folder, 'l.json') 
  begin
    json_data0 = JSON.parse(File.read(json_file_path))
  rescue Errno::ENOENT => e
    status 404
    return "File not found: #{e.message}"
  rescue JSON::ParserError => e
    status 500
    return "Invalid JSON data: #{e.message}"
  end
    json_file_path = File.join(settings.public_folder, 'o.json') 
  begin
    json_data1 = JSON.parse(File.read(json_file_path))
  rescue Errno::ENOENT => e
    status 404
    return "File not found: #{e.message}"
  rescue JSON::ParserError => e
    status 500
    return "Invalid JSON data: #{e.message}"
  end
    json_file_path = File.join(settings.public_folder, 'a.json') 
  begin
    json_data2 = JSON.parse(File.read(json_file_path))
  rescue Errno::ENOENT => e
    status 404
    return "File not found: #{e.message}"
  rescue JSON::ParserError => e
    status 500
    return "Invalid JSON data: #{e.message}"
  end
  data = [json_data0, json_data1, json_data2]
  erb :gow, locals: { data: data  } 
end

get "/gowithit" do
  playlist_id = "PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr" 
  api_key = ""
  url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{playlist_id}&key=#{api_key}&maxResults=50"   
  response = URI.open(url)
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


get "/dafuq" do 
    json_data = [JSON.parse(File.read(File.join(settings.public_folder, 'o.json'))), 
    JSON.parse(File.read(File.join(settings.public_folder, 'a.json'))), 
    JSON.parse(File.read(File.join(settings.public_folder, 'l.json')))]

  
  erb :dafuq, locals: { data: json_data }
  end