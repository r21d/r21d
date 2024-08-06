require 'json'
require 'open-uri'

# URLs of your JSON files
urls = [
  'http://r21d.com/lyricsbi.json',
  'http://r21d.com/ASFA.json',
  'http://r21d.com/ogjssonfix.json'
]

# Fetch and parse JSON data
data_sources = []
urls.each do |url|
  begin
    json_data = URI.open(url).read
    data_sources << JSON.parse(json_data)
  rescue OpenURI::HTTPError => e
    puts "Error fetching #{url}: #{e.message}"
  rescue JSON::ParserError => e
    puts "Error parsing #{url}: #{e.message}"
  end
end

# Combine data, ensuring all 92 entries are present
combined_data = {}
(1..92).each do |id|
  combined_data[id.to_s] = {}  # Initialize each entry

  data_sources.each do |data_source|
    if data_source.key?(id.to_s)
      combined_data[id.to_s].merge!(data_source[id.to_s])
    end
  end
end

# Write the combined data to a new JSON file
File.open('combined.json', 'w') do |file|
  file.write(JSON.pretty_generate(combined_data))
end

puts "Combined JSON data written to combined.json"