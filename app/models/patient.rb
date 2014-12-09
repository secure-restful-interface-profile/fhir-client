class Patient

  def self.parse_from_fhir(fhir)
    patients = []

    fhir["entry"].map do |resource|
      patient = Hash.new

      patient["family_name"]   = resource["content"]["name"].first["family"]
      patient["given_name"]    = resource["content"]["name"].first["given"]
      patient["birth_date"]    = Date.parse(resource["content"]["birthDate"])
      patient["id"]           = resource["id"]

      patients << patient
    end

    patients
  end
  
end
