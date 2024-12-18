# frozen_string_literal: true

module Spam
  class SpamRating
    attr_reader :user

    # Enum zur Gesamt-Bewerung eines users
    EVALUATIONS = {
      good:    0,
      warning: 1,
      bad:     2
    }.freeze

    def initialize(user)
      @user = user
    end

    def spam_label_class
      case spam_evaluation
      when :good
        "label-success"
      when :warning
        "label-warning"
      when :bad
        "label-danger"
      else
        ""
      end
    end

    def spam_evaluation
      score = spam_score
      return :good if score < 0.3
      return :warning if score < 0.6

      :bad
    end

    # Creates a value from 0 to 1. 0 means no message has a positive spam value, 1 means every message has been tested
    # positive for spam.
    # However. 0 Should not mean, there is no spam (in terms of unwanted text), it may be too short to test or the
    # message could be in a not supported language.
    # A value of 1 could mean on the other side, that message may have a 'false positive'  # score then means to
    # check the actual messages and maybe set the spam value manually.
    def spam_score
      return 0 if total_message_count == 0

      total_spam_count.to_f / total_message_count
    end

    private

    def total_spam_count
      Post.where(author_id: user.id, spam: true).count +
              Comment.where(author_id: user.id, spam: true).count
    end

    def total_message_count
      Post.where(author_id: user.id).count + Comment.where(author_id: user.id).count
    end
  end
end
