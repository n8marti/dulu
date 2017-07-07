module ApplicationHelper
  def assemble_dates(params, model, *fields)
    fields.each do |field|
      if params[model]["#{field}_y"]
        begin
          fdate = FuzzyDate.new(params[model]["#{field}_y"],
                                params[model]["#{field}_m"],
                                params[model]["#{field}_d"])
          params[model][field] = fdate.to_s
        rescue
          # Bad Data. Set nothing and allow it to fail validation if the field is required
          # Downside: fields that aren't required will be silently ignored which may surprise the user
          # Probable Solution: JS Validation
          # TODO: revisit this downside
        end
      end
    end
  end

end
