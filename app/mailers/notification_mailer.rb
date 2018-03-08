class NotificationMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME']

  def welcome(person, creator)
    @person = person
    @creator = creator
    set_locale person
    mail to: to_field(person), subject: I18n.t('email.welcome.welcome')
  end

  def notify(notification)
    person = notification.person
    @notification = notification
    set_locale person
    mail to: to_field(person), subject: I18n.t('email.notify.subject')
    notification.update(emailed: true)
  end

  def notification_summary(person)
    @notifications = person.notifications.where(read: false, emailed: false)
    @person = person
    return if @notifications.empty?
    set_locale(person)
    mail to: to_field(person), subject: I18n.t('email.notification_summary.subject')
    @notifications.update(emailed: true)
  end

  private

  def set_locale(person)
    I18n.locale = person.try(:ui_language) || I18n.default_locale
  end

  def to_field(person)
    %("#{person.full_name}" <#{person.email}>)
  end
end
