#!/usr/bin/env ruby
require_relative "../app/init"

Relay::Models::User.create(
  name: "0x1eef",
  email: "0x1eef@hardenedbsd.org",
  password: "relay"
)
