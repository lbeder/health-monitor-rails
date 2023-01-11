# frozen_string_literal: true

class Model1 < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :database1, reading: :database1 }
end
