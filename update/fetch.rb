require "./title.rb"
require "thor"

def days_in_month(month, year = Time.now.year)
	days = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	return 29 if month == 2 && Date.gregorian_leap?(year)
	days[month]
end

class CLI < Thor
	class_option :replace, :type => :boolean, :default => false, :aliases => "-r"
	
	option :month, :type => :numeric, :default => Time.now.month, :aliases => "-m"
	option :year, :type => :numeric, :default => Time.now.year, :aliases => "-y"
	desc "month [-r] [-m MONTH] [-y YEAR]", "Archive by month"
	def month
		last = days_in_month(options[:month])
		if !options[:replace]
			puts "Retrieve titles from local archive"
			l = Titles.initTitles(options[:month], options[:year])
			puts "\tNo archive.txt" if !l
			puts "\tLoaded" if l
		else
			puts "Will replace entire month"
		end
		puts "Retrieving titles from month #{options[:month]}"
		for day in 1..last
			puts "\t#{options[:month]}/#{day}/#{options[:year]}"
			k = Titles.getTitles(options[:month], day, options[:year])
			puts "\t\tSuccessful" if k
			puts "\t\t404" if !k
			break if !k
		end
		puts "Saving to archive"
		if File.directory?("../archive")
			if !File.directory?("../archive/#{options[:year]}")
				Dir.mkdir "../archive/#{options[:year]}"
			end
		else
			Dir.mkdir "../archive"
			Dir.mkdir "../archive/#{options[:year]}"
		end
		File.open("../archive/#{options[:year]}/#{options[:month]}.txt", "w+") { |f| f.write(Titles.returnTitles.join("\n")) }
	end
	
	option :month, :type => :numeric, :default => Time.now.month, :aliases => "-m"
	option :year, :type => :numeric, :default => Time.now.year, :aliases => "-y"
	option :day, :type => :numeric, :default => Time.now.day, :aliases => "-d"
	desc "day [-r] [-m MONTH] [-d DAY] [-y YEAR]", "Archive by day"
	def day
		if !options[:replace]
			puts "Retrieve titles from local archive"
			l = Titles.initTitles(options[:month], options[:year])
			puts "\tNo archive.txt" if !l
			puts "\tLoaded" if l
		else
			puts "Will replace entire month"
		end
		puts "Retrieving titles from #{options[:month]}/#{options[:day]}/#{options[:year]}"
		k = Titles.getTitles(options[:month], options[:day], options[:year])
		puts "\tSuccessful" if k
		puts "\t404" if !k
		puts "Saving to archive"
		if File.directory?("../archive")
			if !File.directory?("../archive/#{options[:year]}")
				Dir.mkdir "../archive/#{options[:year]}"
			end
		else
			Dir.mkdir "../archive"
			Dir.mkdir "../archive/#{options[:year]}"
		end
		File.open("../archive/#{options[:year]}/#{options[:month]}.txt", "w+") { |f| f.write(Titles.returnTitles.join("\n")) }
	end
end

CLI.start(ARGV)