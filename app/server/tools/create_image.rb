# frozen_string_literal: true

module Server::Tool
  class CreateImage < LLM::Tool
    name "create-image"
    description "Create a generated image"
    param :prompt, String, "The prompt", required: true
    param :provider, Enum["openai", "gemini", "xai"], "The provider", default: "xai"
    param :n, Integer, "The number of images to generate", default: 1

    ##
    # Returns a HTML link for an image
    # @return [Hash]
    def call(prompt:, provider: "xai", n: 1)
      key  = ENV["#{provider.upcase}_SECRET"]
      llm  = LLM.method(provider).call(key:)
      res  = llm.images.create(prompt:, n:)
      res.images.each do |image|
        file = "#{SecureRandom.hex}.png"
        IO.copy_stream image, File.join(images_dir, file)
      end
      { directions: 'embed the html in your response exactly as it appears', html: "<img src='/g/#{file}'>" }
    rescue LLM::RateLimitError => ex
      { error: ex.class.to_s, message: "rate limit reached" }
    rescue => ex
      { error: ex.class.to_s, message: ex.message }
    end

    private

    def project_root = File.realpath(File.join(__dir__, "..", ".."))
    def images_dir = File.join(project_root, "public", "g")
  end
end
