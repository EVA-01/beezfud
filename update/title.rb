require 'nokogiri'
require 'open-uri'
require 'set'
require 'json'

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
	def self.getData
		if File.directory?("../archive") and File.exists?("../archive/data.json")
			@data = JSON.parse(File.read("../archive/data.json"))
		else
			@data = {}
		end
		return @data
	end
	def self.updateData(month, day, year)
		if !defined?(@data)
			self.getData
		end
		current = {
			"month" => month.to_i,
			"day" => day.to_i,
			"year" => year.to_i
		}
		if !@data.key?("latest") or current["year"] > @data["latest"]["year"] or (current["year"] == @data["latest"]["year"] and current["month"] > @data["latest"]["month"]) or (current["year"] == @data["latest"]["year"] and current["month"] == @data["latest"]["month"] and current["day"] > @data["latest"]["day"])
			@data["latest"] = current
		end
		if !@data.key?("earliest") or current["year"] < @data["earliest"]["year"] or (current["year"] == @data["earliest"]["year"] and current["month"] < @data["earliest"]["month"]) or (current["year"] == @data["earliest"]["year"] and current["month"] == @data["earliest"]["month"] and current["day"] < @data["earliest"]["day"])
			@data["earliest"] = current
		end
		if !@data.key?("included")
			@data["included"] = {
				"#{current["year"]}" => {
					"#{current["month"]}" => {
						"#{current["day"]}" => true
					}
				}
			}
		else
			if !@data["included"].key?("#{current["year"]}")
				@data["included"]["#{current["year"]}"] = {}
			end
			if !@data["included"]["#{current["year"]}"].key?("#{current["month"]}")
				@data["included"]["#{current["year"]}"]["#{current["month"]}"] = {}
			end
			if !@data["included"]["#{current["year"]}"]["#{current["month"]}"].key?("#{current["day"]}")
				@data["included"]["#{current["year"]}"]["#{current["month"]}"]["#{current["day"]}"] = true
			end
		end
		return @data
	end
	def self.saveData
		File.open("../archive/data.json","w") do |f|
			f.write(JSON.pretty_generate(@data))
		end
	end
end