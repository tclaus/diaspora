# frozen_string_literal: true
#
class PushNotificationService
  def initialize
    OneSignal::OneSignal.api_key = '9e1a5a1e-402a-4b12-9fcf-526457a0ae3d'
    OneSignal::OneSignal.user_auth_key = 'N2JhNjdlNDktMTM3OC00MWJlLTljNWMtNGIzMTdkNmVkYjUx'
  end

  def deliver_message(toUser, message)
    OneSignal::Player.get(id: toUser.guid)
    OneSignal::Notification.create(params: {
            included_segments: [],
            contents: {
                    en: "EN " + message,
                    de: "DE " + message
            },
            filters: {
                    include_player_ids: ["playerId"]
            }
    })
  end

end
