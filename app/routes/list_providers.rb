# frozen_string_literal: true

module Relay::Routes
  class ListProviders < Base
    prepend Hooks::RequireUser

    def call
      partial("fragments/providers")
    end
  end
end
