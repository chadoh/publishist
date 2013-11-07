class Person < ActiveRecord::Base
  attr_accessible :name, :first_name, :middle_name, :last_name, :email, :password, :password_confirmation, :primary_publication_id, :primary_publication, :remember_me

  extend Memoist

  devise :database_authenticatable, :confirmable,
         :recoverable, :registerable, :rememberable, :trackable,
         :validatable

  attr_reader :password

  belongs_to :primary_publication, class_name: "Publication"

  has_many :submissions,        foreign_key: 'author_id'
  has_many :attendees,          dependent:   :destroy
  has_many :roles,              dependent:   :destroy
  has_many :meetings,           through:     :attendees
  has_many :positions,          through:     :roles
  has_many :position_abilities, through:     :positions
  has_many :abilities,          through:     :position_abilities
  has_many :magazines,          through:     :positions, uniq: true

  validates_presence_of :email

  extend FriendlyId
  friendly_id :name, :use => [:slugged, :history]

  include Gravtastic
  gravtastic :size => 200, :default => "http://s3.amazonaws.com/pcmag/children.png", :rating => 'R'

  def full_name
    if first_name || middle_name || last_name
      [first_name, middle_name, last_name].reject(&:blank?).join(' ')
    else
      email
    end
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

  def communicates? resource = primary_publication, *flags
    positions = positions_for resource, *flags
    positions.joins(:abilities).where(:abilities => { :key => "communicates" }).present?
  end

  def orchestrates? resource = primary_publication, *flags
    positions = positions_for(resource, *flags)
    positions.joins(:abilities).where(:abilities => { :key => "orchestrates" }).present?
  end

  def scores? resource
    positions = positions_for(resource)
    positions.joins(:abilities).where(:abilities => { :key => "scores" }).present?
  end

  def views? resource
    positions = positions_for(resource)
    positions.joins(:abilities).where("abilities.key in (?)", %w[communicates scores orchestrates views]).present?
  end

  class << self
    extend Memoist

    def find_or_create formatted_name_and_email, attrs = {}
      return nil if formatted_name_and_email.blank?
      name = formatted_name_and_email.gsub(',','').split
      email = name.delete_at(name.length - 1).gsub(/[<>]/, '')
      person = Person.find_by_email email
      unless person
        if name.present? && email.present?
          person = Person.new attrs.merge(email: email)
          person.name = name.join(' ')
          person = person.save ? person : nil
        end
      end
      person
    end

    memoize :find_or_create
  end

  memoize :full_name, :name_and_email, :name, :can_enter_scores_for?

  private

    def positions_for(resource, *flags)
      return positions_for_publication(resource, *flags) if resource.is_a?(Publication)
      positions_for_magazine(resource, *flags)
    end

    def positions_for_magazine(resource, *flags)
      resource = resource.magazine unless resource.is_a?(Magazine)
      magazines = [resource]
      if flags.include? :or_adjacent
        magazines << Magazine.before(resource)
        magazines << Magazine.after(resource)
        magazines.compact!
      end
      self.positions.where("magazine_id IN (?)", magazines.map(&:id))
    end

    def positions_for_publication(publication, *flags)
      this = positions.joins(:magazine).where(:magazines => { :publication_id => publication.id })
      return this unless flags.include? :nowish
      this.where("magazines.accepts_submissions_until > ?", 1.week.ago)
    end
end
