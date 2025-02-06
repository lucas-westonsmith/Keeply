class BusinessMailer < ApplicationMailer
  default to: "contact@keeply.tech", from: "no-reply@keeply.tech"

  def contact_email(contact_params)
    @contact_params = contact_params
    mail(
      subject: "New Business Inquiry from #{@contact_params[:company]}",
      reply_to: @contact_params[:email]
    )
  end
end
