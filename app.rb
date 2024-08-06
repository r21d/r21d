require "sinatra"

set :bind, "0.0.0.0"
port = ENV["PORT"] || "3000"
set :port, port

get '/h/:filename' do
  filename = params[:filename].split(':')
  file_path = File.join("/public/", "#{filename[0]}.#{filename[1]}")
  if File.exist?(file_path)
    send_file file_path
  else
    redirect "/public/#{file_path}"
  end
end


get "/" do
  redirect "https://www.youtube.com/channel/UCkfI4g-ztKQZa3bB_QX9gBw?sub_confirmation=1"

end

get "/list" do
  redirect "https://www.youtube.com/watch?v=QblWYWmXOQ4&list=PL6sZpQz3MZtnG4B2W5RlaXUKUkr6catIr"
end
