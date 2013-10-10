require 'json'
require 'puppet_labs/github/github_mix'

# This class provides a model of a pull rquest.
module PuppetLabs
module Github
class PullRequest
  include GithubMix
  # Pull request data
  attr_reader :number,
    :env,
    :repo_name,
    :title,
    :html_url,
    :body,
    :action,
    :message,
    :created_at,
    :author,
    :author_avatar_url

  def self.from_json(json)
    new(:json => json)
  end

  def self.from_data(data)
    new(:data => data)
  end

  def initialize(options = {})
    if json = options[:json]
      load_json(json)
    elsif data = options[:data]
      load_data(data)
    end
    if env = options[:env]
      @env = env
    else
      @env = ENV.to_hash
    end
  end

  def load_json(json)
    load_data(JSON.load(json))
  end

  def load_data(data)
    @message = data
    pr = data['pull_request'] || data
    @number = pr['number']
    @title = pr['title']
    @html_url = pr['html_url']
    @body = pr['body']
    repo = data['repository'] || data['base']['repo']
    @repo_name = repo['name']
    @action = data['action']
    @action = 'opened' if action.nil? && data['state'] == 'open'
    @created_at = pr['created_at']
    sender = data['sender'] || data['user']
    if sender
      @author = sender['login']
      @author_avatar_url = sender['avatar_url']
    end
  end

  def description
    desc = <<-DESC.gsub(/^ {4}/, '')
      ----

       * Author: **#{author_name}** <#{author_email}>",
       * Company: #{author_company}",
       * Github ID: [#{author}](#{author_html_url})",
       * [Pull Request #{number} Discussion](#{html_url})",
       * [File Diff](#{html_url}/files)",

      Pull Request Description
      ====

      #{body}
    DESC

    desc
  end

  def summary
    "Pull Request #{number}: #{title} [#{author_name}]"
  end
end
end
end
