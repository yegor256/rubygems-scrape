require 'nokogiri'
require 'open-uri'

root = 'https://rubygems.org'
headers = {
  "User-Agent" => "curl/7.30.0",
  "Accept" => '*/*'
}

start = '000'

('A'..'Z').to_a.each do |letter|
  suffix = "/gems?letter=#{letter}&page=1"
  while true do
    doc = Nokogiri::HTML(
      open(root + suffix, headers)
    )
    doc.css('div.gems ol li a').each do |link|
      uri = link['href']
      next if uri < "/gems/#{start}"
      page = Nokogiri::HTML(open(root + uri, headers))
      text = ''
      title = page.at_css('h2 a')
      text += title
      source = page.at_css('div.links a')
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
