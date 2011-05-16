class Submission < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  belongs_to :author, :class_name => "Person"
  has_many :packlets, :dependent  => :destroy
  has_many :meetings, :through    => :packlets
  has_many :scores,   :through    => :packlets

  has_friendly_id :to_slug, :use_slug => true

  validate "errors.add :author_email, 'must be filled in. Or you can sign in.'",
    :if => Proc.new {|s| s.author_id.blank? && s.author_email.blank? }
  validate "self.author_name = 'Anonymous'",
    :if => Proc.new {|s| s.author_id.blank? && s.author_name .blank? }
  validate "errors.add :body, 'cannot be blank.'",
    :if => Proc.new {|s| s.body.blank? && s.title.blank? }

  after_find :reviewed_if_meeting_has_occurred

  def magazine
    self.reload.meetings.first.try(:magazine)
  end

  acts_as_enum :state, [:draft, :submitted, :queued, :reviewed, :scored, :rejected, :published]

  validates_attachment_content_type :photo, 
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if => Proc.new { |submission| submission.photo.file? },
    :message => "must be an image"

  has_attached_file :photo,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "/:style/:filename",
    :styles => { :medium => "510x510>" }

  def author_name
    @author_name ||= if read_attribute :author_id
      @author ||= Person.find(read_attribute(:author_id))
      @author.name
    else
      read_attribute :author_name
    end
  end

  def author_first
    @author_first ||= if read_attribute(:author_id)
      @author ||= Person.find(read_attribute(:author_id))
      @author.first_name
    else
      author_name.split(' ').first
    end
  end

  def email
    @email ||= if read_attribute(:author_id)
      @author ||= Person.find(read_attribute(:author_id))
      @author.email
    else
      read_attribute(:author_email)
    end
  end

  def has_been moved_to_state, options = {}
    if moved_to_state == :submitted
      Notifications.new_submission(self).deliver if (options[:by].blank? or Person.editor.presence != options[:by])
    end
    update_attributes :state => moved_to_state
  end

  [:draft, :submitted, :queued, :reviewed, :scored, :published, :rejected].each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def average_score
    @average_score ||= begin
      packlet_ids = self.packlets.collect &:id
      score = Score.average 'amount', :conditions => "packlet_id IN (#{packlet_ids.join ','})"
      (score * 100).round.to_f / 100
    end
  end

  def to_s
    @to_s ||= strip_tags(self.title).presence || strip_tags(self.body.lines.first)
  end

  def to_slug
    strip_tags(self.title).gsub(/[^0-9A-Z\s]/i, '').presence || strip_tags(self.body.lines.first)
  end

protected

  def reviewed_if_meeting_has_occurred
    if queued?
      if meetings.select {|m| m.datetime < Time.now + 3.hours }.present?
        update_attribute :state, Submission.state(:reviewed)
      end
    end
  end

end
