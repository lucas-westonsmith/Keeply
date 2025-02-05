class BusinessContactsController < ApplicationController
  def create
    @contact = params[:business_contact]

    if @contact[:email].present? && @contact[:message].present?
      BusinessMailer.contact_email(@contact).deliver_now
      flash[:notice] = "Thank you for reaching out! We'll get back to you soon."
    else
      flash[:alert] = "Please fill in all required fields."
    end

    redirect_to business_path
  end
end
