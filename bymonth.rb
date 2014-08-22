require "./title.rb"

COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
def days_in_month(month, year = Time.now.year)
	return 29 if month == 2 && Date.gregorian_leap?(year)
	COMMON_YEAR_DAYS_IN_MONTH[month]
end

if ARGV[0] != "r"
	puts "Retrieve titles from archive.txt"
	l = Titles.initTitles
	puts "\tNo archive.txt" if !l
	puts "\tLoaded" if l
end
if ARGV.length == 2 or (ARGV.length == 1 and ARGV[0] != "r")
	if ARGV.length == 1
		month = ARGV[0]
	else
		replace, month = ARGV
	end
	puts "Retrieving titles for month #{month}"
else
	today = Time.new
	month = today.month
	puts "Retrieving titles for this month"
end
last = days_in_month(month.to_i)
year = Time.now.year
for day in 1..last
	puts "\t#{month}/#{day}/#{year}"
	k = Titles.getTitles(month, day, year)
	puts "\t\tSuccessful" if k
	puts "\t\t404" if !k
	break if !k
end
puts "Saving to archive.txt"
File.open("archive.txt", "w+") { |f| f.write(Titles.returnTitles.join("\n")) }