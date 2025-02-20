# frozen_string_literal: true
# typed: true

class FeatureFlag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def self.enabled?(name)
    feature = find_or_create_by(name: name.to_s) do |flag|
      flag.enabled = false
    end
    feature.enabled
  end
end
