require "sinatra"
require 'json'
require 'open-uri'
require 'net/http'

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
post '/api/generate' do # Updated URL
  content_type :json

  begin
    params = JSON.parse(request.body.read)
    prompt = params['prompt']
    api_key = params['api_key']
    ai_source = params['ai_source']
    iterations = params['iterations'].to_i

    responses = []
    iterations.times do |i|
      response = get_llm_response(prompt, ai_source, api_key)
      responses << response
      prompt = response # Simple loop; you can customize this
    end

    { responses: responses }.to_json
  rescue => e
    { error: e.message }.to_json
  end
end

def get_llm_response(prompt, ai_source, api_key)
  if ai_source == "OpenAI"
    response = call_openai(prompt, api_key)
    response['choices'][0]['text']
  else
    "AI source '#{ai_source}' not supported"
  end
end

def call_openai(prompt, api_key)
  uri = URI('https://api.openai.com/v1/completions')
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{api_key}"
  request.body = {
    model: 'text-davinci-003',
    prompt: prompt,
    max_tokens: 150,
  }.to_json

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(request)}
  JSON.parse(response.read_body)
end
post '/vertex_ai' do
  content_type :json

  begin
    request_data = JSON.parse(request.body.read)
    api_key = request_data['apiKey']
    prompt = request_data['prompt']

    # Authenticate with Vertex AI (Adapt this based on your authentication method)
    credentials = api_key #Could be a json key file path as well


    client = Google::Cloud::AI.new(credentials: credentials, version: :v1)

    model = client.generative_model(MODEL_NAME, project: PROJECT_ID, location: LOCATION)

    response = model.generate_content(prompt)

    #Check for errors
    if response.error
       { error: response.error }.to_json
    else
      { text: response.content }.to_json
    end



  rescue StandardError => e # Add error handling
    puts "Error: #{e.message}" #Log to server console for debugging
    { error: "An error occurred. Check API key and parameters." }.to_json
  end
end



get '/ai' do
  erb :aitest # Updated template name
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
  api_key = "AIzaSyCMkYOzj-pE5BlUmdnJBStvsNtdOalHKMo"
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