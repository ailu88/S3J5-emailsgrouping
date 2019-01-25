
require 'rubygems'
require 'nokogiri'   
require 'open-uri'
require 'csv'


def get_townhall_urls	# creates an array with URLs of all towns from Dep 95

	page = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/rhone.html"))

	url_array = []
	urls_raw = page.xpath('//*/a[@class="lientxt"]')

	urls_raw.each do |url|
	    url_array << "http://annuaire-des-mairies.com"+url['href'].slice(1..-1)
	    end
	return url_array

end


def get_townhall_email(townhall_url)	# given a town's URL, returns its contact e-mail

	page = Nokogiri::HTML(open(townhall_url))
	townhall_email = page.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').text
	return townhall_email

end 


def get_townhall_name(townhall_url)	#given a town's URL, returns its name

	page = Nokogiri::HTML(open(townhall_url))
	townhall_name_raw = page.xpath('/html/body/div/main/section[1]/div/div/div/h1').text
	townhall_name = townhall_name_raw[0].capitalize+townhall_name_raw.slice(0..-9).split('-').map(&:capitalize).map{|a| a.length <=3 ? a.downcase : a}.join('-')[1..-1]
	return townhall_name

end 


def scrapping_townhalls_email		# creates a hash with the town name associated with its email for all URLs of Dep 95.

	url_array = get_townhall_urls

	email_list = [] 
		url_array.each do |town_url|
			hash = { get_townhall_name(town_url) => get_townhall_email(town_url)}
			puts hash
			email_list << hash
		end

	return email_list 
end 

def save_as_csv(list_of_emails_to_be_scrapped)

		CSV.open("db/emails.csv", "wb") do |csv|


			(0..list_of_emails_to_be_scrapped.length-1).each do |i|
				
				hash = list_of_emails_to_be_scrapped[i]
				keys = list_of_emails_to_be_scrapped[i].keys

				ville = keys[0] 
				email = hash[keys[0]]
				
				input = [ville, email]

	  		csv << input

	  		end
		end
	end



begin 								# Manage Exceptions
	scrapping_townhalls_email
rescue => e 
	puts "Oups petite erreur mais c'est pas grave"
end 

def perform
	list_of_scrapped_emails = scrapping_townhalls_email
	puts list_of_scrapped_emails
	save_as_csv(list_of_scrapped_emails)
end

perform
