require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class LoyaltyCard < ApplicationRecord
  belongs_to :user

  before_create :generate_unique_card_number, :generate_barcode_data

  def barcode
    barcode = Barby::Code128B.new(card_number) # Code-barre basé sur le numéro unique
    Base64.encode64(barcode.to_png) # Encode en base64 pour affichage dans HTML
  end

  private

  def generate_unique_card_number
    self.card_number ||= loop do
      random_number = SecureRandom.alphanumeric(10).upcase
      break random_number unless LoyaltyCard.exists?(card_number: random_number)
    end
  end

  def generate_barcode_data
    self.barcode_data = card_number
  end
end
