require 'spec_helper'
require 'puppet_labs/github/pull_request'

describe 'PuppetLabs::Github::PullRequest' do
  subject { PuppetLabs::Github::PullRequest.new }
  let(:payload) { read_fixture("example_pull_request.json") }
  let(:data)    { JSON.load(payload) }

  it 'creates a new instance using the from_json class method' do
    pr = PuppetLabs::Github::PullRequest.from_json(payload)
  end

  it 'creates a new instance using the from_data class method' do
    pr = PuppetLabs::Github::PullRequest.from_data(data)
  end

  it 'initializes with json' do
    pr = PuppetLabs::Github::PullRequest.new(:json => payload)
    pr.action.should == "opened"
  end

  it 'initializes with data hash' do
    pr = PuppetLabs::Github::PullRequest.new(:data => data)
    pr.action.should == "opened"
  end

  describe '#load_json' do
    it 'loads a json hash readable through the data method' do
      subject.load_json(payload)
      subject.action.should == "opened"
    end
  end

  describe '#load_data' do
    it 'loads a ruby hash readable through the data method' do
      subject.load_data(data)
      subject.action.should == "opened"
    end

    it "doesn't raise errors if the data has no key named `sender` or `user`" do
      data['sender'] = nil
      data['user'] = nil

      expect { subject.load_data(data) }.to_not raise_error
    end
  end

  describe "#action" do
    actions = [ "opened", "closed", "synchronize" ]
    payloads = [
      read_fixture("example_pull_request.json"),
      read_fixture("example_pull_request_closed.json"),
      read_fixture("example_pull_request_synchronize.json"),
    ]

    actions.zip(payloads).each do |action, payload|
      it "returns '#{action}' when the pull request is #{action}." do
        subject.load_json(payload)
        subject.action.should == action
      end
    end
  end

  context 'newly created pull request' do
    subject { PuppetLabs::Github::PullRequest.new(:json => payload) }

    it 'has a number' do
      subject.number.should == data['pull_request']['number']
    end
    it 'has a repo name' do
      subject.repo_name.should == data['repository']['name']
    end
    it 'has a title' do
      subject.title.should == data['pull_request']['title']
    end
    it 'has a html_url' do
      subject.html_url.should == data['pull_request']['html_url']
    end
    it 'has a body' do
      subject.body.should == data['pull_request']['body']
    end
    it 'has a action' do
      subject.action.should == data['action']
    end
    it 'has a message' do
      subject.message.should == data
    end
    it 'has a created_at' do
      subject.created_at.should == data['pull_request']['created_at']
    end
    it 'has a author' do
      subject.author.should == data['sender']['login']
    end
    it 'has a author_avatar_url' do
      subject.author_avatar_url.should == data['sender']['avatar_url']
    end
  end

  context 'existing pull request' do
    let(:payload) { read_fixture("example_pull_request_by_id.json") }
    subject { PuppetLabs::Github::PullRequest.new(:json => payload) }

    it 'has a number' do
      subject.number.should == data['number']
    end
    it 'has a repo name' do
      subject.repo_name.should == data['base']['repo']['name']
    end
    it 'has a title' do
      subject.title.should == data['title']
    end
    it 'has a html_url' do
      subject.html_url.should == data['html_url']
    end
    it 'has a body' do
      subject.body.should == data['body']
    end
    it 'has a action' do
      subject.action.should == "opened"
    end
    it 'has a message' do
      subject.message.should == data
    end
    it 'has a created_at' do
      subject.created_at.should == data['created_at']
    end
    it 'has a author' do
      subject.author.should == data['user']['login']
    end
    it 'has a author_avatar_url' do
      subject.author_avatar_url.should == data['user']['avatar_url']
    end
  end

  shared_context 'stub Github API' do
    let(:github_account) do
      {
        'name' => 'Github user',
        'email' => 'user@fqdn.blackhole',
        'company' => 'Company Inc.',
        'html_url' => 'fqdn.blackhole',
      }
    end

    before :each do
      github_api = double('github api', :account => github_account)
      pull_request.stub(:github).and_return github_api
    end
  end

  context '#description' do
    let(:pull_request) { PuppetLabs::Github::PullRequest.new(:json => payload) }

    subject { pull_request.description }
    include_context 'stub Github API'

    it "contains the author name" do
      subject.should match pull_request.author_name
    end

    it "contains the author Github ID" do
      subject.should match pull_request.author
    end

    it "contains the pull request number" do
      subject.should match pull_request.number.to_s
    end

    it "contains a link to the discussion" do
      subject.should match pull_request.html_url
    end

    it "contains a link to the file diff" do
      subject.should match "#{pull_request.html_url}/files"
    end

    it "contains the body of the pull request message" do
      subject.should match pull_request.body
    end
  end

  context '#summary' do
    let(:pull_request) { PuppetLabs::Github::PullRequest.new(:json => payload) }

    subject { pull_request.summary }
    include_context 'stub Github API'

    it "contains the pull request number" do
      subject.should match pull_request.number.to_s
    end

    it "contains the pull request title" do
      subject.should match pull_request.title
    end

    it "contains the pull request author name" do
      subject.should match pull_request.author_name
    end
  end
end
