require "sinatra"

set :bind, "0.0.0.0"
port = ENV["PORT"] || "3000"
set :port, port
get '/h/:filename' do
  filename = params[:filename].split(':')
  file_path = File.join(settings.public_folder, "#{filename[0]}.#{filename[1]}")
  if File.exist?(file_path)
    send_file file_path
  else
    status 404
    "File not found"
    "#{file_path}!"
  end
end
get "/" do
  name = ENV["NAME"] || "World"
  "Hello #{name}!"
end