# == Schema Information
#
# Table name: installation_configs
#
#  id               :bigint           not null, primary key
#  locked           :boolean          default(TRUE), not null
#  name             :string           not null
#  serialized_value :jsonb            not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_installation_configs_on_name                 (name) UNIQUE
#  index_installation_configs_on_name_and_created_at  (name,created_at) UNIQUE
#
class InstallationConfig < ApplicationRecord
  before_validation :set_lock
  validates :name, presence: true
  validate :saml_sso_users_check, if: -> { name == 'ENABLE_SAML_SSO_LOGIN' }

  # TODO: Get rid of default scope
  # https://stackoverflow.com/a/1834250/939299
  default_scope { order(created_at: :desc) }
  scope :editable, -> { where(locked: false) }

  after_commit :clear_cache

  def value
    # Compatibilidade durante migração YAML -> JSONB
    val = serialized_value

    # Extrair valor de Hash JSONB primeiro
    if val.is_a?(Hash)
      val = val['value'] || val[:value]
    end

    # Se o resultado for string YAML, fazer parse
    if val.is_a?(String) && val.start_with?('---')
      begin
        parsed = YAML.safe_load(val, permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol], aliases: true)
        # Se parseou para um Hash com chave 'value', extrair recursivamente
        val = parsed.is_a?(Hash) ? (parsed['value'] || parsed[:value] || parsed) : parsed
      rescue StandardError
        # Se falhar o parse, retorna a string original
      end
    end

    val
  end

  def value=(value_to_assigned)
    self.serialized_value = {
      value: value_to_assigned
    }.with_indifferent_access
  end

  private

  def set_lock
    self.locked = true if locked.nil?
  end

  def clear_cache
    GlobalConfig.clear_cache
  end

  def saml_sso_users_check
    return unless value == false || value == 'false'
    return unless User.exists?(provider: 'saml')

    errors.add(:base, 'Cannot disable SAML SSO login while users are using SAML authentication')
  end
end
