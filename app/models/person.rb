# == Schema Information
# Schema version: 20110516234654
#
# Table name: people
#
#  id                   :integer         not null, primary key
#  first_name           :string(255)
#  middle_name          :string(255)
#  last_name            :string(255)
#  email                :string(255)
#  encrypted_password   :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  verified             :boolean
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer         default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  password_salt        :string(255)
#  cached_slug          :string(255)
#

#require 'digest/sha2'

class Person < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  devise :database_authenticatable, :omniauthable, :confirmable,
         :recoverable, :registerable, :rememberable, :trackable,
         :validatable

  attr_reader :password

  has_many :ranks,       dependent:   :destroy
  has_many :submissions, foreign_key: 'author_id'
  has_many :attendees,   dependent:   :destroy
  has_many :meetings,    through:     :attendees
  has_many :roles,       dependent:   :nullify

  validates_presence_of :first_name

  default_scope includes(:ranks)

  has_friendly_id :name, :use_slug => true

  include Gravtastic
  gravtastic :size => 200, :default => "http://s3.amazonaws.com/pcmag/children.png", :rating => 'R'

  def name
    "#{first_name}#{" #{last_name}" if last_name}"
  end

  def full_name
    "#{first_name}#{" #{middle_name}" if middle_name}#{" #{last_name}" if last_name}"
  end

  def editor?
    rank = self.highest_rank
    rank = rank.rank_type if rank
    rank == 2 || rank == 3
  end

  def the_editor?
    rank = self.highest_rank
    rank = rank.rank_type if rank
    rank == 3
  end

  def the_coeditor?
    rank = self.highest_rank
    rank = rank.rank_type if rank
    rank == 2
  end

  def is_staff?
    self.ranks.where(:rank_end => nil).collect {|r| r.rank_type }.include? 1
  end

  def highest_rank
    self.ranks.where(:rank_end => nil).order("rank_type").last
  end

  def editorships
    self.ranks.where(:rank_type => 3).collect do |r|
      if r.rank_end
        "from #{r.rank_start.strftime("%e %b %Y")} until #{r.rank_end.strftime("%e %b %Y")}"
      else
        "since #{r.rank_start.strftime("%e %b %Y")}"
      end
    end
  end

  def coeditorships
    self.ranks.where(:rank_type => 2).collect do |r|
      if r.rank_end
        "from #{r.rank_start.strftime("%e %b %Y")} until #{r.rank_end.strftime("%e %b %Y")}"
      else
        "since #{r.rank_start.strftime("%e %b %Y")}"
      end
    end
  end

  def staffships
    self.ranks.where(:rank_type => 1).collect do |r|
      if r.rank_end
        "from #{r.rank_start.strftime("%e %b %Y")} until #{r.rank_end.strftime("%e %b %Y")}"
      else
        "since #{r.rank_start.strftime("%e %b %Y")}"
      end
    end
  end

  def current_ranks
    ranks = self.ranks.where(:rank_end => nil)
    ranks.collect do |r|
      rank = r.rank_type
      if rank == 1
        "Staff"
      elsif rank == 2
        "Coeditor"
      else rank == 3
        "Editor"
      end
    end
  end

  def can_enter_scores_for? meeting
    unless attendee = Attendee.find_by_person_id_and_meeting_id(self.id, meeting.id)
      false
    else
      if (scores = attendee.scores).empty?
        true
      else
        if scores.select {|s| s.entered_by_coeditor? }.empty?
          true
        else
          false
        end
      end
    end
  end

  def name_and_email
    "#{full_name}, #{email}"
  end

  def to_s
    name
  end

  # function to set the password without knowing the current password used in our confirmation controller.
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end
  # function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # function to provide access to protected method unless_confirmed
  def only_if_unconfirmed
    unless_confirmed {yield}
  end

  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  class << self
    extend ActiveSupport::Memoizable

    def editors
      ranks = Rank.where(:rank_type => 2..3, :rank_end => nil)
      ranks = ranks.sort_by {|a| a.rank_type }
      ranks.collect {|r| r.person}
    end
    def editor
      rank = Rank.where(rank_type: 3, rank_end: nil).first.try(:person)
    end
    def coeditor
      rank = Rank.where(:rank_type => 2, :rank_end => nil).first
      rank.person if rank
    end
    def chad
      chad = Person.find_by_email "chad.ostrowski@gmail.com"
    end
    def find_or_create formatted_name_and_email
      email = formatted_name_and_email.split(' ').last
      person = Person.find_by_email email
    end

    memoize :editors, :editor, :coeditor, :find_or_create
  end

  memoize :full_name, :name_and_email, :name, :editor?, :the_editor?, :the_coeditor?, :is_staff?, :current_ranks, :can_enter_scores_for?, :staffships, :coeditorships, :editorships, :highest_rank
end
