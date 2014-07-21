Many.ApplicationRoute = Ember.Route.extend({
  setupController: function(controller, model) {

    var store = this.get('store');
    var client = new Faye.Client("/faye", {
      retry: 5,
      timeout: 120
    });

    client.subscribe("/posts", function(message) {
      if (message.type === "created") {
        store.push('post', JSON.parse(message.data));
      } else if (message.type === "updated") {
        store.find('post', JSON.parse(message.data).id).then(function(post) {
          post.reload();
        });
      } else if (message.type === "deleted") {
        store.find('post', JSON.parse(message.data).id).then(function(post) {
          post.unloadRecord();
        });
      }
    });

    client.subscribe("/comments", function(message) {
      if (message.type === "created") {
        store.find('post', JSON.parse(message.data).post_id).then(function(post) {
          post.reload();
        });
      } else if (message.type === "updated") {
        store.find('comment', JSON.parse(message.data).id).then(function(comment) {
          comment.reload();
        });
      } else if (message.type === "deleted") {
        store.find('comment', JSON.parse(message.data).id).then(function(comment) {
          comment.unloadRecord();
        });
      }
    });

  }
});
