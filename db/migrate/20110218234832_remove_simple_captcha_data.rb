class RemoveSimpleCaptchaData < ActiveRecord::Migration
  def self.up
    drop_table :simple_captcha_data
  end

  def self.down
  end
end
