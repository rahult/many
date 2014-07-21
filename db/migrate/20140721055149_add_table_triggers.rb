class AddTableTriggers < ActiveRecord::Migration
  def change
    # Table level trigger for calling notify_trigger on
    execute "
      CREATE TRIGGER post_changes
      AFTER INSERT OR UPDATE OR DELETE ON posts
      FOR EACH ROW EXECUTE PROCEDURE notify_trigger();
    "

    execute "
      CREATE TRIGGER comment_changes
      AFTER INSERT OR UPDATE OR DELETE ON comments
      FOR EACH ROW EXECUTE PROCEDURE notify_trigger();
    "
  end
end
