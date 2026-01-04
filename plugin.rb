# frozen_string_literal: true

# name: discourse-gitee-login
# about: 允许用户使用 Gitee OAuth2 登录到您的 Discourse 论坛。
# version: 0.0.1
# authors: 徐晓伟<xuxiaowei@xuxiaowei.com.cn>
# url: http://github.com/xuxiaowei-com-cn/discourse-gitee-login

# 引入自定义的 Gitee OAuth2 策略
require_relative "lib/omniauth/strategies/gitee"

# 注册 Gitee SVG 图标
register_svg_icon "gitee"

# 启用插件设置项，允许在管理面板中控制插件的启用状态
enabled_site_setting :gitee_login_enabled

# Gitee 认证器类，继承自 Discourse 的托管认证器
# 负责处理 Gitee OAuth2 认证流程
class GiteeAuthenticator < ::Auth::ManagedAuthenticator
  # 返回认证器名称
  def name
    "gitee"
  end

  # 检查插件是否已启用
  def enabled?
    SiteSetting.gitee_login_enabled?
  end

  # 返回 Gitee 提供商的基础 URL
  def provider_url
    "https://gitee.com"
  end

  # 注册 OmniAuth 中间件，配置 Gitee OAuth2 策略
  # @param omniauth [OmniAuth::Builder] OmniAuth 构建器实例
  def register_middleware(omniauth)
    omniauth.provider :gitee,
                      setup: lambda { |env|
                        # 获取当前策略实例
                        strategy = env["omniauth.strategy"]
                        
                        # 从站点设置中获取客户端 ID 和密钥
                        strategy.options[:client_id] = SiteSetting.gitee_login_client_id
                        strategy.options[:client_secret] = SiteSetting.gitee_login_client_secret
                        
                        # 配置 Gitee API 客户端选项
                        strategy.options[:client_options] = {
                          site: "https://gitee.com",
                          authorize_url: "/oauth/authorize",  # 授权 URL
                          token_url: "/oauth/token"         # 令牌 URL
                        }
                        
                        # 设置请求的权限范围
                        strategy.options[:scope] = "user_info"  # 请求用户信息权限
                      }
  end

  # 标记 Gitee 提供的主邮箱为已验证
  # @param auth_token [Hash] 认证令牌信息
  # @return [Boolean] 始终返回 true，表示邮箱已验证
  def primary_email_verified?(auth_token)
    true
  end
end

# 注册认证提供商，设置按钮标题、图标和认证器
auth_provider title_setting: "gitee_login_button_title", icon: "gitee", authenticator: GiteeAuthenticator.new
