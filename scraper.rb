require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

url = 'https://eproperty.marrickville.nsw.gov.au/eServices/P1/PublicNotices/AllPublicNotices.aspx?r=MC.P1.WEBGUEST&f=%24P1.ESB.PUBNOTAL.ENQ'
page = agent.get(url)

base_info_url = 'https://eproperty.marrickville.nsw.gov.au/eServices/P1/eTrack/eTrackApplicationDetails.aspx?r=MC.P1.WEBGUEST&f=%24P1.ETR.APPDET.VIW&ApplicationId='
comment_url = 'mailto:council@innerwest.nsw.gov.au?subject=Development Application - '

(page/'//*[@id="ctl00_Content_cusApplicationResultsGrid_pnlCustomisationGrid"]').search('table').each do |t|
  closing_date = t.search('td')[7].inner_text
  on_notice_to = (closing_date == 'N/A' ? nil : Date.strptime(closing_date, '%d/%m/%Y'))

  record = {
    'council_reference' => t.search('td')[1].inner_text,
    'description'       => t.search('td')[3].inner_text,
    'on_notice_to'      => on_notice_to,
    'address'           => t.search('td')[5].inner_text,
    'info_url'          => base_info_url + t.search('td')[1].inner_text,
    'comment_url'       => comment_url + t.search('td')[1].inner_text,
    'date_scraped'      => Date.today.to_s
  }

  if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
    puts "Saving record " + record['council_reference'] + ", " + record['address']
#    puts record
    ScraperWiki.save_sqlite(['council_reference'], record)
  else
    puts "Skipping already saved record " + record['council_reference']
  end
end
