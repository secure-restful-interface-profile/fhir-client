##
# = Medication model
#
# This class provides medication-specific logic, particularly for parsing
# medications from FHIR-formatted data.

class Medication

  ##
  # Parses a list of medications from FHIR-formatted data
  #
  # Params:
  #   +fhir+::          FHIR-formatted data
  #
  # Returns:
  #   +Array+::         Array of medications parsed from FHIR data

  def self.parse_from_fhir(fhir)
    medications = []

    fhir["entry"].map do |resource|
      medication = Hash.new

      medication["name"] = resource["content"]["code"]["coding"].first["display"]

      medications << medication
    end

    medications
  end
  
end
