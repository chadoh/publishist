class DeviseAlterPeopleAndDropSessions < ActiveRecord::Migration
  def self.up
    drop_table :sessions
    change_table(:people) do |t|
      t.rename :salt, :password_salt
      #t.remove :verified
      #t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

    end

    add_index :people, :email,                :unique => true
    add_index :people, :reset_password_token, :unique => true
    add_index :people, :confirmation_token,   :unique => true
    # add_index :people, :unlock_token,         :unique => true
  end

  def self.down
    create_table :sessions do |t|
      t.belongs_to :person
      t.string :path, :ip_address
      t.timestamps
    end
    change_table :people do |t|
      t.rename  :password_salt, :salt
      t.boolean :verified
      t.remove  :confirmation_token, :confirmed_at,
                :confirmation_sent_at, :reset_password_token,
                :remember_token, :remember_created_at,
                :sign_in_count, :current_sign_in_at,
                :last_sign_in_at, :current_sign_in_ip,
                :last_sign_in_ip
    end

    remove_index :people, :email
  end
end
