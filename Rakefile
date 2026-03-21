# frozen_string_literal: true

require_relative "app/init"

load "tasks/db.rake"
load "tasks/dev.rake"

namespace :assets do
  desc "Build frontend assets"
  task :build do
    sh "npm --prefix app/assets run assets:build"
  end
end
