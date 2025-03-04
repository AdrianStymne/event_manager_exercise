require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'




def clean_zipcode(zipcode)
  zipcode = zipcode.to_s.rjust(5,'0')[0..4]
end

def legislators_by_zipcode(zipcode)
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin 
    civic_info.representative_info_by_address(
     address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
     ).officials
  rescue
    'No Rep for YOU'
  end
end

def save_thank_you_letter(id,personal_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts personal_letter
  end
end

puts 'Event Manager Initialized!'


contents = CSV.open(
  'event_attendees.csv', 
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter


contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)
  personal_letter = erb_template.result(binding)
  save_thank_you_letter(id,personal_letter)
end