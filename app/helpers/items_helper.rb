module ItemsHelper
  def cloudinary_invoice_url(item)
    return unless item.invoice.attached?

    # Récupérer la clé Cloudinary
    invoice_key = item.invoice.key

    # Récupérer la bonne version de l'asset depuis Cloudinary
    begin
      asset_details = Cloudinary::Api.resource("development/#{invoice_key}", type: "upload", resource_type: "image")
      version = asset_details["version"]
      "https://res.cloudinary.com/#{Cloudinary.config.cloud_name}/image/upload/v#{version}/development/#{invoice_key}.pdf"
    rescue StandardError => e
      Rails.logger.error "Erreur Cloudinary: #{e.message}"
      nil
    end
  end
end
