require 'sinatra'
require 'json'
require 'open3'
require 'net/http'
require 'uri'
require 'open-uri' # Required for the /gowithit route

# --- Sinatra Configuration ---
set :bind, '0.0.0.0'
port = ENV["PORT"] || 3000
set :port, port
set :views, File.join(File.dirname(__FILE__), 'views')
set :public_folder, File.join(File.dirname(__FILE__), 'public')

# --- API Endpoints (No Layout) ---

post '/vertex_ai' do
  content_type :json
  begin
    params = JSON.parse(request.body.read)
    api_key = params['apiKey']
    project_id = params['projectId']
    location = params['location']
    prompt = params['prompt']

    cmd = "curl -H \"Authorization: Bearer #{api_key}\" -H \"Content-Type: application/json\" -X POST -d \"{\\\"contents\\\": [{\\\"role\\\": \\\"user\\\", \\\"parts\\\": [{\\\"text\\\": \\\"#{prompt}\\\"}]}], \\\"systemInstruction\\\": {\\\"parts\\\": [{\\\"text\\\": \\\"Respond concisely.\\\"}]}, \\\"generationConfig\\\": {\\\"temperature\\\": 1, \\\"maxOutputTokens\\\": 200, \\\"topP\\\": 0.95}, \\\"safetySettings\\\": [{\\\"category\\\": \\\"HARM_CATEGORY_HATE_SPEECH\\\", \\\"threshold\\\": \\\"OFF\\\"}, {\\\"category\\\": \\\"HARM_CATEGORY_DANGEROUS_CONTENT\\\", \\\"threshold\\\": \\\"OFF\\\"}, {\\\"category\\\": \\\"HARM_CATEGORY_SEXUALLY_EXPLICIT\\\", \\\"threshold\\\": \\\"OFF\\\"}, {\\\"category\\\": \\\"HARM_CATEGORY_HARASSMENT\\\", \\\"threshold\\\": \\\"OFF\\\"}]}\" \"https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/gemini-1.5-flash-002:streamGenerateContent\""

    stdout, stderr, status = Open3.capture3(cmd)

    if status.success?
      begin
        response_json = JSON.parse(stdout)
        generated_text = response_json["result"]["parts"][0]["text"] rescue nil
        if generated_text.nil?
          { error: "Could not extract text from Vertex AI response" }.to_json
        else
          { text: generated_text }.to_json
        end
      rescue JSON::ParserError => e
        { error: "Invalid JSON response from Vertex AI: #{e.message}" }.to_json
      end
    else
      { error: "Error generating text from Vertex AI: #{stderr.strip}" }.to_json
    end
  rescue StandardError => e
    { error: "An unexpected error occurred: #{e.message}" }.to_json
  end
end


# --- Page Routes (Using Shared Layout) ---

get "/" do
  # Read the content of the static pabe.html and render it within the layout
  file_path = File.join(settings.public_folder, 'pabe.html')
  if File.exist?(file_path)
    html_content = File.read(file_path)
    erb html_content, layout: :layout
  else
    status 404
    "Homepage file (pabe.html) not found."
  end
end

get '/ai' do
  erb :ai_form, layout: :layout
end

get "/wow" do
  json_file_path0 = File.join(settings.public_folder, 'l.json')
  json_file_path1 = File.join(settings.public_folder, 'o.json')
  json_file_path2 = File.join(settings.public_folder, 'a.json')
  begin
    data = [
      JSON.parse(File.read(json_file_path0)),
      JSON.parse(File.read(json_file_path1)),
      JSON.parse(File.read(json_file_path2))
    ]
    erb :gow, locals: { data: data }, layout: :layout
  rescue Errno::ENOENT, JSON::ParserError => e
    status 500
    "Error loading data: #{e.message}"
  end
end

get "/gowithit" do
  playlist_id = "PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr"
  api_key = ENV['YOUTUBE_API_KEY'] || "" # IMPORTANT: Use an environment variable for this key
  url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{playlist_id}&key=#{api_key}&maxResults=50"
  begin
    response = URI.open(url)
    data = JSON.parse(response.read)
    videos = data['items'].map do |item|
      {
        title: item['snippet']['title'],
        videoId: item['snippet']['resourceId']['videoId'],
        thumbnail: item['snippet']['thumbnails']['medium']['url']
      }
    end
    erb :playlist, locals: { videos: videos }, layout: :layout
  rescue OpenURI::HTTPError => e
    status 500
    "Error fetching YouTube playlist: #{e.message}"
  end
end

get "/dafuq" do
  begin
    json_data = [
      JSON.parse(File.read(File.join(settings.public_folder, 'o.json'))),
      JSON.parse(File.read(File.join(settings.public_folder, 'a.json'))),
      JSON.parse(File.read(File.join(settings.public_folder, 'l.json')))
    ]
    erb :dafuq, locals: { data: json_data }, layout: :layout
  rescue Errno::ENOENT, JSON::ParserError => e
    status 500
    "Error loading data: #{e.message}"
  end
end

# --- Proxy Route for the Latin Applet ---

get '/latin' do
  begin
    uri = URI('https://the-didactic-codex-a-complete-latin-learning-suit-562877954055.us-west1.run.app/')
    response_body = Net::HTTP.get(uri)
    erb response_body, layout: :layout
  rescue StandardError => e
    status 500
    "Could not connect to the applet service: #{e.message}"
  end
end

get '/fin' do
  begin
    uri = URI('https://polyglot-codex-562877954055.us-west1.run.app/')
    response_body = Net::HTTP.get(uri)
    erb response_body, layout: :layout
  rescue StandardError => e
    status 500
    "Could not connect to the applet service: #{e.message}"
  end
end
# --- External Redirects (No Layout) ---

get "/insta" do
  redirect "https://www.instagram.com/r21d/"
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
