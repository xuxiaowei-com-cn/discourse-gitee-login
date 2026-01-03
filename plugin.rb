# frozen_string_literal: true

# name: discourse-gitee-login
# about: 允许用户使用 Gitee OAuth2 登录到您的 Discourse 论坛。
# version: 0.0.1
# authors: 徐晓伟<xuxiaowei@xuxiaowei.com.cn>
# url: http://github.com/xuxiaowei-com-cn/discourse-gitee-login

require_relative "lib/omniauth/strategies/gitee"

register_svg_icon "gitee"

enabled_site_setting :gitee_login_enabled

class GiteeAuthenticator < ::Auth::ManagedAuthenticator
  def name
    "gitee"
  end

  def enabled?
    SiteSetting.gitee_login_enabled?
  end

  def provider_url
    "https://gitee.com"
  end

  def register_middleware(omniauth)
    omniauth.provider :gitee,
                      setup: lambda { |env|
                        strategy = env["omniauth.strategy"]
                        strategy.options[:client_id] = SiteSetting.gitee_login_client_id
                        strategy.options[:client_secret] = SiteSetting.gitee_login_client_secret
                        strategy.options[:client_options] = {
                          site: "https://gitee.com",
                          authorize_url: "/oauth/authorize",
                          token_url: "/oauth/token"
                        }
                        strategy.options[:scope] = "user_info"
                      }
  end

  def primary_email_verified?(auth_token)
    true
  end
end

auth_provider title_setting: "gitee_login_button_title", icon: "gitee", authenticator: GiteeAuthenticator.new
