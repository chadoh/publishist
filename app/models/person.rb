require 'digest/sha2'

class Person < ActiveRecord::Base
  attr_reader :password

  ENCRYPT = Digest::SHA256

  has_many :sessions, :dependent => :destroy
  has_many :ranks, :dependent => :destroy
  has_many :compositions, :foreign_key => 'author_id'
  has_many :attendances
  has_many :meetings, :through => :attendances

  validates_presence_of :email
  validates_uniqueness_of :email, :message => "has already been used by someone else"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    :on => :create
  validates_format_of :password, :with => /\A([\x20-\x7E]){6,}\Z/,
    :message => "must be at least 6 characters",
    :unless => :password_is_not_being_updated?
  validates_confirmation_of :password
  validates_presence_of :first_name

  before_create :n00b_salt, :if => Proc.new { self.password.blank? }
  after_save :flush_passwords

  is_gravtastic :email, :size => 200, :default => "http://pcmag.heroku.com/images/children.png", :rating => 'R'

  def self.find_by_email_and_password(email, password)
    person = self.find_by_email(email)
    if person and person.encrypted_password == ENCRYPT.hexdigest(password + "chrouiNt" + person.salt)
      return person
    end
  end

  def password=(password)
    @password = password
    unless password_is_not_being_updated?
      self.salt = [Array.new(9){rand(256).chr}.join].pack('m').chomp
      self.encrypted_password = ENCRYPT.hexdigest(password + "chrouiNt" + self.salt)
      self.verified = true
    end
  end


  # CONVENIENCES
  def name
    "#{self.first_name} #{self.last_name}"
  end

  def full_name
    "#{self.first_name} #{self.middle_name} #{self.last_name}"
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

  class << self
    def editors
      ranks = Rank.where(:rank_type => 2..3, :rank_end => nil)
      ranks = ranks.sort_by {|a| a.rank_type }
      ranks.collect {|r| r.person}
    end
    def editor
      rank = Rank.where(:rank_type => 3, :rank_end => nil).first
      rank.person if rank
    end
    def coeditor
      rank = Rank.where(:rank_type => 2, :rank_end => nil).first
      rank.person if rank
    end
    def chad
      chad = Person.find_by_email "chad.ostrowski@gmail.com"
    end
    def find_or_create formatted_name_and_email
      if formatted_name_and_email =~ /\A.+<.+>\Z/
        email = formatted_name_and_email.scan(/<.+>/).first.delete "<>"
        person = Person.find_by_email email
        unless person
          names = formatted_name_and_email.scan(/.+</).first.gsub(/["<>[:cntrl:]]/, '').split(' ')
          first = names.delete_at(0)
          last = names.delete_at(names.length - 1) unless names.empty?
          middles = names.join(' ') unless names.empty?
          person = Person.create(
            :first_name => first, 
            :middle_name => middles, 
            :last_name => last, 
            :email => email
          )
        end
      else
        person = Person.new
        person.errors.add(:id, "must be in the format \"first_name middle_name last_name\" <email@ddress.com>")
      end 
      person
    end
  end

protected

  def n00b_salt
    self.salt = "n00b"
  end

  def flush_passwords
    @password = @password_confirmation = nil
  end

  def password_is_not_being_updated?
    (self.id and self.password.blank?) || (!self.id && self.password.blank?)
  end
end
