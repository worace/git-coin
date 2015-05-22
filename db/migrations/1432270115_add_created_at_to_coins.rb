Sequel.migration do
  up do
    alter_table(:coins) do
      add_column(:created_at, DateTime)
    end
  end

  down do
    drop_column :coins, :created_at
  end
end
