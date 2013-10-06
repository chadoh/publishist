class Person < ActiveRecord::Base
  extend Memoist

  devise :database_authenticatable, :confirmable,
         :recoverable, :registerable, :rememberable, :trackable,
         :validatable

  attr_reader :password

  has_many :submissions,        foreign_key: 'author_id'
  has_many :attendees,          dependent:   :destroy
  has_many :roles,              dependent:   :destroy
  has_many :meetings,           through:     :attendees
  has_many :positions,          through:     :roles
  has_many :position_abilities, through:     :positions
  has_many :abilities,          through:     :position_abilities

  validates_presence_of :first_name
  validates_presence_of :email

  extend FriendlyId
  friendly_id :name, :use => [:slugged, :history]

  include Gravtastic
  gravtastic :size => 200, :default => "http://s3.amazonaws.com/pcmag/children.png", :rating => 'R'

  def full_name
    [first_name, middle_name, last_name].reject{|n| n.blank? }.join(' ')
  end
  alias :name :full_name

  def name= name
    name = name.split(' ')
    self.first_name = name.delete_at(0).try(:gsub, /['"]/, '')
    self.last_name = name.delete_at(name.length - 1).try(:gsub, /['"]/, '')
    self.middle_name = name.join(' ')
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

  def magazines
    self.position_abilities.collect(&:magazine).flatten.uniq
  end

  def magazines_with_meetings
    magazines.reject{|m| m.meetings.empty? }.sort_by(&:accepts_submissions_from).reverse
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


  # ABILITIES
  #

  def communicates? resource
    resource = :any if resource.nil?
    if resource.is_a?(Symbol)
      # currently only accepting ':now/:currently' and ':any'
      if resource == :now or resource == :currently or resource == :current
        mag_ids = Magazine.where("accepts_submissions_until > ?", 1.week.ago).collect(&:id)
        positions = self.positions.select{|p| mag_ids.include? p.magazine_id }
      elsif resource == :any
        positions = self.positions
      end
    else
      magazine = resource.is_a?(Magazine) ? resource : resource.magazine
      positions = self.positions.select{|p| p.magazine == magazine}
    end
    positions.collect(&:abilities).flatten.select{|a| a.key == 'communicates' }.present? if positions
  end

  def orchestrates? resource, *flags
    resource = :any if resource.nil?
    if resource.is_a?(Symbol)
      # currently only accepting ':now/:currently' and ':any'
      if resource == :now or resource == :currently or resource == :current
        mag_ids = Magazine.where("accepts_submissions_until > ?", 1.week.ago).collect(&:id)
        positions = self.positions.select{|p| mag_ids.include? p.magazine_id }
      elsif resource == :any
        positions = self.positions
      end
    else
      magazine = resource.is_a?(Magazine) ? resource : resource.magazine
      mag_ids = [magazine.id]
      if flags.first # only accepting :or_adjacent right now, so just accepting everything
        if before = Magazine.before(magazine) then mag_ids << before.id end
        if after  = Magazine.after(magazine)  then mag_ids << after.id  end
      end
      positions = self.positions.select{|p| mag_ids.include? p.magazine.id }
    end
    positions.collect(&:abilities).flatten.select{|a| a.key == 'orchestrates' }.present? if positions
  end

  def scores? resource
    magazine = resource.is_a?(Magazine) ? resource : resource.magazine
    self.positions.select{|p| p.magazine == magazine}\
      .collect(&:abilities).flatten\
      .select{|a| a.key == 'scores' }.present?
  end

  def views? resource, *flags
    resource = :any if resource.nil?
    if resource.is_a?(Symbol)
      # The only resource currently being passed is the symbol :any.
      # Since we don't have to be aware of any others, let's accept any
      if flags.first # only accepting :with_meetings right now, so just accepting everything
        positions = self.positions.reject {|p| p.magazine.meetings.empty? }
      else
        positions = self.positions
      end
    else
      magazine = resource.is_a?(Magazine) ? resource : resource.magazine
      positions = self.positions.select{|p| p.magazine == magazine}
    end
    positions.collect(&:abilities).flatten\
      .select{|a| a.key == 'views' || a.key == 'orchestrates' }.present? if positions
  end

  class << self
    extend Memoist

    def current_communicators
      mag = Magazine.current || Magazine.first
      pos = mag.positions.joins(:abilities).where(abilities: { key: 'communicates' }) if mag
      pos ? pos.collect(&:people).flatten.uniq : []
    end

    def current_scorers
      mag = Magazine.current || Magazine.first
      pos = mag.positions.joins(:abilities).where(abilities: { key: 'scores' }) if mag
      pos ? pos.collect(&:people).flatten.uniq : []
    end

    def find_or_create formatted_name_and_email
      return nil if formatted_name_and_email.blank?
      name = formatted_name_and_email.gsub(',','').split
      email = name.delete_at(name.length - 1).gsub(/[<>]/, '')
      person = Person.find_by_email email
      unless person
        if name.present? && email.present?
          person = Person.new(email: email)
          person.name = name.join(' ')
          person = person.save ? person : nil
        end
      end
      person
    end

    memoize :find_or_create
  end

  memoize :full_name, :name_and_email, :name, :can_enter_scores_for?
end
