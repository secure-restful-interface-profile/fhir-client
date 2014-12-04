class Condition

  def self.parse_from_fhir(fhir)
    conditions = []

    fhir["entry"].map do |resource|
      condition = Hash.new

      condition["text_status"]  = resource["content"]["code"]["coding"].first["display"]
      condition["onset_date"]   = resource["content"]["onsetDate"].to_datetime
      condition["location"]     = resource["content"]["location"].first["code"]["coding"].first["display"]

      conditions << condition
    end

    conditions
  end

end
