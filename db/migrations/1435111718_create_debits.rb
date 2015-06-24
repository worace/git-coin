Sequel.migration do
  up do
    create_table(:debits) do
      primary_key :id
      String :digest
      DateTime :created_at
    end
  end

  down do
    drop_table(:debits)
  end
end
