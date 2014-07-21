// For more information see: http://emberjs.com/guides/routing/

Many.IndexRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('post')
  }
});
