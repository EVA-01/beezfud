require "./title.rb"
require "thor"

def days_in_month(month, year = Time.now.year)
	days = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	return 29 if month == 2 && Date.gregorian_leap?(year)
	days[month]
end

class CLI < Thor
	class_option :replace, :type => :boolean, :default => false, :aliases => "-r"

	option :year, :type => :numeric, :default => Time.now.year, :aliases => "-y"
	desc "year [-r] [-y YEAR]", "Archive by year"
	def year
		Titles.getData
		for month in 1..12
			last = days_in_month(month)
			t = Titles.new
			if !options[:replace]
				puts "Retrieve titles from local archive"
				l = t.initTitles(month, options[:year])
				puts "\tNo archive.txt" if !l
				puts "\tLoaded" if l
			else
				puts "Will replace entire month"
			end
			puts "Retrieving titles from month #{month}"
			for day in 1..last
				puts "\t#{month}/#{day}/#{options[:year]}"
				k = t.getTitles(month, day, options[:year])
				if k
					puts "\t\tSuccessful"
					Titles.updateData(month, day, options[:year])
				else
					puts "\t\t404"
					break
				end
			end
			g = t.returnTitles
			if g.length != 0
				puts "Saving to archive"
				if File.directory?("../archive")
					if !File.directory?("../archive/#{options[:year]}")
						Dir.mkdir "../archive/#{options[:year]}"
					end
				else
					Dir.mkdir "../archive"
					Dir.mkdir "../archive/#{options[:year]}"
				end
				File.open("../archive/#{options[:year]}/#{month}.txt", "w+") { |f| f.write(g.join("\n")) }
				puts "Updating data"
				Titles.saveData
			end
		end
		puts 7.chr
	end

	option :month, :type => :numeric, :default => Time.now.month, :aliases => "-m"
	option :year, :type => :numeric, :default => Time.now.year, :aliases => "-y"
	desc "month [-r] [-m MONTH] [-y YEAR]", "Archive by month"
	def month
		last = days_in_month(options[:month])
		t = Titles.new
		Titles.getData
		if !options[:replace]
			puts "Retrieve titles from local archive"
			l = t.initTitles(options[:month], options[:year])
			puts "\tNo archive.txt" if !l
			puts "\tLoaded" if l
		else
			puts "Will replace entire month"
		end
		puts "Retrieving titles from month #{options[:month]}"
		for day in 1..last
			puts "\t#{options[:month]}/#{day}/#{options[:year]}"
			k = t.getTitles(options[:month], day, options[:year])
			if k
				puts "\t\tSuccessful"
				Titles.updateData(options[:month], day, options[:year])
			else
				puts "\t\t404"
				break
			end
		end
		g = t.returnTitles
		if g.length != 0
			puts "Saving to archive"
			if File.directory?("../archive")
				if !File.directory?("../archive/#{options[:year]}")
					Dir.mkdir "../archive/#{options[:year]}"
				end
			else
				Dir.mkdir "../archive"
				Dir.mkdir "../archive/#{options[:year]}"
			end
			File.open("../archive/#{options[:year]}/#{options[:month]}.txt", "w+") { |f| f.write(g.join("\n")) }
			puts "Updating data"
			Titles.saveData
		end
		puts 7.chr
	end
	
	option :month, :type => :numeric, :default => Time.now.month, :aliases => "-m"
	option :year, :type => :numeric, :default => Time.now.year, :aliases => "-y"
	option :day, :type => :numeric, :default => Time.now.day, :aliases => "-d"
	desc "day [-r] [-m MONTH] [-d DAY] [-y YEAR]", "Archive by day"
	def day
		t = Titles.new
		Titles.getData
		if !options[:replace]
			puts "Retrieve titles from local archive"
			l = t.initTitles(options[:month], options[:year])
			puts "\tNo archive.txt" if !l
			puts "\tLoaded" if l
		else
			puts "Will replace entire month"
		end
		puts "Retrieving titles from #{options[:month]}/#{options[:day]}/#{options[:year]}"
		k = t.getTitles(options[:month], options[:day], options[:year])
		if k
			puts "\tSuccessful"
			Titles.updateData(options[:month], options[:day], options[:year])
		else
			puts "\t404"
		end
		g = t.returnTitles
		if g.length != 0
			puts "Saving to archive"
			if File.directory?("../archive")
				if !File.directory?("../archive/#{options[:year]}")
					Dir.mkdir "../archive/#{options[:year]}"
				end
			else
				Dir.mkdir "../archive"
				Dir.mkdir "../archive/#{options[:year]}"
			end
			File.open("../archive/#{options[:year]}/#{options[:month]}.txt", "w+") { |f| f.write(t.returnTitles.join("\n")) }
			puts "Updating data"
			Titles.saveData
		end
		puts 7.chr
	end
end

CLI.start(ARGV)