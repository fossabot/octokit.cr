module Octokit
  module Models
    struct PreReceiveHook
      rest_model(
        id: Int64,
        name: String,
        enforcement: String,
        config_url: String
      )
    end
  end
end