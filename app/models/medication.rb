class Medication

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
