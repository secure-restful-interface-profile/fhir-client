class Encounter

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
