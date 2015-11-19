Sequel.migration do
  up do
    drop_table(:debits)
  end

  down do
    create_table(:debits) do
      primary_key :id
      String :digest
      DateTime :created_at
    end
  end
end
