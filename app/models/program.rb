class Program < ApplicationRecord
  include ClusterProgram

  has_many :activities
  has_many :translation_activities
  has_many :linguistic_activities
  has_many :media_activities
  has_many :bible_books, through: :translation_activities

  has_many :publications
  has_many :domain_updates

  belongs_to :language
  has_one :cluster, through: :language

  default_scope { includes(:language).order("languages.name") }

  def name
    language.name
  end

  alias display_name name

  def get_lpf
    lpf || cluster.try(:lpf)
  end

  def all_participants
    cluster.nil? ?
      participants :
      participants + cluster.participants
  end

  def all_people
    cluster.nil? ?
      people :
      people + cluster.people
  end

  def all_current_participants
    cluster.nil? ?
      current_participants :
      current_participants + cluster.current_participants
  end

  def all_current_people
    cluster.nil? ?
      current_people :
      current_people + cluster.current_people
  end

  def sorted_activities
    activities.order("type DESC, bible_book_id")
  end

  def sorted_translation_activities
    translation_activities.joins(:bible_book).order("bible_books.usfm_number")
  end

  def research_activities
    linguistic_activities.where(category: :Research)
  end

  def workshops_activities
    linguistic_activities.where(category: :Workshops)
  end

  def sorted_pubs(kind)
    publications.where(kind: kind).order("year DESC")
  end

  def is_translating?(book_id)
    translation_activities.where(bible_book_id: book_id).count > 0
  end

  def all_events
    cluster.nil? ?
      events :
      Event.left_outer_joins(:programs, :clusters)
      .where("events_programs.program_id=? or clusters_events.cluster_id=?", id, cluster.id)
  end

  def percentages
    percents = {}
    translations = translation_activities.loaded? ? translation_activities :
      translation_activities.includes([:bible_book, :stages]).where(stages: { current: true })
    translations.each do |translation|
      unless translation.stages.first.name == Stage.first_stage(:Translation)
        bible_book = translation.bible_book
        testament = bible_book.testament
        stage_name = translation.stages.first.name
        percents[testament] ||= {}
        percents[testament][stage_name] ||= 0.0
        percents[testament][stage_name] += bible_book.percent_of_testament
      end
    end
    percents
  end

  def self.percentages(programs = nil)
    percentages = {}
    unless programs
      programs = Program.includes(:translation_activities => [:bible_book, :stages])
                        .where(stages: { current: true })
    end
    programs.each do |program|
      percentages[program.id] = program.percentages
    end
    percentages
  end

  def self.all_sorted_by_recency
    Program.all.unscope(:order).order("programs.updated_at DESC")
  end

  def self.search(query)
    programs = Program.joins(:language).where("unaccent(languages.name) ILIKE unaccent(?) OR
                                               unaccent(languages.alt_names) ILIKE unaccent(?) OR languages.code=?",
                                              "%#{query}%", "%#{query}%", query).includes(:language)
    results = []
    programs.each do |program|
      description = "#{I18n.t(:Language_program)}"
      description += " - #{program.activities.count} #{I18n.t(:Activities).downcase}" if program.activities.count > 0
      results << { title: program.name,
                   model: program,
                   description: description }
    end
    results
  end

  private
end
