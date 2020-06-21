# written by Miki Olsz / (c) 2020 Unforgiven.pl
# released under Apache 2.0 License

require 'github_api'

unless ARGV.size >= 3 && ARGV[0].include?('/') && ARGV[2] =~ /^\d+$/ && %w[true false -].include?(ARGV[4]) && %w[merge squash rebase -].include?(ARGV[3])
  puts <<~HELP
    incorrect parameter syntax or less than three parameters provided, which is probably NOT what was intended
    this script supports the following parameters:
      0 = path/repository    (required)
      1 = auth token         (requited; token must have privileges to create PRs in given repository)
      2 = number of PR       (required; digits only and it must point to an open PR in the repository)
      3 = merge method       (optional; defaults to "merge", other allowed values are "squash" and "rebase")
      4 = delete branch      (optional; defaults to "true"; indicates whether to delete source branch when PR is successful)
      5 = commit message     (optional; '-' means default: "automatic merge of PR #number")
      6 = commit details     (optional; '-' means default: "merging branch <source> to <target>")
      7 = labels to have     (optional; '-' means none; PR must have ALL of the comma-separated labels)
      8 = labels to not have (optional; '-' means none; PR must have NONE of the comma-separated labels)
      9 = delay in seconds   (optional; specifies the delay in performing the merge; defaults to 0)
  HELP
end

user, repository = *ARGV[0].split('/')
token = ARGV[1]
number = ARGV[2].to_i

github = Github.new(oauth_token: token)
begin
  puts "looking for an existing, open PR #{number} in #{user}/#{repository}..."
  existing_pr = github.pulls.get(user: user, repo: repository, number: number)
  unless existing_pr.state == 'open'
    puts "...existing PR is in state #{existing_pr.state}, cannot continue!"
    exit 400
  end

  puts("(requested delay of #{ARGV[9]} seconds, hold on)") or sleep(ARGV[9].to_i) if ARGV[9] =~ /^\d+$/ && ARGV[9].to_i > 0

  required_labels, rejected_labels = [7, 8].map { |num| ARGV[num] && ARGV[num] != '-' ? ARGV[num].split(/\s*,\s*/) : []}
  pr_labels = existing_pr.labels.map(&:name)
  puts "...found PR with labels #{pr_labels}..."
  unless (required_labels.empty? || required_labels & pr_labels == required_labels) && (rejected_labels.empty? || (rejected_labels & pr_labels).empty?)
    puts "...labels do not match; required #{required_labels}, rejected #{rejected_labels}; cannot continue!"
    exit 402
  end

  puts "...ok; attempting to merge..."
  merge_method = ARGV[3].nil? || ARGV[3] == '-' ? 'merge' : ARGV[3]
  commit_title = ARGV[5].nil? || ARGV[5] == '-' ? "automatic merge of PR ##{number}" : ARGV[5]
  commit_details = ARGV[6].nil? || ARGV[6] == '-' ? "merging branch #{existing_pr.head.ref} to #{existing_pr.base.ref}" : ARGV[6]
  github.pulls.merge(user: user, repo: repository, number: number, merge_method: merge_method, sha: existing_pr.head.sha, commit_title: commit_title, commit_details: commit_details)
  puts '...merge completed...'
  if ARGV[4] == '-' || ARGV[4] == "true"
    puts "...deleting branch #{existing_pr.head.ref}..."
    github.git_data.references.delete(user: user, repo: repository, ref: "heads/#{existing_pr.head.ref}")
  end
  puts 'all done; thank you!'
rescue Github::Error::Conflict => e
  puts 'head branch was modified, review and try again'
  puts e.message
  exit 409
rescue Github::Error::MethodNotAllowed => e
  puts 'request cannot be merged, see error message'
  puts e.message
  exit 405
rescue Github::Error::NotFound => e
  puts "PR #{number} not found"
  puts e.message
  exit 404
end
