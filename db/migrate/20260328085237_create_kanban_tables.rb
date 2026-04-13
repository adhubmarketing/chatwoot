class CreateKanbanTables < ActiveRecord::Migration[7.1]
  def change
    # Kanban Boards - main board entity
    create_table :kanban_boards do |t|
      t.references :account, null: false, index: true
      t.string :name, null: false
      t.text :description
      t.jsonb :settings, default: {}
      t.integer :steps_order, array: true, default: []

      t.timestamps
    end

    add_index :kanban_boards, [:account_id, :name], unique: true, if_not_exists: true

    # Kanban Board Steps - columns in the board
    create_table :kanban_board_steps do |t|
      t.references :account, null: false, index: true
      t.references :board, null: false, foreign_key: { to_table: :kanban_boards }
      t.string :name, null: false
      t.text :description
      t.string :color, null: false, default: '#1f93ff'
      t.integer :tasks_count, default: 0, null: false
      t.boolean :cancelled, default: false, null: false

      t.timestamps
    end

    add_index :kanban_board_steps, [:board_id, :name], unique: true, if_not_exists: true

    # Kanban Tasks - individual tasks
    create_table :kanban_tasks do |t|
      t.references :account, null: false, index: true
      t.references :board, null: false, foreign_key: { to_table: :kanban_boards }
      t.references :step, null: true, foreign_key: { to_table: :kanban_board_steps }
      t.string :title, null: false
      t.text :description, limit: 5000
      t.integer :priority, default: 0, null: false
      t.integer :position, null: false
      t.date :start_date
      t.date :due_date
      t.string :cached_label_list
      t.datetime :step_changed_at

      t.timestamps
    end

    add_index :kanban_tasks, [:account_id], if_not_exists: true
    add_index :kanban_tasks, [:board_id, :step_id, :position], if_not_exists: true
    add_index :kanban_tasks, [:due_date], if_not_exists: true
    add_index :kanban_tasks, [:priority], if_not_exists: true

    # Join table: Kanban Board <-> Agents
    create_table :kanban_board_agents do |t|
      t.references :account, null: false, index: true
      t.references :board, null: false, foreign_key: { to_table: :kanban_boards }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_board_agents, [:board_id, :user_id], unique: true, if_not_exists: true

    # Join table: Kanban Board <-> Inboxes
    create_table :kanban_board_inboxes do |t|
      t.references :account, null: false, index: true
      t.references :board, null: false, foreign_key: { to_table: :kanban_boards }
      t.references :inbox, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_board_inboxes, [:board_id, :inbox_id], unique: true, if_not_exists: true

    # Join table: Kanban Task <-> Agents
    create_table :kanban_task_agents do |t|
      t.references :account, null: false, index: true
      t.references :task, null: false, foreign_key: { to_table: :kanban_tasks }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_task_agents, [:task_id, :user_id], unique: true, if_not_exists: true

    # Join table: Kanban Task <-> Contacts
    create_table :kanban_task_contacts do |t|
      t.references :account, null: false, index: true
      t.references :task, null: false, foreign_key: { to_table: :kanban_tasks }
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end

    add_index :kanban_task_contacts, [:task_id, :contact_id], unique: true, if_not_exists: true

    # Kanban Audit Events - change history
    create_table :kanban_audit_events do |t|
      t.references :account, null: false, index: true
      t.references :task, null: false, foreign_key: { to_table: :kanban_tasks }
      t.string :action, null: false
      t.jsonb :metadata, default: {}
      t.references :performed_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :kanban_audit_events, [:task_id, :created_at], if_not_exists: true
    add_index :kanban_audit_events, [:account_id, :created_at], if_not_exists: true

    # Kanban Account User Preferences - user-specific settings
    create_table :kanban_account_user_preferences do |t|
      t.references :account, null: false, index: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :preferences, default: {}

      t.timestamps
    end

    add_index :kanban_account_user_preferences, [:account_id, :user_id], unique: true, name: 'index_kanban_prefs_on_account_and_user', if_not_exists: true

    # Add kanban_task_id to conversations
    add_reference :conversations, :kanban_task, foreign_key: { to_table: :kanban_tasks }, index: true
  end
end
