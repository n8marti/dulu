class Role
  ROLES = %i( Translator TranslationConsultant TranslationConsultantTraining Exegete BackTranslator
              LinguisticConsultant LinguisticConsultantTraining Linguist
              Literacy_specialist Literacy_consultant
              Scripture_engagement_specialist
              MediaConsultant MediaSpecialist
              LanguageProgramCommittee
              Cluster_coordinator Cluster_facilitator ProjectCoordinator
              LanguageProgramFacilitator
              Administration
              DuluAdmin
  )

  NON_PROGRAM_ROLES = %i( Administration DuluAdmin )

  SUPERVISOR_ROLES = %i( DuluAdmin Administration LanguageProgramFacilitator )

  PARTICIPANT_ROLES = %i(
    Translator TranslationConsultant TranslationConsultantTraining Exegete BackTranslator
    LinguisticConsultant LinguisticConsultantTraining Linguist
    Literacy_specialist Literacy_consultant
    Scripture_engagement_specialist
    MediaConsultant MediaSpecialist
    Cluster_coordinator Cluster_facilitator ProjectCoordinator
  )

  EVENT_ROLES = %i( Leader Facilitator Student )

  def self.program_roles(source = ROLES)
    source - NON_PROGRAM_ROLES
  end

  def self.available(assign_to, source = ROLES)
    source - assign_to.roles
  end

  def self.grantable_roles(user, person = nil)
    if user.has_role? :DuluAdmin
      roles = ROLES
    elsif user.has_role_among? SUPERVISOR_ROLES
      roles = ROLES - [:DuluAdmin]
    elsif user.has_role_among? PARTICIPANT_ROLES
      roles = ROLES - SUPERVISOR_ROLES
    else
      roles = []
    end
    return roles if person.nil?
    available(person, roles)
  end

  def self.is_a_role?(role)
    ROLES.include? role.to_sym
  end

  def self.has_a_program_role?(person)
    arrays_overlap? program_roles, person.roles
  end

  def self.roles_overlap?(roles1, roles2)
    arrays_overlap?(roles1, roles2)
  end

  # Keep in sync with Role.ts
  def self.domain(role)
    case role.to_sym
    when :Administration then nil
    when :BackTranslator then :Translation
    when :DuluAdmin then nil
    when :Cluster_coordinator then :All
    when :Cluster_facilitator then :All
    when :Exegete then :Translation
    when :Facilitator then nil
    when :LanguageProgramCommittee then :All
    when :LanguageProgramFacilitator then :All
    when :Leader then nil
    when :Linguist then :Linguistics
    when :LinguisticConsultant then :Linguistics
    when :LinguisticConsultantTraining then :Linguistics
    when :Literacy_specialist then :Literacy
    when :Literacy_consultant then :Literacy
    when :MediaConsultant then :Media
    when :MediaSpecialist then :Media
    when :ProjectCoordinator then :All
    when :Scripture_engagement_specialist then :Scripture_use
    when :Student then nil
    when :Translator then :Translation
    when :TranslationConsultant then :Translation
    when :TranslationConsultantTraining then :Translation
    end
  end

  private

  def self.arrays_overlap?(a1, a2)
    a1.any? { |item1| a2.any? { |item2| item1.to_sym == item2.to_sym } }
  end
end
