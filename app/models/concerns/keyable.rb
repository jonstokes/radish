module Keyable
  extend ActiveSupport::Concern

  included do
    validates :key, presence: true, uniqueness: true

    before_validation do
      self[:key] = self.class.to_key(name)
    end
  end

  module ClassMethods
    def find_by_key(string)
      find_by(key: to_key(string))
    end

    def to_key(string)
      string.upcase.gsub(/[^\w\s]/, ' ').squish
    end
  end
end