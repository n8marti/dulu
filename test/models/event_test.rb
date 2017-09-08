require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @genesis_check = events :HdiGenesisChecking
    I18n.locale = :en
  end

  test "Relations" do
    hdi_program = programs :HdiProgram
    drew_genesis_check = event_participants :DrewHdiGenesis
    drew = people :Drew

    assert_includes @genesis_check.programs, hdi_program
    assert_includes @genesis_check.event_participants, drew_genesis_check
    assert_includes @genesis_check.people, drew
  end

  test "Presence Validation" do
    params = {kind: :Consultation, start_date: '2019-04', end_date: '2019-04'}
    model_validation_hack_test Event, params
  end

  test "Validate Kind" do
    assert_raises(Exception){ @genesis_check.update(kind: 'NotARealKind') }
  end

  test "Validate Start Date Fuzzy Date" do
    refute @genesis_check.update(start_date: 'abc'), "Should not save with invalid start date"
  end

  test "Validate End Date not before Start Date" do
    refute @genesis_check.update(end_date: '2017-01'), "Should not save with end date before start date"
  end

  test "Display Name" do
    hdi_past = events :HdiPastChecking
    assert_equal 'Hdi Genesis Checking', @genesis_check.display_name
    assert_equal 'Consultant Check', hdi_past.display_name
  end

  test "F Dates" do
    assert_equal FuzzyDate.new(2018, 1, 15), @genesis_check.f_start_date
    assert_equal FuzzyDate.new(2018, 1, 30), @genesis_check.f_end_date
    assert_nil Event.new.f_start_date
    assert_nil Event.new.f_end_date
  end

  test "Role Of" do
    drew = people :Drew
    rick = people :Rick
    consultant = program_roles :TranslationConsultant
    assert_equal consultant, @genesis_check.role_of(drew)
    assert_nil @genesis_check.role_of(rick)
  end

  test "User Not Associated With Event" do
    rick = people :Rick
    refute @genesis_check.associated_with?(rick), "Rick is not associated with the event"
  end

  test "User Direct Association" do
    rick = people :Rick
    tc = program_roles :TranslationConsultant
    @genesis_check.event_participants << EventParticipant.new(person: rick, program_role: tc)
    assert @genesis_check.associated_with?(rick), "Rick is directly associated with the event"
  end

  test "User Program Association" do
    rick = people :Rick
    tc = program_roles :TranslationConsultant
    hdi = programs :HdiProgram
    Participant.create(person: rick, program: hdi, program_role: tc, start_date: '2017')
    assert @genesis_check.associated_with?(rick), "Rick is associated with Event program"
  end
end