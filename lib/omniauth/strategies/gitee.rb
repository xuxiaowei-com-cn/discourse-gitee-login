# frozen_string_literal: true

# 引入 OmniAuth OAuth2 基础策略
require "omniauth-oauth2"

# Gitee OAuth2 策略类，继承自 OmniAuth::Strategies::OAuth2
# 实现与 Gitee OAuth2 API 的交互，获取用户信息
class OmniAuth::Strategies::Gitee < ::OmniAuth::Strategies::OAuth2
  # 设置策略名称
  option :name, "gitee"

  # 获取用户唯一标识符
  # @return [String] Gitee 用户 ID
  uid do
    raw_info["id"]
  end

  # 构建用户信息哈希
  # @return [Hash] 包含用户基本信息的哈希
  info do
    {
      name: raw_info["name"],        # 用户姓名
      nickname: raw_info["login"],   # 用户登录名
      email: raw_info["email"],      # 用户邮箱
      image: raw_info["avatar_url"]  # 用户头像 URL
    }
  end

  # 构建额外信息哈希
  # @return [Hash] 包含原始用户信息的哈希
  extra do
    {
      "raw_info" => raw_info  # 原始用户信息
    }
  end

  # 获取 Gitee API 返回的原始用户信息
  # @return [Hash] Gitee API 返回的用户信息
  def raw_info
    # 缓存原始用户信息，避免重复请求
    @raw_info ||= access_token.get("/api/v5/user").parsed
  end

  # 自定义回调 URL，确保使用 Discourse 基础 URL
  # @return [String] 完整的回调 URL
  def callback_url
    Discourse.base_url_no_prefix + script_name + callback_path
  end
end
