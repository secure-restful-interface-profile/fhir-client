##
# = Observation model
#
# This class provides observation-specific logic, particularly for parsing
# observations from FHIR-formatted data.

class Observation

  ##
  # Parses a list of observations from FHIR-formatted data
  #
  # Params:
  #   +fhir+::          FHIR-formatted data
  #
  # Returns:
  #   +Array+::         Array of observations parsed from FHIR data

  def self.parse_from_fhir(fhir)
    observations = []

    fhir["entry"].map do |resource|
      observation = Hash.new

      observation["type"]   = resource["content"]["name"]["coding"].first["display"]
      observation["date"]   = Date.parse(resource["content"]["appliesDateTime"])
      observation["value"]  = resource["content"]["component"].map do |component|
        component["valueQuantity"]["value"].to_i
      end

      observations << observation
    end

    observations
  end
  
end
