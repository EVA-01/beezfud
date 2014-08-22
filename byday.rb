require "./title.rb"

if ARGV[0] != "r"
	puts "Retrieve titles from archive.txt"
	l = Titles.initTitles
	puts "\tNo archive.txt" if !l
	puts "\tLoaded" if l
end
if ARGV.length == 3 or ARGV.length == 4
	if ARGV.length ==3
		month, day, year = ARGV
	else
		replace, month, day, year = ARGV
	end
	puts "Retrieving titles for #{month}/#{day}/#{year}"
else
	today = Time.new
	month, day, year = today.month, today.day, today.year
	puts "Retrieving titles for today"
end
k = Titles.getTitles(month, day, year)
puts "\tSuccessful" if k
puts "\t404" if !k
puts "Saving to archive.txt"
File.open("archive.txt", "w+") { |f| f.write(Titles.returnTitles.join("\n")) }
