##
# = Patient model
#
# This class provides patient-specific logic, particularly for parsing
# patients from FHIR-formatted data.

class Patient

  ##
  # Parses a list of patients from FHIR-formatted data
  #
  # Params:
  #   +fhir+::          FHIR-formatted data
  #
  # Returns:
  #   +Array+::         Array of patients parsed from FHIR data

  def self.parse_from_fhir(fhir)
    patients = []

    fhir["entry"].map do |resource|
      patient = Hash.new
      birth_date = Date.parse(resource["content"]["birthDate"])

      patient["family_name"]  = resource["content"]["name"].first["family"]
      patient["given_name"]   = resource["content"]["name"].first["given"]
      patient["birth_date"]   = birth_date
      patient["gender"]       = resource["content"]["gender"]["coding"].first["code"] == "M" ? "Male" : "Female"
      patient["age"]          = Time.diff(Date.today, birth_date)[:year]
      patient["id"]           = resource["id"]

      patients << patient
    end

    patients
  end
  
end
