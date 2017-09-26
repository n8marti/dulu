require 'test_helper'

class NewTranslationActivityTest < Capybara::Rails::TestCase
  def setup
    # Capybara.current_driver = :selenium
    @olga = people :Olga
    @hdi_program = programs :HdiProgram
    @john = bible_books :John
    log_in @olga
    visit program_path(@hdi_program)
    click_link 'Add books to translate'
  end

  test "Add John Translation" do
    select 'John', from: 'activity_bible_book'
    check 'Drew Maust'
    click_button 'Add'
    assert_current_path dashboard_program_path @hdi_program
    hdi_john = @hdi_program.translation_activities.find_by(bible_book: @john)
    row = find(:css, "tr#activity-row-#{hdi_john.id}")
    assert row.has_content?('John'), "Should see John listed"
    click_link 'John'
    assert page.has_content?('Drew Maust'), "Should see Drew's name on John page"
  end

  test "Add a whole Testament" do
    select 'New Testament', from: 'activity_bible_book'
    check 'Drew Maust'
    click_button 'Add'
    assert_current_path dashboard_program_path @hdi_program
    click_link 'John'
    assert page.has_content?('Drew Maust'), "Should see Drew's name on the John page"
  end
end