module ListsHelper
  def cloudinary_list_photo_url(list)
    return unless list.photo.attached?

    # Déterminer l’environnement (production ou development)
    env_folder = Rails.env.production? ? "production" : "development"

    # Récupérer la clé Cloudinary
    photo_key = list.photo.key

    # Récupérer l'URL Cloudinary avec la bonne version
    begin
      asset_details = Cloudinary::Api.resource("#{env_folder}/#{photo_key}", type: "upload", resource_type: "image")
      version = asset_details["version"]
      "https://res.cloudinary.com/#{Cloudinary.config.cloud_name}/image/upload/v#{version}/#{env_folder}/#{photo_key}.jpg"
    rescue StandardError => e
      Rails.logger.error "Cloudinary Error: #{e.message}"
      nil
    end
  end
end
