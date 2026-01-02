# frozen_string_literal: true

require "omniauth-oauth2"

class OmniAuth::Strategies::Gitee < ::OmniAuth::Strategies::OAuth2
  option :name, "gitee"

  uid do
    raw_info["id"]
  end

  info do
    {
      name: raw_info["name"],
      nickname: raw_info["login"],
      email: raw_info["email"],
      image: raw_info["avatar_url"]
    }
  end

  extra do
    {
      "raw_info" => raw_info
    }
  end

  def raw_info
    @raw_info ||= access_token.get("/api/v5/user").parsed
  end

  def callback_url
    Discourse.base_url_no_prefix + script_name + callback_path
  end
end
