# frozen_string_literal: true

# Retrieve all the files from a directory within Github
class GithubImporter
  def initialize(oauth_token, repo)
    @gh = Octokit::Client.new(access_token: oauth_token)
    @repo = repo
  end

  # Yields to the block once for each file in the directory
  # @yield [path, file] Gives the filename and filecontents to the block for
  def import(path)
    gh.contents(repo, path: path).each do |resource|
      yield(resource.path, retrieve_file(resource))
    end
  end

  private

  attr_reader :gh, :repo

  def retrieve_file(resource)
    blob = gh.blob(repo, resource.sha)
    Base64.decode64(blob.content).force_encoding('UTF-8')
  end
end
