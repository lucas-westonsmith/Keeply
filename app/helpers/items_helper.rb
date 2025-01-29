module ItemsHelper
  def cloudinary_invoice_url(item)
    return unless item.invoice.attached?

    # Déterminer l'environnement (production ou development)
    env_folder = Rails.env.production? ? "production" : "development"

    # Récupérer la clé Cloudinary
    invoice_key = item.invoice.key

    # Récupérer la bonne version de l'asset depuis Cloudinary
    begin
      asset_details = Cloudinary::Api.resource("#{env_folder}/#{invoice_key}", type: "upload", resource_type: "image")
      version = asset_details["version"]
      "https://res.cloudinary.com/#{Cloudinary.config.cloud_name}/image/upload/v#{version}/#{env_folder}/#{invoice_key}.pdf"
    rescue StandardError => e
      Rails.logger.error "Cloudinary Error: #{e.message}"
      nil
    end
  end
end
