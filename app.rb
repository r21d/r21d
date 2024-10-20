require 'sinatra'
require 'json'
require 'open3'
require 'base64'

set :bind, "0.0.0.0"
port = ENV["PORT"] || "8080"
set :port, port

post '/generate' do
  content_type :json

  begin
    params = JSON.parse(request.body.read)
    api_key_path = params['apiKey']
    project_id = params['projectId']
    location = params['location']
    prompt = params['prompt']


    # Read the service account key file - Enhanced Error Handling
    begin
      key_file_contents = File.read(api_key_path)
      key_file_data = JSON.parse(key_file_contents)
      encoded_key = Base64.encode64(key_file_data["private_key"])
    rescue Errno::ENOENT => e
      return { error: "Service account key file not found: #{e.message}" }.to_json
    rescue JSON::ParserError => e
      return { error: "Invalid JSON in service account key file: #{e.message}" }.to_json
    rescue StandardError => e
      return { error: "Error reading service account key file: #{e.message}" }.to_json
    end

    # Construct Curl command
    cmd = "curl -H \"Authorization: Bearer $(gcloud auth activate-service-account --key-file=#{api_key_path} print-access-token)\" -H \"Content-Type: application/json\" -X POST -d \"{\\\"contents\\\": [{\\\"role\\\": \\\"user\\\", \\\"parts\\\": [{\\\"text\\\": \\\"#{prompt}\\\"}]}], \\\"systemInstruction\\\": {\\\"parts\\\": [{\\\"text\\\": \\\"Respond concisely.\\\"}]}, \\\"generationConfig\\\": {\\\"temperature\\\": 1, \\\"maxOutputTokens\\\": 200, \\\"topP\\\": 0.95}, \\\"safetySettings\\\": [{\\\"category\\\": \\\"HARM_CATEGORY_HATE_SPEECH\\\", \\\"threshold\\\": \\\"OFF\\\"}, {\\\"category\\\": \\\"HARM_CATEGORY_DANGEROUS_CONTENT\\\", \\\"threshold\\\": \\\"OFF\\\"}, {\\\"category\\\": \\\"HARM_CATEGORY_SEXUALLY_EXPLICIT\\\", \\\"threshold\\\": \\\"OFF\\\"}, {\\\"category\\\": \\\"HARM_CATEGORY_HARASSMENT\\\", \\\"threshold\\\": \\\"OFF\\\"}]}\" \"https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/gemini-1.5-flash-002:streamGenerateContent\""


    stdout, stderr, status = Open3.capture3(cmd)

    if status.success?
      begin
        response_json = JSON.parse(stdout)
        generated_text = response_json["result"]["parts"][0]["text"] rescue nil
        if generated_text.nil?
          return { error: "Could not extract text from Vertex AI response" }.to_json
        else
          return { text: generated_text }.to_json
        end
      rescue JSON::ParserError => e
        return { error: "Invalid JSON response from Vertex AI: #{e.message}" }.to_json
      rescue StandardError => e
          return {error: "Error processing Vertex AI response: #{e.message}"}.to_json
      end
    else
      return { error: "Error generating text from Vertex AI (curl error): #{stderr.strip}" }.to_json
    end
  rescue StandardError => e
    return { error: "An unexpected error occurred: #{e.message}" }.to_json
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