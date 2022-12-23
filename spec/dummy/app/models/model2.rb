# frozen_string_literal: true

class Model2 < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :database2, reading: :database2 }
end
