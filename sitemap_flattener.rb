require 'nokogiri'

class SitemapFlattener
  def initialize(file, output)
    @output = output
    @file = path_to_file(file)
    write_links
  end
  
  private
  
  def path_to_file(path)
    raise ArgumentError, "No file at path #{path}" unless File.exists?(path)
    File.read(path)
  end
  
  def write_links
    doc = Nokogiri::XML(@file) do |config|
      config.strict.nonet
    end
    open @output, 'a' do |f|
      doc.css("loc").each do |location|
        f << "#{location.content}\n"
      end
    end
  end
end

# usage: ruby sitemap_flattener.rb path/to/sitemaps output.csv
if __FILE__ == $0
  $stdout.sync = true
  input_dir = ARGV[0] || "."
  output_file = ARGV[0] || "output.csv"
  files = Dir.entries(input_dir).select {|f| f.match /sitemap[\d]+\.xml/ }

  if File.exists? output_file
    File.truncate(output_file, 0)
  end
  files.each do |f|
    SitemapFlattener.new(f, output_file)
  end
end
