module Octokit
  class Client
    # Methods for the Repositories API
    #
    # **See Also:**
    # - [https://developer.github.com/v3/repos/](https://developer.github.com/v3/repos/)
    module Repositories
      # :nodoc:
      alias Repository = Models::Repository

      # Check if a repository exists.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#get](https://developer.github.com/v3/repos/#get)
      def repository?(repo)
        !!repository(repo)
      rescue Octokit::Error::InvalidRepository
        false
      rescue Octokit::Error::NotFound
        false
      end

      # Get a single repository
      #
      # **Aliases:** `repo`
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#get](https://developer.github.com/v3/repos/#get)
      # - [https://developer.github.com/v3/licenses/#get-a-repositorys-license](https://developer.github.com/v3/licenses/#get-a-repositorys-license)
      def repository(path)
        res = get Repository.path(path)
        Repository.from_json(res)
      end

      alias_method :repository, :repo

      # Edit a repository.
      #
      # **Example:**
      # ```
      # @client.edit_repository("watzon/cadmium", has_wiki: true)
      # ```
      #
      # Available edit options are stored in `Octokit::Models::CreateRepoRequest`
      #
      # **Aliases:** `edit`, `update`, `update`
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#edit](https://developer.github.com/v3/repos/#edit)
      def edit_repository(repo : String | Repository, **options)
        name = Repository.get_name(repo)
        options = {name: name}.merge(options)
        res = post "repos/#{repo}", {json: options}
        Repository.from_json(res)
      end

      alias_method :edit_repository, :edit
      alias_method :edit_repository, :update_repository
      alias_method :edit_repository, :update

      # List user repositories.
      #
      # If user is not supplied, repositories for the current
      # authenticated user are returned.
      #
      # **Aliases:** `list_repositories`, `list_repos`, `repos`
      #
      # **Note:** If the user provided is a GitHub organization, only the
      #   organization's public repositories will be listed. For retrieving
      #   organization repositories the `Organizations#organization_repositories`
      #   method should be used instead.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#list-your-repositories](https://developer.github.com/v3/repos/#list-your-repositories)
      # - [https://developer.github.com/v3/repos/#list-user-repositories](https://developer.github.com/v3/repos/#list-user-repositories)
      def repositories(user = nil, **options)
        paginate Repository, "#{User.path user}/repos", **options
      end

      alias_method :edit_repository, :list_repositories
      alias_method :edit_repository, :list_repos
      alias_method :edit_repository, :repos

      # List all repositories.
      #
      # This provides a dump of every public repository on Github, in the order
      # that they were created.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#list-all-public-repositories](https://developer.github.com/v3/repos/#list-all-public-repositories)
      def all_repositories(**options)
        paginate Repository, "repositories", **options
      end

      # Star a repository.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/activity/starring/#star-a-repository](https://developer.github.com/v3/activity/starring/#star-a-repository)
      def star(repo)
        boolean_from_response :put, "user/starred/#{Repository.get_full_name(repo)}"
      end

      # Unstar a repository.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/activity/starring/#unstar-a-repository](https://developer.github.com/v3/activity/starring/#unstar-a-repository)
      def unstar(repo)
        boolean_from_response :delete, "user/starred/#{Repository.get_full_name(repo)}"
      end

      # Watch a repository.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/activity/watching/#watch-a-repository-legacy](https://developer.github.com/v3/activity/watching/#watch-a-repository-legacy)
      def watch(repo)
        boolean_from_response :put, "user/watched/#{Repository.get_full_name(repo)}"
      end

      # Unwatch a repository.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/activity/watching/#stop-watching-a-repository-legacy](https://developer.github.com/v3/activity/watching/#stop-watching-a-repository-legacy)
      def unwatch(repo)
        boolean_from_response :put, "user/watched/#{Repository.get_full_name(repo)}"
      end

      # Fork a repository.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/forks/#create-a-fork](https://developer.github.com/v3/repos/forks/#create-a-fork)
      def fork(repo)
        post "#{Repository.path(repo)}/forks"
      end

      # Create a repository for a user or organization.
      #
      # **Aliases:** `create`, `create_repo`
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#create](https://developer.github.com/v3/repos/#create)
      def create_repository(repo, organization = nil, **options)
        name = Repository.get_name(repo)
        options = {name: name}.merge(options)

        if organization.nil?
          res = post "user/repos", {json: options}
        else
          res = post "#{Octokit::Models::Organization.path(organization)}/repos", {json: options}
        end

        Repository.from_json(res)
      end

      alias_method :create_repository, :create_repo
      alias_method :create_repository, :create

      # Delete a repository.
      #
      # **Aliases:** `delete_repo`
      #
      # **Note:** If OAuth is used, 'delete_repo' scope is required.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#delete-a-repository](https://developer.github.com/v3/repos/#delete-a-repository)
      def delete_repository(repo)
        boolean_from_response :delete, Repository.path(repo)
      end

      # Transfer a repository.
      #
      # Transfer a repository owned by your organization.
      #
      # **Aliases:** `transfer_repo`
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/#transfer-a-repository](https://developer.github.com/v3/repos/#transfer-a-repository)
      def transfer_repository(repo, new_owner, team_ids : Array(Int32))
        options = {new_owner: new_owner, team_ids: team_ids}
        res = post "#{Repository.path(repo)}/transfer", {json: options}
        Repository.from_json(res)
      end

      alias_method :transfer_repository, :transfer_repo

      # Hide a public repository.
      #
      # This is a convenience method that uses `#update_repository`
      def set_private(repo)
        update_repository repo, {private: true}
      end

      # Unhide a private repository.
      #
      # This is a convenience method that uses `#update_repository`
      def set_public(repo)
        update_repository repo, {private: false}
      end

      # Get deploy keys on a repo.
      #
      # Requires authenticated client.
      #
      # **Aliases:**
      # - [https://developer.github.com/v3/repos/keys/#list-deploy-keys](https://developer.github.com/v3/repos/keys/#list-deploy-keys)
      #
      # **Example:**
      # ```
      # @client.deploy_keys("watzon/cadmium")
      # ```
      def deploy_keys(repo)
        paginate Repository, "#{Repository.path(repo)}/keys"
      end

      alias_method :deploy_keys, :list_deploy_keys

      # Get a single deploy key for a repo.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/keys/#get-a-deploy-key](https://developer.github.com/v3/repos/keys/#get-a-deploy-key)
      #
      # **Example:**
      # ```
      # @client.deploy_key("watzon/cadmium", 7729435)
      # ```
      def deploy_key(repo, id)
        res = get "#{Repository.path(repo)}/keys/#{id}"
        RepositoryDeployKey.from_json(res)
      end

      # Add deploy key to a repo.
      #
      # Requires authenticated client.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/keys/#add-a-new-deploy-key](https://developer.github.com/v3/repos/keys/#add-a-new-deploy-key)
      #
      # **Example:**
      # ```
      # @client.deploy_key("watzon/cadmium", "Staging server", "ssh-rsa AAA...")
      # ```
      def add_deploy_key(repo, title, key, read_only = false)
        options = {title: title, key: key, read_only: read_only}
        res = post "#{Repository.path(repo)}/keys", {json: options}
        RepositoryDeployKey.from_json(res)
      end

      # Remove a deploy key from a repo.
      #
      # **Note:** Requires authenticated client.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/keys/#remove-a-deploy-key](https://developer.github.com/v3/repos/keys/#remove-a-deploy-key)
      #
      # **Example:**
      # ```
      # @client.remove_deploy_key("watzon/cadmium", 7729435)
      # ```
      def remove_deploy_key(repo, id)
        boolean_from_response :delete, "#{Repository.path(repo)}/keys/#{id}"
      end

      # List collaborators.
      #
      # **Aliases:** `collabs`
      #
      # **Note:** Requires authenticated client for private repos.
      #
      # **See Also:**
      # - [https://developer.github.com/v3/repos/collaborators/#list-collaborators](https://developer.github.com/v3/repos/collaborators/#list-collaborators)
      #
      # **Examples:**
      #
      # With unauthenticated client
      # ```
      # Octokit.collaborators("watzon/cadmium")
      # ```
      #
      # With authenticated client
      # ```
      # @client.collaborators("watzon/cadmium")
      # ```
      def collaborators(repo, affiliation = :all)
        options = {affiliation: affiliation.to_s}
        paginate User, "#{Repository.path(repo)}/collaborators", options: {json: options}
      end

      alias_method :collaborators, :collabs
    end
  end
end
