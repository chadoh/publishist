# Use this to implement the "Honey Pot" method of spam prevention
# http://www.ngenworks.com/blog/invisible_captcha_to_prevent_form_spam/
module HoneyPot
  attr_accessor :preference, :encoding, :legality, :tolerance, :mean
end
