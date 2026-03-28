# frozen_string_literal: true

module Relay::Routes
  class Settings::SetModel < Base
    prepend Relay::Hooks::RequireUser

    def call
      set_model
      partial("fragments/settings/set_model", locals:)
    end

    private

    def set_model
      session["model"] = params["model"]
    end

    def locals
      {user:, models: cache.models}
    end
  end
end
