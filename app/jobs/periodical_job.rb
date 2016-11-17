# frozen_string_literal: true
class PeriodicalJob < ApplicationJob
  queue_as :default

  def perform
    Marketplace.all.each do |marketplace|
      MWS::ImportService.initial_import(marketplace)
    end
  end
end
