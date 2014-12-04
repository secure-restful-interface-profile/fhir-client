class Observation

  def self.parse_from_fhir(fhir)
    observations = []

    fhir["entry"].map do |resource|
      observation = Hash.new

      observation["date"]   = Date.parse(resource["content"]["appliesDateTime"])
      observation["value"]  = resource["content"]["component"].map do |component|
        component["valueQuantity"]["value"].to_i
      end

      observations << observation
    end

    observations
  end
  
end
