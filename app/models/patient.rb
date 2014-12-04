class Patient

  def self.parse_from_fhir(fhir)
    patients = []

    fhir["entry"].map do |resource|
      patient = Hash.new

      patients << patient
    end

    patients
  end
  
end
