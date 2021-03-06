module Octokit
  module Models
    struct ActivityWatching
      Octokit.rest_model(
        subscriptions: Bool,
        ignored: Bool,
        reason: String,
        created_at: String,
        url: String,

        # Only populated for repository subscriptions
        repository_url: String?,

        # Only populated for thread subscriptions
        thread_url: String?
      )
    end
  end
end
