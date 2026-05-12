# frozen_string_literal: true

MaisPersonClient.configure(
  api_key: Base64.decode64(Settings.person_api.key),
  api_cert: Base64.decode64(Settings.person_api.cert),
  base_url: Settings.person_api.url,
  user_agent: 'Stanford Digital Repository'
)

# Override the MaIS Person Client to add a method for converting the XML
# response into a Person struct, and to monkeypatch the Person struct to include
# a method for converting it into a hash for use in the AccountService
class MaisPersonClient
  # Add a method to convert the XML response from the MAIS Person API into a Person struct for use in the AccountService
  def self.to_person(xml_string)
    Person.new(xml_string)
  end

  # Monkeypatch Person to include hashification logic for use in the AccountService
  class Person
    def to_h
      {
        sunetid:,
        name: [display_name.first_name, display_name.last].compact.join(' '),
        description: job_title
      }
    end
  end
end
