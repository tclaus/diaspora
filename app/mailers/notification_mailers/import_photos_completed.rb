# frozen_string_literal: true

module NotificationMailers
  class ImportPhotosCompleted < NotificationMailers::Base

    def set_headers
      @headers[:subject] = I18n.t('notifier.import_completed.photos')
    end
  end
end
