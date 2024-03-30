// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//= require ./content_view
app.views.Comment = app.views.Content.extend({
  templateName: "comment",
  className : "comment media",
  tooltipSelector: "time",

  subviews: {
    ".likes-on-comment": "likesInfoView"
  },

  events: function() {
    return _.extend({}, app.views.Content.prototype.events, {
      "click .comment_delete": "destroyModel",
      "click .comment_report": "report",
      "click .like": "toggleLike",
      "click .comment-translate": "translateComment"
    });
  },

  initialize: function(options) {
    this.templateName = options.templateName || this.templateName;
    this.model.interactions.on("change", this.render, this);
    this.model.on("change", this.render, this);
    this.model.set("translationEnabled", this.translationEnabled());
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      canRemove: this.canRemove(),
      text: app.helpers.textFormatter(this.model.get("text"), this.model.get("mentioned_people")),
      likesCount: this.model.attributes.likesCount,
      userLike: this.model.interactions.userLike(),
      translatedFormattedText: function() {
        if (this.translatedText) {
          return app.helpers.textFormatter(this.translatedText, this.mentioned_people);
        }
        return undefined;
      }
    });
  },

  translateComment: function(evt) {
    if (evt) {
      evt.preventDefault();
    }
    if (this.hasTranslation()) {
      this.removeTranslation();
    } else {
      this.model.translate();
    }
  },

  translationEnabled: function() {
    return gon.translationEnabled && app.currentUser.authenticated();
  },

  removeTranslation: function(evt) {
    if (evt) {
      evt.preventDefault();
    }
    this.model.removeTranslation();
  },

  hasTranslation: function() {
    return !(this.model.translatedText() === undefined);
  },

  translatedText: function() {
    return this.model.translatedText();
  },

  detectedSourceLanguage: function() {
    return this.model.detectedSourceLanguage();
  },

  ownComment: function() {
    return app.currentUser.authenticated() && this.model.get("author").diaspora_id === app.currentUser.get("diaspora_id");
  },

  postOwner: function() {
    return  app.currentUser.authenticated() && this.model.get("parent").author.diaspora_id === app.currentUser.get("diaspora_id");
  },

  canRemove: function() {
    return app.currentUser.authenticated() && (this.ownComment() || this.postOwner());
  },

  toggleLike: function(evt) {
    if (evt) { evt.preventDefault(); }
    this.model.interactions.toggleLike();
  },

  likesInfoView: function() {
    return new app.views.LikesInfo({model: this.model});
  }
});

app.views.ExpandedComment = app.views.Comment.extend({
  postRenderTemplate : function(){
    this.bindMediaEmbedThumbClickEvent();
  }
});
// @license-end
