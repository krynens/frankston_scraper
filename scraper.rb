require 'scraperwiki'
require 'mechanize'

FileUtils.touch('data.sqlite')

today = Time.now.strftime('%Y-%m-%d')

url   = 'https://epathway.frankston.vic.gov.au/ePathway/Production/Web/generalenquiry/enquirylists.aspx'
agent = Mechanize.new
page  = agent.get(url)

form = page.form('aspnetForm')
form.radiobuttons[0].click

page = agent.submit(form, form.buttons[2])
table = page.search('table.ContentPanel')
rows = table.search('tr.ContentPanel', 'tr.AlternateContentPanel')

for row in rows do
  date_received = row.search('td')[3].text.strip  
  record = {
    "address" => row.search('td')[1].text.strip,
    "council_reference" => row.search('td')[0].text.strip,
    "date_received" => DateTime.strptime(date_received, '%d/%m/%Y').strftime('%Y-%m-%d'),
    "date_scraped" => today,
    "description" => row.search('td')[2].text.strip,
    "info_url" => 'https://epathway.frankston.vic.gov.au/ePathway/Production/Web/GeneralEnquiry/' + row.search('a').to_s.split('"')[3]
    }
  
  ScraperWiki.save_sqlite(['council_reference'], record)
  
end
