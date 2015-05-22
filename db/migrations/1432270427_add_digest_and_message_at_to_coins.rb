Sequel.migration do
  up do
    alter_table(:coins) do
      add_column(:digest, String)
      add_column(:message, String)
    end
  end

  down do
    drop_column :coins, :digest
    drop_column :coins, :message
  end
end
