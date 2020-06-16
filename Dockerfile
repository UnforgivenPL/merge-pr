FROM ruby:2.6

COPY Gemfile Gemfile.lock merge-pr.sh merge-pr.rb ./
RUN bundle install
RUN chmod +x /merge-pr.sh

ENTRYPOINT ["/merge-pr.sh"]