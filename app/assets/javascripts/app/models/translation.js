// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.models.Translation = Backbone.Model.extend({
  url: function() {
    return _.result(this.post, "url") + "/translation";
  },

  initialize: function(model, options) {
    this.post = options.post;
  }
});
// @license-end

// Now there are post translations, but i am also interested in comment translations
// /translation/post/:id
// /translation/comment/:id
