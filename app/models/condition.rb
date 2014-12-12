##
# = Condition model
#
# This class provides condition-specific logic, particularly for parsing
# conditions from FHIR-formatted data.

class Condition

  ##
  # Parses a list of conditions from FHIR-formatted data
  #
  # Params:
  #   +fhir+::          FHIR-formatted data
  #
  # Returns:
  #   +Array+::         Array of conditions parsed from FHIR data

  def self.parse_from_fhir(fhir)
    conditions = []

    fhir["entry"].map do |resource|
      condition = Hash.new

      condition["text_status"]  = resource["content"]["code"]["coding"].first["display"]
      condition["onset_date"]   = Date.parse(resource["content"]["onsetDate"])
      condition["location"]     = resource["content"]["location"].first["code"]["coding"].first["display"]

      conditions << condition
    end

    conditions
  end

end
