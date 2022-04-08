# frozen_string_literal: true

module NotificationMailers
  class ImportDataCompleted < NotificationMailers::Base

    def set_headers
      @headers[:subject] = I18n.t('notifier.import_completed.data')
    end
  end
end
