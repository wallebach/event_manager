require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clear_homephone_number(homephone_number)
    homephone_number = homephone_number.to_s.gsub(/\D/,"").gsub(/^1/, "")
    if homephone_number.length == 10 
        return homephone_number
    else
        return "bad phone"
    end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def peak_hour(dates) 
    hours = {}
    dates.each do | date |
        time = Time.strptime(date, "%m/%d/%y %k:%M")
        count = hours[time.hour]
        if count.nil? 
            hours[time.hour] = 1
        else 
            hours[time.hour] += 1
        end
    end
    return hours.key(hours.values.max)
end

def peak_days(dates) 
    weekdays = {}
    dates.each do | date |
        time = Time.strptime(date, "%m/%d/%y %k:%M")
        weekday_number = weekdays[time.wday]
        if weekday_number.nil?
            weekdays[time.wday] = 1
        else 
            weekdays[time.wday] += 1
        end
    end
    return weekdays.sort_by{|k,v| -v}
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

dates = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = row[:homephone]
  
  homephone = clear_homephone_number(homephone)

  dates << row[:regdate]

  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

puts "Peak hour is: #{peak_hour(dates)}" 

day_number = peak_days(dates)[0][0].to_i
puts "Peak day is: #{Date::DAYNAMES[day_number]}" 
