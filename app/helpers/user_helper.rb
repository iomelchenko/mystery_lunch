# frozen_string_literal: true

module UserHelper
  def avatar_for(user)
    return gravatar(user) unless user.avatar.present?

    image_tag user.avatar.variant(resize: "75x75")
  end

  def gravatar(user)
    image_tag("#{::User::GRAVATAR_URL}?gravatar_id=#{Digest::MD5::hexdigest(user.email)}?d=wavatar")
  end
end
