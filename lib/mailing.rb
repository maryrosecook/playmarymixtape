require 'net/imap'

class Mailing < ActionMailer::Base

  # emails me when there is an error
  def log_email(log)
    # compose email components
    recipients Configuring.get("error_log_email_address")
    from Configuring.get("communication_email_address")
    reply_to = Configuring.get("communication_email_address")
    subject "Logged: #{log.event}."

    body[:current_user] = log.user unless !log.user
    body[:item_id] = log.item_id unless !log.item_id
    body[:item_class] = log.item_class unless !log.item_class
    body[:event] = log.event unless !log.event
    body[:exception_backtrace] = log.exception_backtrace unless !log.exception_backtrace
    body[:exception_message] = log.exception_message unless !log.exception_message
    body[:message] = log.message unless !log.message
    body[:time] = log.time unless !log.time
  end
end
