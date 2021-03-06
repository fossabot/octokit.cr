module Octokit
  module Models
    struct Migration
      Octokit.rest_model(
        id: Int64,
        guid: String,

        state: String,

        lock_repositories: Bool,

        exclude_attachments: Bool,
        url: String,
        created_at: String,
        updated_at: String,
        repositories: Array(Repository)
      )
    end

    struct MigrationOptions
      Octokit.rest_model(
        lock_repositories: Bool,
        exclude_attachments: Bool
      )
    end

    struct StartMigration
      Octokit.rest_model(
        repositories: Array(String),

        lock_repositories: Bool?,

        exclude_attachments: Bool?
      )
    end
  end
end
