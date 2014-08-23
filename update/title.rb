require 'nokogiri'
require 'open-uri'
require 'set'

class String
	def clean
		c = ""
		self.each_byte { |x| c << x unless x > 127 }
		return c
	end
end
class Titles
	@titles = Set.new []
	def self.getTitles(month, day, year)
		url = "http://www.buzzfeed.com/archive/#{year}/#{month}/#{day}"
		begin
			doc = Nokogiri::HTML(open(url))
			titles = doc.css(".flow li.bf_dom a")
			@titles.merge(titles.map { |t| t.content.gsub(/\xE2\x80\x9C/, '"').gsub(/\xE2\x80\x9D/, '"').gsub(/\xE2\x80\x98/, "'").gsub(/\xE2\x80\x99/, "'").clean })
			return true
		rescue OpenURI::HTTPError => e
			if e.message == "404 Not Found"
				return false
			else
				raise e
			end
		end
	end
	def self.initTitles(month, year)
		if File.directory?("../archive") and File.directory?("../archive/#{year}") and File.exists?("../archive/#{year}/#{month}.txt")
			k = File.read("../archive/#{year}/#{month}.txt").split("\n")
			@titles.merge(k)
			return true
		else
			return false
		end
	end
	def self.returnTitles
		return @titles.to_a
	end
end