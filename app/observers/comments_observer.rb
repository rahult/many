class CommentsObserver

  def initialize
    config = Rails.configuration.database_configuration
    pg = PGconn.connect(dbname: config[Rails.env]["database"])
    client = Faye::Client.new('http://127.0.0.1:3000/faye')
    pg.exec "LISTEN comments_insert;"
    pg.exec "LISTEN comments_update;"
    pg.exec "LISTEN comments_delete;"

    EM.next_tick do
      EM.watch(pg.socket, CommentsSubscriber, pg, client) { |c| c.notify_readable = true }
    end
  end

end

module CommentsSubscriber
  def initialize(pg, faye)
    @pg = pg
    @faye = faye
  end

  def notify_readable

    @pg.consume_input

    while notification = @pg.notifies
      if notification[:relname] =~ /_insert$/
        @faye.publish('/comments', type: 'created', data: notification[:extra])
      elsif notification[:relname] =~ /_update$/
        @faye.publish('/comments', type: 'updated', data: notification[:extra])
      elsif notification[:relname] =~ /_delete$/
        @faye.publish('/comments', type: 'deleted', data: notification[:extra])
      end
    end
  end

  def unbind
    @pg.close
  end
end
