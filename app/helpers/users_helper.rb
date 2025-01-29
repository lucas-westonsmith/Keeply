module UsersHelper
  def cloudinary_avatar_url(user)
    return unless user.avatar.attached?

    # Récupérer la clé Cloudinary
    avatar_key = user.avatar.key

    # Récupérer la bonne version de l'asset depuis Cloudinary
    begin
      asset_details = Cloudinary::Api.resource("#{Rails.env}/#{avatar_key}", type: "upload", resource_type: "image")
      version = asset_details["version"]
      "https://res.cloudinary.com/#{Cloudinary.config.cloud_name}/image/upload/v#{version}/#{Rails.env}/#{avatar_key}.jpg"
    rescue StandardError => e
      Rails.logger.error "Cloudinary error: #{e.message}"
      nil
    end
  end
end
