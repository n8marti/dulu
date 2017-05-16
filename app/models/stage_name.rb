class StageName < ApplicationRecord

  has_many :translation_stages

  FIRST_STAGE_ID = 1
  LAST_STAGE_ID = 9

  #Only used for initializing database
  def self.add_stages_to_db
    ["Planned", "Drafting", "Testing", "Revising", "Back-Translating",
    "Consultant Check Needed", "Consultant Check in Progress", 
    "Consultant Checked", "Published"].each do |stage|
      StageName.new({name: stage}).save
    end
  end

  def next_stage
    if ( FIRST_STAGE_ID .. (LAST_STAGE_ID-1) ) === self.id
      return StageName.find(self.id+1)
    end
    return self
  end
end
