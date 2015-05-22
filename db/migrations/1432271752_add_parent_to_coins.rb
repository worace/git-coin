Sequel.migration do
  up do
    alter_table(:coins) do
      add_column(:parent, String)
    end
  end

  down do
    drop_column :coins, :parent
  end
end
