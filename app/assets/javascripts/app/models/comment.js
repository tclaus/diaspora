// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.Comment = Backbone.Model.extend({
  urlRoot: "/comments",

  initialize: function(model, options) {
    options = options || {};
    this.post = model.post || options.post || this.collection.post;
    this.interactions = new app.models.LikeInteractions(
      _.extend({comment: this, post: this.post}, this.get("interactions"))
      );
    this.likes = this.interactions.likes;
    this.likesCount = this.attributes.likes_count;
    this.userLike = this.interactions.userLike();
    this.translation = new app.models.Translation(this.get("translation"), {message: this});
  },

  translate: function() {
    var self = this;
    self.translation.fetch({
      success: function(response) {
        self.set("translatedText", response.get("translatedText"));
        self.set("detectedSourceLanguage", response.get("detectedSourceLanguage"));
        self.translation.trigger("change");
        self.trigger("change");
      },
      error: function(model, response) {
        this.app.flashMessages.handleAjaxError(response);
      }
    });
  },

  translatedText: function() {
    return this.get("translatedText");
  },

  removeTranslation: function() {
    this.unset("translatedText");
  }

});
// @license-end
