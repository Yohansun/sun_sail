class CustomersNotifier < ActionMailer::Base
  def around(message)
    @message = message
    @account = message.account
    from = message.account.settings.email_notifier_from

    mail(:from => from, :to => message.recipients, :subject => message.title) do |format|
      format.html
    end
  end
end