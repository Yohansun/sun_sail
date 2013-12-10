# -*- encoding : utf-8 -*-
module MagicAutoSettings

  def check_auto_settings(settings={})
    ['unusual_conditions', 'dispatch_conditions', 'notify_conditions'].each do |conditions|
      settings[conditions]  = {} if settings[conditions].blank?
    end
    settings
  end

  def change_auto_settings(account, update_params)
    settings = decorate_auto_settings(update_params)
    account.settings.auto_settings = account.settings.auto_settings.update(settings)
    settings = account.settings.auto_settings || {}
    settings
  end

  def decorate_auto_settings(hash)
    hash.each do |key, value|
      if value.is_a?(Hash)
        value.each do |sub_key, sub_value|
          hash[key][sub_key] = 1 if sub_value == "on"
          hash[key][sub_key] = nil if sub_value == "off"
        end
      else
        hash[key] = 1 if value == "on"
        hash[key] = nil if value == "off"
      end
    end

    hash
  end
end