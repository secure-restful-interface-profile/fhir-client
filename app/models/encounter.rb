##
# = Encounter model
#
# This class provides encounter-specific logic, particularly for parsing
# encounters from FHIR-formatted data.

class Encounter

  ##
  # Parses a list of encounteres from FHIR-formatted data.
  #
  # Params:
  #   +fhir+::          FHIR-formatted data
  #
  # Returns:
  #   +Array+::         Array of encounters parsed from FHIR data

  def self.parse_from_fhir(fhir)
    encounters = []

    fhir["entry"].map do |resource|
      encounter = Hash.new
      
      # encounter["status"] = ???
      # encounter["location"] = ???
      # encounter["start"] = ???

      encounters << encounter
    end

    encounters
  end

end
