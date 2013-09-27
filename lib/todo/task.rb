# coding: utf-8

require 'active_record'


module Todo

  # tasks table model
  # @author yoshiso
  class Task < ActiveRecord::Base
    NOT_YET = 0 # not finish task
    DONE = 1    # finish task
    PENDING = 2 # pending task
    STATUS = {
      'NOT_YET' => NOT_YET,
      'DONE' => DONE,
      'PENDING' => PENDING
    }.freeze

    scope :status_is, ->(status){where(status: status)}

    validates :name, presence: true, length: {maximum: 140}
    validates :content, presence: true
    validates :status, numericality: true, inclusion: {in: STATUS.values}

    def status_name
      STATUS.key(self.status)
    end
  end

end
