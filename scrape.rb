require 'nokogiri'
require 'open-uri'
require 'retriable'

root = 'https://rubygems.org'
start = '000'

def load(uri)
  Retriable.retriable do
    headers = {
      "User-Agent" => "curl/7.30.0",
      "Accept" => 'text/html'
    }
    Nokogiri::HTML(open(uri, headers))
  end
end

('A'..'Z').to_a.each do |letter|
  suffix = "/gems?letter=#{letter}&page=1"
  while true do
    doc = load(root + suffix)
    doc.css('div.gems ol li a').each do |link|
      uri = link['href']
      next if uri < "/gems/#{start}"
      page = load(root + uri)
      text = ''
      title = page.at_css('h2 a')
      text += title
      source = page.css('div.links a').find{ |a| a['href'].include? 'github.com' }
      text += ',' + (source ? source['href'] : 'nil')
      downloads = page.at_css('div.downloads span:first-child strong')
      text += ',' + (downloads ? downloads.text.gsub(',', '') : '0')
      puts text
      $stdout.flush
    end
    link = doc.at_css('a.next_page')
    break if link.nil?
    suffix = link['href']
  end
end
