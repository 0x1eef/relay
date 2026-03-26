# frozen_string_literal: true

module Relay::Routes
  class SignInPage < Base
    def call
      response["content-type"] = "text/html"
      page("sign_in", title: "Sign In")
    end
  end
end
