class PostsObserver

  def initialize
    config = Rails.configuration.database_configuration
    pg = PGconn.connect(dbname: config[Rails.env]["database"])
    client = Faye::Client.new('http://127.0.0.1:3000/faye')
    pg.exec "LISTEN posts_insert;"
    pg.exec "LISTEN posts_update;"
    pg.exec "LISTEN posts_delete;"

    EM.next_tick do
      EM.watch(pg.socket, PostsSubscriber, pg, client) { |c| c.notify_readable = true }
    end
  end

end

module PostsSubscriber
  def initialize(pg, faye)
    @pg = pg
    @faye = faye
  end

  def notify_readable

    @pg.consume_input

    while notification = @pg.notifies
      if notification[:relname] =~ /_insert$/
        @faye.publish('/posts', type: 'created', data: notification[:extra])
      elsif notification[:relname] =~ /_update$/
        @faye.publish('/posts', type: 'updated', data: notification[:extra])
      elsif notification[:relname] =~ /_delete$/
        @faye.publish('/posts', type: 'deleted', data: notification[:extra])
      end
    end
  end

  def unbind
    @pg.close
  end
end
